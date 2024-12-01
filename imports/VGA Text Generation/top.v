`timescale 1ns / 1ps

module top(
    input clk,          // 100MHz on Basys 3
    input reset,        // btnC on Basys 3
    input btnC,         // U18: Start/Stop button
    input btnL,         // W19: Decrease 1 minute button
    input btnR,         // T17: Increase 1 minute button
    input btnU,         // T18: Reset button
    input [7:0] sw,  // Switch inputs
    output hsync,       // to VGA connector
    output vsync,       // to VGA connector
    output [11:0] rgb   // to DAC, to VGA connector
    );

    // Signals
    wire [9:0] w_x, w_y;
    wire w_video_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [255:0] data_raw;
    reg [255:0] data_raw_reg;

    // Debounce signals
    wire btnR_debounced;

    // Initial block for data_raw_reg
    initial begin
        data_raw_reg = {16'd0000, 16'd0001, 16'd0002, 16'd0003, 16'd0004, 16'd0005, 16'd0006, 16'd0007, 
                        16'd0008, 16'd0009, 16'd0010, 16'd0011, 16'd0012, 16'd0013, 16'd0014, 16'd0015};
    end

    // Instantiate debounce logic
    debounce_better_version debounce_inst(
        .clk(clk),
        .pb_1(btnR),
        .pb_out(btnR_debounced)
    );

    // Detect btnR press (rising edge)
    reg btnR_state, btnR_pressed;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btnR_state <= 0;
            btnR_pressed <= 0;
        end else begin
            btnR_pressed <= btnR_debounced && !btnR_state; // Detect rising edge
            btnR_state <= btnR_debounced; // Update state
        end
    end

    // Update data_raw_reg when btnR is pressed
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_raw_reg <= {16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000, 
                             16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000, 16'd0000};
        end else if (btnR_pressed) begin
            if (sw[0] == 1 && sw[4] == 1) begin
                data_raw_reg[255:240] = data_raw_reg[255:240] + 1;
            end

            if (sw[0] == 1 && sw[5] == 1) begin
                data_raw_reg[239:224] = data_raw_reg[239:224] + 1;
            end

            if (sw[0] == 1 && sw[6] == 1) begin
                data_raw_reg[223:208] = data_raw_reg[223:208] + 1;
            end

            if (sw[0] == 1 && sw[7] == 1) begin
                data_raw_reg[207:192] = data_raw_reg[207:192] + 1;
            end

            if (sw[1] == 1 && sw[4] == 1) begin
                data_raw_reg[191:176] = data_raw_reg[191:176] + 1;
            end

            if (sw[1] == 1 && sw[5] == 1) begin
                data_raw_reg[175:160] = data_raw_reg[175:160] + 1;
            end

            if (sw[1] == 1 && sw[6] == 1) begin
                data_raw_reg[159:144] = data_raw_reg[159:144] + 1;
            end

            if (sw[1] == 1 && sw[7] == 1) begin
                data_raw_reg[143:128] = data_raw_reg[143:128] + 1;
            end

            if (sw[2] == 1 && sw[4] == 1) begin
                data_raw_reg[127:112] = data_raw_reg[127:112] + 1;
            end

            if (sw[2] == 1 && sw[5] == 1) begin
                data_raw_reg[111:96] = data_raw_reg[111:96] + 1;
            end

            if (sw[2] == 1 && sw[6] == 1) begin
                data_raw_reg[95:80] = data_raw_reg[95:80] + 1;
            end

            if (sw[2] == 1 && sw[7] == 1) begin
                data_raw_reg[79:64] = data_raw_reg[79:64] + 1;
            end

            if (sw[3] == 1 && sw[4] == 1) begin
                data_raw_reg[63:48] = data_raw_reg[63:48] + 1;
            end

            if (sw[3] == 1 && sw[5] == 1) begin
                data_raw_reg[47:32] = data_raw_reg[47:32] + 1;
            end

            if (sw[3] == 1 && sw[6] == 1) begin
                data_raw_reg[31:16] = data_raw_reg[31:16] + 1;
            end

            if (sw[3] == 1 && sw[7] == 1) begin
                data_raw_reg[15:0] = data_raw_reg[15:0] + 1;
            end

            // // Original code

            // if (sw[0] == 1 && sw[4] == 1) begin
            //     if (add_button) data_raw_reg[255:240] = data_raw_reg[255:240] + 1;
            //     else if ((data_raw_reg[255:240] - 1) == 0) data_raw_reg[255:240] = 16'd0000;
            //     else if (minus_button) data_raw_reg[255:240] = data_raw_reg[255:240] - 1;
            // end

            // if (sw[0] == 1 && sw[5] == 1) begin
            //     if (add_button) data_raw_reg[239:224] = data_raw_reg[239:224] + 1;
            //     else if ((data_raw_reg[239:224] - 1) == 0) data_raw_reg[239:224] = 16'd0000;
            //     else if (minus_button) data_raw_reg[239:224] = data_raw_reg[239:224] - 1;
            // end

            // if (sw[0] == 1 && sw[6] == 1) begin
            //     if (add_button) data_raw_reg[223:208] = data_raw_reg[223:208] + 1;
            //     else if ((data_raw_reg[223:208] - 1) == 0) data_raw_reg[223:208] = 16'd0000;
            //     else if (minus_button) data_raw_reg[223:208] = data_raw_reg[223:208] - 1;
            // end

            // if (sw[0] == 1 && sw[7] == 1) begin
            //     if (add_button) data_raw_reg[207:192] = data_raw_reg[207:192] + 1;
            //     else if ((data_raw_reg[207:192] - 1) == 0) data_raw_reg[207:192] = 16'd0000;
            //     else if (minus_button) data_raw_reg[207:192] = data_raw_reg[207:192] - 1;
            // end

            // if (sw[1] == 1 && sw[4] == 1) begin
            //     if (add_button) data_raw_reg[191:176] = data_raw_reg[191:176] + 1;
            //     else if ((data_raw_reg[191:176] - 1) == 0) data_raw_reg[191:176] = 16'd0000;
            //     else if (minus_button) data_raw_reg[191:176] = data_raw_reg[191:176] - 1;
            // end

            // if (sw[1] == 1 && sw[5] == 1) begin
            //     if (add_button) data_raw_reg[175:160] = data_raw_reg[175:160] + 1;
            //     else if ((data_raw_reg[175:160] - 1) == 0) data_raw_reg[175:160] = 16'd0000;
            //     else if (minus_button) data_raw_reg[175:160] = data_raw_reg[175:160] - 1;
            // end

            // if (sw[1] == 1 && sw[6] == 1) begin
            //     if (add_button) data_raw_reg[159:144] = data_raw_reg[159:144] + 1;
            //     else if ((data_raw_reg[159:144] - 1) == 0) data_raw_reg[159:144] = 16'd0000;
            //     else if (minus_button) data_raw_reg[159:144] = data_raw_reg[159:144] - 1;
            // end

            // if (sw[1] == 1 && sw[7] == 1) begin
            //     if (add_button) data_raw_reg[143:128] = data_raw_reg[143:128] + 1;
            //     else if ((data_raw_reg[143:128] - 1) == 0) data_raw_reg[143:128] = 16'd0000;
            //     else if (minus_button) data_raw_reg[143:128] = data_raw_reg[143:128] - 1;
            // end

            // if (sw[2] == 1 && sw[4] == 1) begin
            //     if (add_button) data_raw_reg[127:112] = data_raw_reg[127:112] + 1;
            //     else if ((data_raw_reg[127:112] - 1) == 0) data_raw_reg[127:112] = 16'd0000;
            //     else if (minus_button) data_raw_reg[127:112] = data_raw_reg[127:112] - 1;
            // end

            // if (sw[2] == 1 && sw[5] == 1) begin
            //     if (add_button) data_raw_reg[111:96] = data_raw_reg[111:96] + 1;
            //     else if ((data_raw_reg[111:96] - 1) == 0) data_raw_reg[111:96] = 16'd0000;
            //     else if (minus_button) data_raw_reg[111:96] = data_raw_reg[111:96] - 1;
            // end

            // if (sw[2] == 1 && sw[6] == 1) begin
            //     if (add_button) data_raw_reg[95:80] = data_raw_reg[95:80] + 1;
            //     else if ((data_raw_reg[95:80] - 1) == 0) data_raw_reg[95:80] = 16'd0000;
            //     else if (minus_button) data_raw_reg[95:80] = data_raw_reg[95:80] - 1;
            // end

            // if (sw[2] == 1 && sw[7] == 1) begin
            //     if (add_button) data_raw_reg[79:64] = data_raw_reg[79:64] + 1;
            //     else if ((data_raw_reg[79:64] - 1) == 0) data_raw_reg[79:64] = 16'd0000;
            //     else if (minus_button) data_raw_reg[79:64] = data_raw_reg[79:64] - 1;
            // end

            // if (sw[3] == 1 && sw[4] == 1) begin
            //     if (add_button) data_raw_reg[63:48] = data_raw_reg[63:48] + 1;
            //     else if ((data_raw_reg[63:48] - 1) == 0) data_raw_reg[63:48] = 16'd0000;
            //     else if (minus_button) data_raw_reg[63:48] = data_raw_reg[63:48] - 1;
            // end

            // if (sw[3] == 1 && sw[5] == 1) begin
            //     if (add_button) data_raw_reg[47:32] = data_raw_reg[47:32] + 1;
            //     else if ((data_raw_reg[47:32] - 1) == 0) data_raw_reg[47:32] = 16'd0000;
            //     else if (minus_button) data_raw_reg[47:32] = data_raw_reg[47:32] - 1;
            // end

            // if (sw[3] == 1 && sw[6] == 1) begin
            //     if (add_button) data_raw_reg[31:16] = data_raw_reg[31:16] + 1;
            //     else if ((data_raw_reg[31:16] - 1) == 0) data_raw_reg[31:16] = 16'd0000;
            //     else if (minus_button) data_raw_reg[31:16] = data_raw_reg[31:16] - 1;
            // end

            // if (sw[3] == 1 && sw[7] == 1) begin
            //     if (add_button) data_raw_reg[15:0] = data_raw_reg[15:0] + 1;
            //     else if ((data_raw_reg[15:0] - 1) == 0) data_raw_reg[15:0] = 16'd0000;
            //     else if (minus_button) data_raw_reg[15:0] = data_raw_reg[15:0] - 1;
            // end

        end
    end

    // RGB buffer
    always @(posedge clk)
        if (w_p_tick)
            rgb_reg <= rgb_next;

    // Output assignments
    assign rgb = rgb_reg;
    assign data_raw = data_raw_reg;

    // VGA Controller
    vga_controller vga(
        .clk_100MHz(clk), 
        .reset(reset), 
        .hsync(hsync), 
        .vsync(vsync),
        .video_on(w_video_on), 
        .p_tick(w_p_tick), 
        .x(w_x), 
        .y(w_y)
    );

    // Text Generation Circuit
    ascii_test at(
        .clk(clk), 
        .video_on(w_video_on), 
        .x(w_x), 
        .y(w_y), 
        .rgb(rgb_next), 
        .data_raw(data_raw)
    );

endmodule