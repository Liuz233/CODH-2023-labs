`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/02 14:37:52
// Design Name: 
// Module Name: Branchcontrol
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


module Branchcontrol(
    input [2:0] zero,
    input [2:0] Branch,
    output reg sel
    );
    always@(*)
    begin
        if(Branch==3'b100) sel=1;
        else if(Branch==3'b001&&zero[0]) sel=1;
        else if(Branch==3'b010&&zero[1]) sel=1;
        else if(Branch==3'b011&&zero[2]) sel=1;
        else sel=0;
    end
endmodule
