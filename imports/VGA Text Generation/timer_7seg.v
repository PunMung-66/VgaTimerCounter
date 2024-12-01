module timer_7seg(
    input clk,                   // 100 MHz clock input
    input btnC,                  // U18: Start/Stop button
    input btnL,                  // W19: Decrease 1 minute button
    input btnR,                  // T17: Increase 1 minute button
    input btnU,                  // T18: Reset button
    input mode,                  // Mode switch input
    output reg [3:0] an,         // Anodes for 7-segment displays
    output reg [6:0] seg         // Cathodes for segments (a to g)
);
    // Internal registers
    reg [6:0] minutes = 0;       // Initialize timer at 00 minutes
    reg [5:0] seconds = 0;       // Initialize seconds at 00
    reg running = 0;             // Running state of timer

    // Clock divider to generate 1 Hz clock
    reg [26:0] clk_div = 0;
    wire clk_1hz = (clk_div == 100_000_000 - 1);

    always @(posedge clk) begin
        if (clk_1hz)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    // Debounce logic for buttons (simple implementation)
    reg btnC_db, btnL_db, btnR_db, btnU_db;
    reg btnC_prev, btnL_prev, btnR_prev, btnU_prev;

    always @(posedge clk or posedge mode) begin
        if (mode) begin
            btnC_prev <= 0;
            btnL_prev <= 0;
            btnR_prev <= 0;
            btnU_prev <= 0;
            btnC_db <= 0;
            btnL_db <= 0;
            btnR_db <= 0;
            btnU_db <= 0;
        end else begin
            btnC_prev <= btnC;
            btnL_prev <= btnL;
            btnR_prev <= btnR;
            btnU_prev <= btnU;

            btnC_db <= (btnC && !btnC_prev);
            btnL_db <= (btnL && !btnL_prev);
            btnR_db <= (btnR && !btnR_prev);
            btnU_db <= (btnU && !btnU_prev);
        end
    end

    // Button event handling and timer countdown logic
    always @(posedge clk) begin
        if (btnU_db) begin
            running <= 0;
            minutes <= 0;
            seconds <= 0;
        end else if (btnC_db) begin
            running <= ~running;
        end

        if (btnL_db && minutes > 0 && !running)
            minutes <= minutes - 1;
        if (btnR_db && minutes < 99 && !running)
            minutes <= minutes + 1;

        if (running && clk_1hz) begin
            if (seconds == 0) begin
                if (minutes > 0) begin
                    minutes <= minutes - 1;
                    seconds <= 59;
                end
            end else begin
                seconds <= seconds - 1;
            end
        end
    end

    // 7-Segment display multiplexing
    reg [18:0] refresh_counter = 0; // Refresh counter for multiplexing
    wire refresh_clk = refresh_counter[18]; // Slower clock for refreshing display

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end

    reg [1:0] display_digit = 0;
    reg [3:0] digit_value;

    always @(posedge refresh_clk) begin
        case (display_digit)
            2'd0: begin
                an <= 4'b0111;
                digit_value <= minutes / 10;
            end
            2'd1: begin
                an <= 4'b1011;
                digit_value <= minutes % 10;
            end
            2'd2: begin
                an <= 4'b1101;
                digit_value <= seconds / 10;
            end
            2'd3: begin
                an <= 4'b1110;
                digit_value <= seconds % 10;
            end
        endcase
        // Move to next digit
        display_digit <= display_digit + 1;
    end

    // 7-Segment decoding logic
    always @(*) begin
        case (digit_value)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            4'd10: seg = 7'b0001000; // A
            4'd11: seg = 7'b0000011; // L
            4'd12: seg = 7'b1000110; // C
            4'd13: seg = 7'b0100001; // U
            4'd14: seg = 7'b0101011; // C
            default: seg = 7'b1111111;
        endcase
    end
endmodule