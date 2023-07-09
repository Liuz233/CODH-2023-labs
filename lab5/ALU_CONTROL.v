`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/01 11:43:57
// Design Name: 
// Module Name: ALU_CONTROL
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


module ALU_CONTROL(
    input [6:0] ALUOP,
    input [31:0] IR,
    output reg [2:0] f
    );
    localparam [6:0]    OP=7'b0110011,
                        OPIMM=7'b0010011,
                        LUI=7'b0110111,
                        AUIPC=7'b0010111,
                        LOAD=7'b0000011,
                        STORE=7'b0100011,
                        BRANCH=7'b1100011,
                        JAL=7'b1101111,
                        JALR=7'b1100111;
    always@(*)
    begin
        f=3'b000;
        case(ALUOP)
            OP:begin
                if(IR[14:12]==3'b000&&IR[31:25]==7'b0000000) f=3'b001;//add
                else if(IR[14:12]==3'b111) f=3'b010;//and
                else if(IR[14:12]==3'b110) f=3'b011;//or
                else if(IR[14:12]==3'b100) f=3'b100;//xor
                else if(IR[14:12]==3'b000&&IR[31:25]==7'b0100000) f=3'b000;//sub
            end
            OPIMM:begin
                if(IR[14:12]==3'b000) f=3'b001;//addi
                else if(IR[14:12]==3'b001) f=3'b110;//slli
                else if(IR[14:12]==3'b101&&IR[31:25]==7'b0000000) f=3'b101;//srli
                else if(IR[14:12]==3'b101&&IR[31:25]==7'b0100000) f=3'b111;//srai
            end
            LUI:begin
                f=3'b001;//lui
            end
            AUIPC:begin
                f=3'b001;//auipc
            end
            LOAD:begin
                f=3'b001;//lw
            end
            STORE:begin
                f=3'b001;//sw
            end
            BRANCH:begin
                f=3'b000;//beq,blt,bltu
            end
            JAL:begin
                f=3'b000;//jal,useless
            end
            JALR:begin
                f=3'b001;//jalr
            end
            default:begin
                f=3'b001;
            end
        endcase
    end
endmodule
