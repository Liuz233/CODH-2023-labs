`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/21 13:36:03
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(
    input [31:0] IR,
    input [31:0] IRd,
    output reg ctrl,
    output reg PCWrite,
    output reg IF_ID_Write
);
    always@(*) begin
        if (IRd[6:0] == 7'b0000011 && (IRd[11:7] == IR[19:15] || IRd[11:7] == IR[24:20])) begin
            PCWrite = 1'b0;//PCstall
            IF_ID_Write = 1'b0;//dStall
            ctrl = 1'b1;//eFlush
        end
        else begin
            PCWrite = 1'b1;
            IF_ID_Write = 1'b1;
            ctrl = 1'b0;
        end
    end
endmodule
