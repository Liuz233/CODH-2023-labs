`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/09 11:49:21
// Design Name: 
// Module Name: RF
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


module RF(
    input clk,
    input [4:0] ra1,ra2,
    output reg [31:0] rd1,rd2,
    input [4:0] wa,
    input [31:0] wd,
    input we
    );
    reg [31:0] rf[0:31];
    always @(posedge clk)
     if(we && wa!=32'b0) rf[wa]<=wd;//同步写，且不写rf[0]
    always@(*)
    begin
        if(ra1==0) rd1=0;//读rf[0]输出0
        else rd1=rf[ra1];
        if(ra2==0) rd2=0;
        else rd2=rf[ra2];
    end
endmodule
