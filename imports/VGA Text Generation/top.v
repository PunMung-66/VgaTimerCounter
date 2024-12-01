`timescale 1ns / 1ps

module top(
    input clk,          // 100MHz on Basys 3
    input reset,        // btnC on Basys 3
    input button,       // Button for incrementing values
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
    wire button_debounced;

    // Initial block for data_raw_reg
    initial begin
        data_raw_reg = {16'd0000, 16'd0001, 16'd0002, 16'd0003, 16'd0004, 16'd0005, 16'd0006, 16'd0007, 
                        16'd0008, 16'd0009, 16'd0010, 16'd0011, 16'd0012, 16'd0013, 16'd0014, 16'd0015};
    end

    // Instantiate debounce logic
    debounce_better_version debounce_inst(
        .clk(clk),
        .pb_1(button),
        .pb_out(button_debounced)
    );

    // Detect button press (rising edge)
    reg button_state, button_pressed;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            button_state <= 0;
            button_pressed <= 0;
        end else begin
            button_pressed <= button_debounced && !button_state; // Detect rising edge
            button_state <= button_debounced; // Update state
        end
    end

    // Update data_raw_reg when button is pressed
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_raw_reg <= {16'd0000, 16'd0001, 16'd0002, 16'd0003, 16'd0004, 16'd0005, 16'd0006, 16'd0007, 
                             16'd0008, 16'd0009, 16'd0010, 16'd0011, 16'd0012, 16'd0013, 16'd0014, 16'd0015};
        end else if (button_pressed) begin
            for (i = 0; i < 16; i = i + 1) begin
                data_raw_reg[(i*16) +: 16] <= data_raw_reg[(i*16) +: 16] + 1;
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

module debounce_better_version(input pb_1,clk,output pb_out);
wire slow_clk_en;
wire Q1,Q2,Q2_bar,Q0;
clock_enable u1(clk,slow_clk_en);
my_dff_en d0(clk,slow_clk_en,pb_1,Q0);

my_dff_en d1(clk,slow_clk_en,Q0,Q1);
my_dff_en d2(clk,slow_clk_en,Q1,Q2);
assign Q2_bar = ~Q2;
assign pb_out = Q1 & Q2_bar;
endmodule
// Slow clock enable for debouncing button 
module clock_enable(input Clk_100M,output slow_clk_en);
    reg [26:0]counter=0;
    always @(posedge Clk_100M)
    begin
       counter <= (counter>=249999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 249999)?1'b1:1'b0;
endmodule
// D-flip-flop with clock enable signal for debouncing module 
module my_dff_en(input DFF_CLOCK, clock_enable,D, output reg Q=0);
    always @ (posedge DFF_CLOCK) begin
  if(clock_enable==1) 
           Q <= D;
    end
endmodule 