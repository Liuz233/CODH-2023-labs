`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 08:18:13
// Design Name: 
// Module Name: test_DPE
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


module test_DPE(
    input clk,
    input rstn,
    input [15:0] sw,
    input btnr,
    input btnc,
    output A,B,C,D,E,F,G,
    output [7:0] AN
    );
    wire [31:0] data_out;
    sw_DPE DPE_test_inst(
        .clk (clk),
        .rstn (rstn),
        .sw (sw),
        .btnr (btnr),
        .btnc (btnc),
        .data_out (data_out)
    );
    hex32_convert hex_out(
        .clk (clk),
        .data_in (data_out),
        .A (A),
        .B (B),
        .C (C),
        .D (D),
        .E (E),
        .F (F),
        .G (G),
        .AN (AN)
    );
endmodule
