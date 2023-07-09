`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:42:03
// Design Name: 
// Module Name: Control
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


module Control(
    input [31:0] ir,
    output reg RegWrite,
    output reg [1:0] RegSrc,
    output reg MemRead,
    output reg MemWrite,
    //output [3:0] MemOp,
    output reg Jmp,
    output reg [1:0] BranchState,
    output reg [1:0] ASrc,
    output reg BSrc,
    output reg [2:0] ALUOp,
    output reg [2:0] ImmGenWay
    );
    wire [6:0] opcode;
    wire [7:0] diff;
    wire [2:0] func;
    assign opcode = ir[6:0];
    assign func = ir[14:12];
    assign diff = ir[31:25];
    always @(*) begin
        //add, sub, and, or, xor
        if(opcode == 7'b0110011) begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 0;
            ASrc = 1;
            BSrc = 1;
            ImmGenWay = 0;
            RegWrite = 1;
            Jmp = 0;
            RegSrc = 1;
            //mmio = 0;
            if(func == 3'b000) begin    //add & sub
                if(diff == 0) begin //add
                    ALUOp = 1;
                end
                else begin          //sub
                    ALUOp = 0;
                end
            end
            else if (func == 3'b111) begin  //and
                ALUOp = 2;
            end
            else if (func == 3'b110) begin  //or
                ALUOp = 3;
            end
            else if (func == 3'b100) begin  //xor
                ALUOp = 4;
            end
            else begin
                ALUOp = 0;
            end
        end
        //addi, slli, srli, srai
        else if (opcode == 7'b0010011) begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 0;
            ASrc = 1;
            BSrc = 0;
            RegWrite = 1;
            Jmp = 0;
            RegSrc = 1;
            //mmio = 0;
            if(func == 3'b000) begin    //addi
                ImmGenWay = 0;
                ALUOp = 1;
            end
            else if(func == 3'b001) begin   //slli
                ImmGenWay = 5;
                ALUOp = 6;
            end
            else if(func == 3'b101) begin
                ImmGenWay = 5;
                if(diff == 0) begin //srli
                    ALUOp = 5;
                end
                else begin      //srai
                    ALUOp = 7;
                end
            end
            else begin
                ALUOp = 0;
                ImmGenWay = 0;
            end
        end
        //auipc
        else if (opcode == 7'b0010111) begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 0;
            ASrc = 0;
            BSrc = 0;
            ImmGenWay = 1;
            RegWrite = 1;
            ALUOp = 1;
            Jmp = 0;
            RegSrc = 1;
        end
        //lui
        else if (opcode == 7'b0110111) begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 0;
            ASrc = 2;
            BSrc = 0;
            ImmGenWay = 1;
            RegWrite = 1;
            ALUOp = 1;
            Jmp = 0;
            RegSrc = 1;
            //mmio = 0;
        end
        //lw
        else if (opcode == 7'b0000011) begin
            BranchState = 0;
            MemRead = 1;
            MemWrite = 0;
            ASrc = 1;
            BSrc = 0;
            ImmGenWay = 0;
            RegWrite = 1;
            ALUOp = 1;
            Jmp = 0;
            RegSrc = 2;
        end
        //sw
        else if (opcode == 7'b0100011) begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 1;
            ASrc = 1;
            BSrc = 0;
            ImmGenWay = 2;
            RegWrite = 0;
            ALUOp = 1;
            Jmp = 0;
            RegSrc = 1;
        end
        //beq blt bltu
        else if (opcode == 7'b1100011) begin
            MemRead = 0;
            MemWrite = 0;
            ASrc = 1;
            BSrc = 1;
            ImmGenWay = 3;
            RegWrite = 0;
            ALUOp = 0;
            Jmp = 0;
            RegSrc = 1;
            if(func == 3'b000) begin    //beq
                BranchState = 1;
            end
            else if (func == 3'b100) begin  //blt
                BranchState = 2;
            end
            else begin                  //bltu
                BranchState = 3;
            end
        end
        //jal
        else if (opcode == 7'b1101111) begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 0;
            ASrc = 0;
            BSrc = 0;
            ImmGenWay = 4;
            RegWrite = 1;
            ALUOp = 1;
            Jmp = 1;
            RegSrc = 2;
        end
        //jalr
        else if(opcode == 7'b1100111)begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 0;
            ASrc = 1;
            BSrc = 0;
            ImmGenWay = 0;
            RegWrite = 1;
            ALUOp = 1;
            Jmp = 1;
            RegSrc = 2;
        end
        else begin
            BranchState = 0;
            MemRead = 0;
            MemWrite = 0;
            ASrc = 1;
            BSrc = 0;
            ImmGenWay = 0;
            RegWrite = 0;
            ALUOp = 1;
            Jmp = 0;
            RegSrc = 1;
        end
    end
endmodule
