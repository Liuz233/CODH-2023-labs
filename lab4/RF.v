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
    input [4:0] ra1,ra2,ra0,
    output reg [31:0] rd1,rd2,rd0,
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
        else if(ra1==2) rd1=32'h2ffc;
        else rd1=rf[ra1];
        if(ra2==0) rd2=0;
        else if(ra2==2) rd2=32'h2ffc;
        else rd2=rf[ra2];
        if(ra0==0) rd0=0;
        else if(ra0==2) rd0=32'h2ffc;
        else rd0=rf[ra0];
    end
endmodule
