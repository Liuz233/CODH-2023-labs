`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:45:36
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
    input clk,
    // 控制信号
    input RegWrite_in,
    input [1:0] RegSrc_in,
    input MemRead_in,
    input MemWrite_in,
    input Jmp_in,
    input [1:0] BranchState_in,
    input [1:0] ASrc_in,
    input BSrc_in,
    input [2:0] ALUOp_in,
    output reg RegWrite_out,
    output reg [1:0] RegSrc_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg Jmp_out,
    output reg [1:0] BranchState_out,
    output reg [1:0] ASrc_out,
    output reg BSrc_out,
    output reg [2:0] ALUOp_out,

    // 其他寄存器
    input [31:0] pc_in,
    input [31:0] pc_plus_in,
    input [31:0] ir_in,
    input [31:0] R1_in,
    input [31:0] R2_in,
    input [4:0] R1idx_in,
    input [4:0] R2idx_in,
    input [31:0] imm_in,
    input [4:0] rdidx_in,
    input [6:0] opcode_in,
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus_out,
    output reg [31:0] ir_out,
    output reg [31:0] R1_out,
    output reg [31:0] R2_out,
    output reg [31:0] imm_out,
    output reg [4:0] R1idx_out,
    output reg [4:0] R2idx_out,
    output reg [4:0] rdidx_out,
    output reg [6:0] opcode_out,

    input clear,
    input enable
    );
    always @(posedge clk) begin
        if(clear) begin
            RegWrite_out <= 0;
            RegSrc_out <= 1;
            MemRead_out <= 0;
            MemWrite_out <= 0;
            Jmp_out <= 0;
            BranchState_out <= 0;
            ASrc_out <= 1;
            BSrc_out <= 0;
            ALUOp_out <= 1;
            pc_out <= 0;
            pc_plus_out <= 0;
            ir_out <= 0;
            R1_out <= 0;
            R2_out <= 0;
            imm_out <= 0;
            R1idx_out <= 0;
            R2idx_out <= 0;
            rdidx_out <= 0;
            opcode_out <= 0;
        end
        else begin
            if(enable) begin
                RegWrite_out <= RegWrite_in;
                RegSrc_out <= RegSrc_in;
                MemRead_out <= MemRead_in;
                MemWrite_out <= MemWrite_in;
                Jmp_out <= Jmp_in;
                BranchState_out <= BranchState_in;
                ASrc_out <= ASrc_in;
                BSrc_out <= BSrc_in;
                ALUOp_out <= ALUOp_in;
                pc_out <= pc_in;
                pc_plus_out <= pc_plus_in;
                ir_out <= ir_in;
                R1_out <= R1_in;
                R2_out <= R2_in;
                imm_out <= imm_in;
                R1idx_out <= R1idx_in;
                R2idx_out <= R2idx_in;
                rdidx_out <= rdidx_in;
                opcode_out <= opcode_in;
            end
            else begin
                RegWrite_out <= RegWrite_out;
                RegSrc_out <= RegSrc_out;
                MemRead_out <= MemRead_out;
                MemWrite_out <= MemWrite_out;
                Jmp_out <= Jmp_out;
                BranchState_out <= BranchState_out;
                ASrc_out <= ASrc_out;
                BSrc_out <= BSrc_out;
                ALUOp_out <= ALUOp_out;
                pc_out <= pc_out;
                pc_plus_out <= pc_plus_out;
                ir_out <= ir_out;
                R1_out <= R1_out;
                R2_out <= R2_out;
                imm_out <= imm_out;
                R1idx_out <= R1idx_out;
                R2idx_out <= R2idx_out;
                rdidx_out <= rdidx_out;
                opcode_out <= opcode_out;
            end
        end
    end
endmodule
