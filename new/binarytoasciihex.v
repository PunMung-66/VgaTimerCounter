`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 04:48:16 PM
// Design Name: 
// Module Name: binarytoasciihex
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module binarytoasciihex (
    input [15:0] input_val,  // 16-bit input value
    output [48:0] packed_val // 49-bit packed output
);
    // Define 7-bit ASCII values for digits and space
    wire [6:0] digit0, digit1, digit2, digit3, digit4, digit5, digit6;
    wire [6:0] space = 7'h20;  // Blank space (ASCII 0x20)

    // Convert the 16-bit input value to its ASCII equivalent digits
    assign digit6 = (input_val >= 100000) ? (input_val / 100000) + 7'h30 : space; // First digit (hundreds of thousands)
    assign digit5 = (input_val >= 10000)  ? ((input_val / 10000) % 10) + 7'h30 : space;  // Second digit (ten-thousands)
    assign digit4 = (input_val >= 1000)   ? ((input_val / 1000) % 10) + 7'h30 : space;  // Third digit (thousands)
    assign digit3 = (input_val >= 100)    ? ((input_val / 100) % 10) + 7'h30 : space;  // Fourth digit (hundreds)
    assign digit2 = (input_val >= 10)     ? ((input_val / 10) % 10) + 7'h30 : space;   // Fifth digit (tens)
    assign digit1 = input_val % 10 + 7'h30; // Last digit (ones)

    // Fill remaining position with space if fewer than 7 digits
    assign digit0 = space;  // Padding

    // Pack the digits in reverse order to ensure the most significant digit is on the left
    assign packed_val = {digit6, digit5, digit4, digit3, digit2, digit1, digit0}; // Concatenate in reverse order for most significant first

endmodule

