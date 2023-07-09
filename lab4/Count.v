`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/30 16:28:11
// Design Name: 
// Module Name: Count
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


module Count(
    input clk,
    input en,
    input [31:0] init,
    input clear,
    output reg [31:0] Q
    );
    always@(posedge clk) 
    begin
        if(clear)
            Q<=init;
        else if(en)
            Q<=Q+1;
        else Q<=Q;
    end
endmodule