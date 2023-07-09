`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/21 13:35:44
// Design Name: 
// Module Name: ForwardingUnit
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


module ForwardingUnit(
    input EX_MEM_WE,
    input [4:0] EX_MEM_RD,
    input MEM_WB_WE,
    input [4:0] MEM_WB_RD,
    input [4:0] rs1,
    input [4:0] rs2,
    output reg [1:0] SSrcA,
    output reg [1:0] SSrcB
    );
    always@(*)
    begin
        if(EX_MEM_WE && EX_MEM_RD != 5'b0 && rs1==EX_MEM_RD)
            SSrcA=2'b01;
        else if(MEM_WB_WE && MEM_WB_RD != 5'b0 && rs1==MEM_WB_RD)
            SSrcA=2'b10;
        else 
            SSrcA=2'b00;

        if(EX_MEM_WE && EX_MEM_RD != 5'b0 && rs2==EX_MEM_RD)
            SSrcB=2'b01;
        else if(MEM_WB_WE && MEM_WB_RD != 5'b0 && rs2==MEM_WB_RD)
            SSrcB=2'b10;
        else 
            SSrcB=2'b00;
    end
endmodule
