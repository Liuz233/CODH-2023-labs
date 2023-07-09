`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:44:48
// Design Name: 
// Module Name: Forwarding
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


module Forwarding(
    input [4:0] EX_R1idx,
    input [4:0] EX_R2idx,
    input [4:0] MEM_rdidx,
    input [4:0] WB_rdidx,
    input MEM_RegWrite,
    input WB_RegWrite,
    output reg [1:0] ALU_A_forward,
    output reg [1:0] ALU_B_forward
    );
    always @(*) begin
        if(EX_R1idx == MEM_rdidx && MEM_RegWrite == 1)begin
            ALU_A_forward = 2;
        end
        else if(EX_R1idx == WB_rdidx && WB_RegWrite == 1) begin
            ALU_A_forward = 0;
        end
        else begin
            ALU_A_forward = 1;
        end

        if (EX_R2idx == MEM_rdidx && MEM_RegWrite == 1) begin
            ALU_B_forward = 2;
        end
        else if (EX_R2idx == WB_rdidx && WB_RegWrite == 1) begin
            ALU_B_forward = 0;
        end
        else begin
            ALU_B_forward = 1; 
        end

    end
endmodule
