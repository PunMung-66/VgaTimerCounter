`timescale 1ns / 1ps

module ascii_test (
    input clk,
    input video_on,
    input [9:0] x, y,
    output reg [11:0] rgb
);

    // Parameters
    parameter CHAR_SIZE = 8;
    parameter ROW_START = 112;
    parameter ROW_HEIGHT = 16;
    parameter COL_START = 104;

    // ASCII ROM interface
    wire [10:0] rom_addr;      // 11-bit text ROM address
    reg [6:0] ascii_char;      // 7-bit ASCII character code
    wire [3:0] char_row;       // 4-bit row of ASCII character
    wire [2:0] bit_addr;       // Column number of ROM data
    wire [7:0] rom_data;       // 8-bit row data from text ROM
    wire ascii_bit, ascii_bit_on;

    // ASCII ROM instantiation
    ascii_rom rom (.clk(clk), .addr(rom_addr), .data(rom_data));

    // Assignments for ROM interface
    assign rom_addr = {ascii_char, char_row};
    assign ascii_bit = rom_data[~bit_addr];
    assign char_row = y[3:0];
    assign bit_addr = x[2:0];

    // ASCII Text Definitions
    localparam [6:0] BLANK = 7'h20;
    // ASCII Text Definitions
    wire [48:0] men;            // "MEN"
    wire [48:0] women;          // "WOMEN"
    wire [48:0] elderly;        // "ELDERLY"
    wire [48:0] child;          // "CHILD"
    wire [48:0] sum_p;          // "SUM_P"
    wire [48:0] sum_e;          // "SUM_E"
    wire [48:0] period;         // "PERIOD:"
    reg [255:0] data_raw;
    reg [15:0] data_in [24:0]; // 16-bit data input
    wire [48:0] data_out [24:0]; // 49-bit ASCII output


    reg [6:0] result;

    // Assignments for ASCII characters
    assign men = {7'h4D, 7'h45, 7'h4E, BLANK, BLANK, BLANK, BLANK};       // "MEN"
    assign women = {7'h57, 7'h4F, 7'h4D, 7'h45, 7'h4E, BLANK, BLANK};     // "WOMEN"
    assign elderly = {7'h45, 7'h4C, 7'h44, 7'h45, 7'h52, 7'h4C, 7'h59};   // "ELDERLY"
    assign child = {7'h43, 7'h48, 7'h49, 7'h4C, 7'h44, BLANK, BLANK};     // "CHILD"
    assign sum_p = {7'h53, 7'h55, 7'h4D, 7'h2D, 7'h50, BLANK, BLANK};     // "SUM_P"
    assign sum_e = {BLANK, BLANK, 7'h53, 7'h55, 7'h4D, 7'h2D, 7'h45};     // "SUM_E"
    assign period = {7'h50, 7'h45, 7'h52, 7'h49, 7'h4F, 7'h44, 7'h3A};    // "PERIOD:"

    // Predefined column positions
    integer col_pos[6:0];
    integer i, j, row;

    initial begin
        // Calculate column positions
        col_pos[0] = COL_START;
        for (i = 1; i <= 6; i = i + 1) begin
            // col_pos[i] = col_pos[i - 1] + (CHAR_SIZE * (i == 1 ? 7 : 4));
            col_pos[i] = col_pos[i - 1] + (CHAR_SIZE * 7);
        end

        data_raw = {16'd0000, 16'd0001, 16'd0002, 16'd0003, 16'd0004, 16'd0005, 16'd0006, 16'd0007, 16'd0008, 16'd0009, 16'd0010, 16'd0011, 16'd0012, 16'd0013, 16'd0014, 16'd0015};

        for (i = 16; i < 25; i = i + 1) begin
            data_in[i] = 16'd0;
        end

        for (i = 0; i < 16; i = i + 1) begin
            data_in[i] = data_raw[255 - (i * 16) -: 16];
            
            if (i <= 3)
                data_in[20] = data_in[20] + data_in[i];
            else if (i <= 7)
                data_in[21] = data_in[21] + data_in[i];
            else if (i <= 11)
                data_in[22] = data_in[22] + data_in[i];
            else if (i <= 15)
                data_in[23] = data_in[23] + data_in[i];

            if ( i == 0 || i == 4 || i == 8 || i == 12)
                data_in[16] = data_in[16] + data_in[i];
            else if ( i == 1 || i == 5 || i == 9 || i == 13)
                data_in[17] = data_in[17] + data_in[i];
            else if ( i == 2 || i == 6 || i == 10 || i == 14)
                data_in[18] = data_in[18] + data_in[i];
            else if ( i == 3 || i == 7 || i == 11 || i == 15)
                data_in[19] = data_in[19] + data_in[i];
        end

        data_in[24] = data_in[16] + data_in[17] + data_in[18] + data_in[19];

        // assign data_in[0] = 16'd9999;
        // assign data_in[1] = 16'd8888;
        // assign data_in[2] = 16'd7777;
        // assign data_in[3] = 16'd6666;
        // assign data_in[4] = 16'd5555;
        // assign data_in[5] = 16'd4444;
        // assign data_in[6] = 16'd3333;
        // assign data_in[7] = 16'd2222;
        // assign data_in[8] = 16'd1111;
        // assign data_in[9] = 16'd1234;
        // assign data_in[10] = 16'd5678;
        // assign data_in[11] = 16'd9876;
        // assign data_in[12] = 16'd5432;
        // assign data_in[13] = 16'd8765;
        // assign data_in[14] = 16'd4321;
        // assign data_in[15] = 16'd6543;
        // assign data_in[16] = 16'd7890;
        // assign data_in[17] = 16'd3456;
        // assign data_in[18] = 16'd6789;
        // assign data_in[19] = 16'd2109;
        // assign data_in[20] = 16'd1092;
        // assign data_in[21] = 16'd0921;
        // assign data_in[22] = 16'd9210;
        // assign data_in[23] = 16'd0000;
        // assign data_in[24] = 16'd12345;

    end

    genvar k;
    for (k = 0; k < 25; k = k + 1) begin
       binarytoasciihex b2(.input_val(data_in[k]), .packed_val(data_out[k]));
    end
    
    // binarytoasciihex b2a(.input_val(16'd9999), .packed_val(data_out[0]));
    // binarytoasciihex b2b(.input_val(16'd8888), .packed_val(data_out[1]));
    // binarytoasciihex b2c(.input_val(16'd7777), .packed_val(data_out[2]));
    // binarytoasciihex b2d(.input_val(16'd6666), .packed_val(data_out[3]));
    // binarytoasciihex b2e(.input_val(16'd5555), .packed_val(data_out[4]));
    // binarytoasciihex b2f(.input_val(16'd4444), .packed_val(data_out[5]));
    // binarytoasciihex b2g(.input_val(16'd3333), .packed_val(data_out[6]));
    // binarytoasciihex b2h(.input_val(16'd2222), .packed_val(data_out[7]));
    // binarytoasciihex b2i(.input_val(16'd1111), .packed_val(data_out[8]));
    // binarytoasciihex b2j(.input_val(16'd1234), .packed_val(data_out[9]));
    // binarytoasciihex b2k(.input_val(16'd5678), .packed_val(data_out[10]));
    // binarytoasciihex b2l(.input_val(16'd9876), .packed_val(data_out[11]));
    // binarytoasciihex b2m(.input_val(16'd5432), .packed_val(data_out[12]));
    // binarytoasciihex b2n(.input_val(16'd8765), .packed_val(data_out[13]));
    // binarytoasciihex b2o(.input_val(16'd4321), .packed_val(data_out[14]));
    // binarytoasciihex b2p(.input_val(16'd6543), .packed_val(data_out[15]));
    // binarytoasciihex b2q(.input_val(16'd7890), .packed_val(data_out[16]));
    // binarytoasciihex b2r(.input_val(16'd3456), .packed_val(data_out[17]));
    // binarytoasciihex b2s(.input_val(16'd6789), .packed_val(data_out[18]));
    // binarytoasciihex b2t(.input_val(16'd2109), .packed_val(data_out[19]));
    // binarytoasciihex b2u(.input_val(16'd1092), .packed_val(data_out[20]));
    // binarytoasciihex b2v(.input_val(16'd0921), .packed_val(data_out[21]));
    // binarytoasciihex b2w(.input_val(16'd9210), .packed_val(data_out[22]));
    // binarytoasciihex b2x(.input_val(16'd0000), .packed_val(data_out[23]));
    // binarytoasciihex b2y(.input_val(16'd12345), .packed_val(data_out[24]));





    function [6:0] get_ascii_from_text(
        input [10:0] x,             // Current x position
        input [10:0] col_start,     // Start position of the column
        input integer CHAR_SIZE,    // Character width
        input [48:0] text           // 49-bit ASCII text to extract
    );
        integer i;                  // Loop variable
        reg [6:0] result;           // ASCII character result
        begin
            result = 7'h20;         // Default to blank space
            for (i = 0; i < 7; i = i + 1) begin
                if (x >= col_start + i * CHAR_SIZE && x < col_start + (i + 1) * CHAR_SIZE) begin
                    result = text[48 - (i * 7) -: 7]; // Extract 7 bits for the current character
                end
            end
            get_ascii_from_text = result;
        end
    endfunction

    // Determine ASCII character based on x position
    always @* begin
        ascii_char = BLANK;  // Default to blank space

        // --> Line 1
        if (y >= (ROW_START) && y < (ROW_START + ROW_HEIGHT)) begin

            if (x >= col_pos[0] && x < col_pos[1])
                ascii_char = get_ascii_from_text(x, col_pos[0], CHAR_SIZE, period); // "PERIOD:"

            
            else if (x >= col_pos[1] && x < col_pos[5]) begin
                for (i = 1; i <= 4; i = i + 1) begin
                    for (j = 0; j < 7; j = j + 1) begin
                        if (x >= col_pos[i] + j * CHAR_SIZE && x < col_pos[i] + (j + 1) * CHAR_SIZE) begin
                            ascii_char = (j == 5 ? 7'h30 + i : 7'h20);  // ASCII for "1", "2", "3", "4"
                        end
                    end
                end
            end

            else if (x >= col_pos[5] && x < col_pos[6])
                ascii_char = get_ascii_from_text(x, col_pos[5], CHAR_SIZE, sum_e); // "SUM_E"

        end

        // partition the rest of the screen
        

        // --> Line 2
        else if (y >= (ROW_START + 2 * ROW_HEIGHT) && y < (ROW_START + 3 * ROW_HEIGHT)) begin
            if (x >= col_pos[0] && x < col_pos[1])
                ascii_char = get_ascii_from_text(x, col_pos[0], CHAR_SIZE, men);
            if (x >= col_pos[1] && x < col_pos[2])
                ascii_char = get_ascii_from_text(x, col_pos[1], CHAR_SIZE, data_out[0]);
            if (x >= col_pos[2] && x < col_pos[3])
                ascii_char = get_ascii_from_text(x, col_pos[2], CHAR_SIZE, data_out[1]);
            if (x >= col_pos[3] && x < col_pos[4])
                ascii_char = get_ascii_from_text(x, col_pos[3], CHAR_SIZE, data_out[2]);
            if (x >= col_pos[4] && x < col_pos[5])
                ascii_char = get_ascii_from_text(x, col_pos[4], CHAR_SIZE, data_out[3]);
            if (x >= col_pos[5] && x < col_pos[6])
                ascii_char = get_ascii_from_text(x, col_pos[5], CHAR_SIZE, data_out[20]);
            
        end

        // --> Line 3
        else if (y >= (ROW_START + 4 * ROW_HEIGHT) && y < (ROW_START + 5 * ROW_HEIGHT)) begin
            if (x >= col_pos[0] && x < col_pos[1])
                ascii_char = get_ascii_from_text(x, col_pos[0], CHAR_SIZE, women); // "women"
            if (x >= col_pos[1] && x < col_pos[2])
                ascii_char = get_ascii_from_text(x, col_pos[1], CHAR_SIZE, data_out[4]);
            if (x >= col_pos[2] && x < col_pos[3])
                ascii_char = get_ascii_from_text(x, col_pos[2], CHAR_SIZE, data_out[5]);
            if (x >= col_pos[3] && x < col_pos[4])
                ascii_char = get_ascii_from_text(x, col_pos[3], CHAR_SIZE, data_out[6]);
            if (x >= col_pos[4] && x < col_pos[5])
                ascii_char = get_ascii_from_text(x, col_pos[4], CHAR_SIZE, data_out[7]);
            if (x >= col_pos[5] && x < col_pos[6])
                ascii_char = get_ascii_from_text(x, col_pos[5], CHAR_SIZE, data_out[21]);
        end

        // --> Line 4
        else if (y >= (ROW_START + 6 * ROW_HEIGHT) && y < (ROW_START + 7 * ROW_HEIGHT)) begin
            if (x >= col_pos[0] && x < col_pos[1])
                ascii_char = get_ascii_from_text(x, col_pos[0], CHAR_SIZE, elderly); // "elderly"
            if (x >= col_pos[1] && x < col_pos[2])
                ascii_char = get_ascii_from_text(x, col_pos[1], CHAR_SIZE, data_out[8]);
            if (x >= col_pos[2] && x < col_pos[3])
                ascii_char = get_ascii_from_text(x, col_pos[2], CHAR_SIZE, data_out[9]);
            if (x >= col_pos[3] && x < col_pos[4])
                ascii_char = get_ascii_from_text(x, col_pos[3], CHAR_SIZE, data_out[10]);
            if (x >= col_pos[4] && x < col_pos[5])
                ascii_char = get_ascii_from_text(x, col_pos[4], CHAR_SIZE, data_out[11]);
            if (x >= col_pos[5] && x < col_pos[6])
                ascii_char = get_ascii_from_text(x, col_pos[5], CHAR_SIZE, data_out[22]);
        end

        // --> Line 5
        else if (y >= (ROW_START + 8 * ROW_HEIGHT) && y < (ROW_START + 9 * ROW_HEIGHT)) begin
            if (x >= col_pos[0] && x < col_pos[1])
                ascii_char = get_ascii_from_text(x, col_pos[0], CHAR_SIZE, child); // "child"
            if (x >= col_pos[1] && x < col_pos[2])
                ascii_char = get_ascii_from_text(x, col_pos[1], CHAR_SIZE, data_out[12]);
            if (x >= col_pos[2] && x < col_pos[3])
                ascii_char = get_ascii_from_text(x, col_pos[2], CHAR_SIZE, data_out[13]);
            if (x >= col_pos[3] && x < col_pos[4])
                ascii_char = get_ascii_from_text(x, col_pos[3], CHAR_SIZE, data_out[14]);
            if (x >= col_pos[4] && x < col_pos[5])
                ascii_char = get_ascii_from_text(x, col_pos[4], CHAR_SIZE, data_out[15]);
            if (x >= col_pos[5] && x < col_pos[6])
                ascii_char = get_ascii_from_text(x, col_pos[5], CHAR_SIZE, data_out[23]);
        end

        // --> Line 6
        else if (y >= (ROW_START + 10 * ROW_HEIGHT) && y < (ROW_START + 11 * ROW_HEIGHT)) begin
            // Display "Sum_P"
            if (x >= col_pos[0] && x < col_pos[1])
                ascii_char = get_ascii_from_text(x, col_pos[0], CHAR_SIZE, sum_p); // "sum_p"
            if (x >= col_pos[1] && x < col_pos[2])
                ascii_char = get_ascii_from_text(x, col_pos[1], CHAR_SIZE, data_out[16]);
            if (x >= col_pos[2] && x < col_pos[3])
                ascii_char = get_ascii_from_text(x, col_pos[2], CHAR_SIZE, data_out[17]);
            if (x >= col_pos[3] && x < col_pos[4])
                ascii_char = get_ascii_from_text(x, col_pos[3], CHAR_SIZE, data_out[18]);
            if (x >= col_pos[4] && x < col_pos[5])
                ascii_char = get_ascii_from_text(x, col_pos[4], CHAR_SIZE, data_out[19]);
            if (x >= col_pos[5] && x < col_pos[6]) begin
                ascii_char = get_ascii_from_text(x, col_pos[5], CHAR_SIZE, data_out[24]);
            end
        end

        else
            ascii_char = BLANK;  // Default to blank space
    end


    // ASCII bit on/off determination
    assign ascii_bit_on = ((x >= col_pos[0] && x < col_pos[6]) && (y >= ROW_START && y < (ROW_START + 11 * ROW_HEIGHT))) ? ascii_bit : 1'b0;

    // RGB multiplexing circuit
    always @* begin
        if (~video_on)
            rgb = 12'h000;      // Blank
        else if (ascii_bit_on)
            rgb = 12'h0F0;      // Green letters
        else
            rgb = 12'h000;      // Dark background
    end
endmodule

