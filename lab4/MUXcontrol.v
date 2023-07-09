`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/02 11:58:20
// Design Name: 
// Module Name: MUXcontrol
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


module MUXcontrol(
    input [1:0] MemtoReg,
    input mmio,
    output reg [1:0] sel
    );  
    always@(*)
    begin
        if(mmio) sel=2'b10;
        else if(MemtoReg==2'b00) sel=2'b00;
        else if(MemtoReg==2'b01) sel=2'b01;
        else if(MemtoReg==2'b10) sel=2'b11;
        else sel=2'b00;
    end
endmodule
