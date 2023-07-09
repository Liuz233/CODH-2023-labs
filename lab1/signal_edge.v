`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 11:22:45
// Design Name: 
// Module Name: signal_edge
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


module signal_edge(
    input clk,
    input button,
    output button_edge
);
    wire button_clean;
     jitter_clr jt(
         .clk(clk),
         .button(button),
         .button_clean(button_clean)
     );
    reg button_r1,button_r2;
    always@(posedge clk)
    button_r1 <= button_clean;
    always@(posedge clk)
    button_r2 <= button_r1;
    assign button_edge = button_r1 & (~button_r2);
endmodule
