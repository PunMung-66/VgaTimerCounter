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
    wire btnR_debounced, btnL_debounced;

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

    debounce_better_version debounce_inst2(
        .clk(clk),
        .pb_1(btnL),
        .pb_out(btnL_debounced)
    );

    // Detect btnR press (rising edge)
    reg btnR_state, btnR_pressed;
    reg btnL_state, btnL_pressed;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btnR_state <= 0;
            btnR_pressed <= 0;

            btnL_state <= 0;
            btnL_pressed <= 0;
        end else begin
            btnR_pressed <= btnR_debounced && !btnR_state; // Detect rising edge
            btnR_state <= btnR_debounced; // Update state

            btnL_pressed <= btnL_debounced && !btnL_state; // Detect rising edge
            btnL_state <= btnL_debounced; // Update state
        end
    end

    // Update data_raw_reg when btnR is pressed
    integer i, j, segment_idx;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_raw_reg <= 256'd0; // Clear all 16-bit segments
        end else if (btnR_pressed) begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 4; j < 8; j = j + 1) begin
                    if (sw[i] && sw[j]) begin
                        // Compute the starting bit of the 16-bit segment
                        segment_idx = 255 - (4 * i + (j - 4)) * 16;
                        // Increment the 16-bit segment
                        data_raw_reg[segment_idx -: 16] <= data_raw_reg[segment_idx -: 16] + 1;
                    end
                end
            end
        end else if (btnL_pressed) begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 4; j < 8; j = j + 1) begin
                    if (sw[i] && sw[j]) begin
                        // Compute the starting bit of the 16-bit segment
                        segment_idx = 255 - (4 * i + (j - 4)) * 16;
                        // Decrement the 16-bit segment, ensuring no underflow
                        if (data_raw_reg[segment_idx -: 16] > 0)
                            data_raw_reg[segment_idx -: 16] <= data_raw_reg[segment_idx -: 16] - 1;
                    end
                end
            end
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