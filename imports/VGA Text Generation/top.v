// `timescale 1ns / 1ps

// module top(
//     input clk,          // 100MHz on Basys 3
//     input reset,        // btnC on Basys 3
//     output hsync,       // to VGA connector
//     output vsync,       // to VGA connector
//     output [11:0] rgb   // to DAC, to VGA connector
//     );
    
//     // signals
//     wire [9:0] w_x, w_y;
//     wire w_video_on, w_p_tick;
//     reg [11:0] rgb_reg;
//     wire [11:0] rgb_next;
//     wire [255:0] data_raw;
//     reg [255:0] data_raw_reg;

//     initial begin
//         data_raw_reg = {16'd0000, 16'd0001, 16'd0002, 16'd0003, 16'd0004, 16'd0005, 16'd0006, 16'd0007, 16'd0008, 16'd0009, 16'd0010, 16'd0011, 16'd0012, 16'd0013, 16'd0014, 16'd0015};
//     end
    
    
//     // rgb buffer
//     always @(posedge clk)
//         if(w_p_tick)
//             rgb_reg <= rgb_next;
            
//     // output
//     assign rgb = rgb_reg;
//     assign data_raw = data_raw_reg;

//     // VGA Controller
//     vga_controller vga(.clk_100MHz(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
//                        .video_on(w_video_on), .p_tick(w_p_tick), .x(w_x), .y(w_y));
//     // Text Generation Circuit
//     ascii_test at(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next), .data_raw(data_raw));
      
// endmodule


module top(
    input clk,          // 100MHz on Basys 3
    input reset,        // btnC on Basys 3
    output hsync,       // to VGA connector
    output vsync,       // to VGA connector
    output [11:0] rgb   // to DAC, to VGA connector
    );

    // signals
    wire [9:0] w_x, w_y;
    wire w_video_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [255:0] data_raw;
    reg [255:0] data_raw_reg;

    // Clock divider for 1-second pulse
    reg [26:0] clk_div_counter; // Enough bits for 100MHz to 1Hz division
    reg one_sec_pulse;

    initial begin
        data_raw_reg = {16'd0000, 16'd0001, 16'd0002, 16'd0003, 16'd0004, 16'd0005, 16'd0006, 16'd0007, 
                        16'd0008, 16'd0009, 16'd0010, 16'd0011, 16'd0012, 16'd0013, 16'd0014, 16'd0015};
        clk_div_counter = 0;
        one_sec_pulse = 0;
    end

    // Generate 1-second pulse
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div_counter <= 0;
            one_sec_pulse <= 0;
        end else if (clk_div_counter == 100_000_000 - 1) begin // 100 MHz clock
            clk_div_counter <= 0;
            one_sec_pulse <= 1;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
            one_sec_pulse <= 0;
        end
    end

    // Increment each 16-bit value in data_raw_reg every second
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_raw_reg <= {16'd0000, 16'd0001, 16'd0002, 16'd0003, 16'd0004, 16'd0005, 16'd0006, 16'd0007, 
                             16'd0008, 16'd0009, 16'd0010, 16'd0011, 16'd0012, 16'd0013, 16'd0014, 16'd0015};
        end else if (one_sec_pulse) begin
            for (i = 0; i < 16; i = i + 1) begin
                data_raw_reg[(i*16) +: 16] <= data_raw_reg[(i*16) +: 16] + 1;
            end
        end
    end

    // RGB buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    // output
    assign rgb = rgb_reg;
    assign data_raw = data_raw_reg;

    // VGA Controller
    vga_controller vga(.clk_100MHz(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
                       .video_on(w_video_on), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    // Text Generation Circuit
    ascii_test at(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next), .data_raw(data_raw));

endmodule
