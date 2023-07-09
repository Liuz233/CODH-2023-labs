`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:45:48
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    input clk,
    // 控制信号
    input RegWrite_in,
    input [1:0] RegSrc_in,
    input MemWrite_in,
    input Jmp_in,
    output reg RegWrite_out,
    output reg [1:0] RegSrc_out,
    output reg MemWrite_out,
    output reg Jmp_out,
    // 其他寄存器
    input [31:0] pc_plus_in,
    input [31:0] ir_in,
    input [31:0] aluresult_in,
    input [31:0] R2_in,
    input [4:0] rdidx_in,
    input pc_choice_in,
    output reg [31:0] pc_plus_out,
    output reg [31:0] ir_out,
    output reg [31:0] aluresult_out,
    output reg [31:0] R2_out,
    output reg [4:0] rdidx_out,
    output reg pc_choice_out,

    input clear,
    input enable
    );
    always @(posedge clk) begin
        if(clear) begin
            RegWrite_out <= 0;
            RegSrc_out <= 1;
            MemWrite_out <= 0;
            Jmp_out <= 0;
            pc_plus_out <= 0;
            ir_out <= 0;
            aluresult_out <= 0;
            R2_out <= 0;
            rdidx_out <= 0;
            pc_choice_out <= 0;
        end
        else begin
            if(enable) begin
                RegWrite_out <= RegWrite_in;
                RegSrc_out <= RegSrc_in;
                MemWrite_out <= MemWrite_in;
                Jmp_out <= Jmp_in;
                pc_plus_out <= pc_plus_in;
                ir_out <= ir_in;
                aluresult_out <= aluresult_in;
                R2_out <= R2_in;
                rdidx_out <= rdidx_in;
                pc_choice_out <= pc_choice_in;
            end
            else begin
                RegWrite_out <= RegWrite_out;
                RegSrc_out <= RegSrc_out;
                MemWrite_out <= MemWrite_out;
                Jmp_out <= Jmp_out;
                pc_plus_out <= pc_plus_out;
                ir_out <= ir_out;
                R2_out <= R2_out;
                rdidx_out <= rdidx_out;
                pc_choice_out <= pc_choice_out;
            end
        end

    end
endmodule
