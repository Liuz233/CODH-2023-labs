`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 07:53:09
// Design Name: 
// Module Name: DP
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


module DP_upper(
    input clk,
    input button,
    output button_edge
    );
    wire button_clean;
    jitter_clr clean_inst(
        .clk (clk),
        .button(button),
        .button_clean (button_clean)
    );
    upper_edge edge_inst(
        .clk (clk),
        .button(button),
        .button_edge (button_edge)
    );
endmodule
module DP_double(
    input clk,
    input button,
    output button_edge
    );
    wire button_clean;
    jitter_clr clean_inst(
        .clk (clk),
        .button(button),
        .button_clean (button_clean)
    );
    double_edge edge_inst(
        .clk (clk),
        .button(button),
        .button_edge (button_edge)
    );
endmodule