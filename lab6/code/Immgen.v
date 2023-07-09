`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/30 17:57:01
// Design Name: 
// Module Name: Immgen
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


module Immgen(
    input [6:0] ImmGen,
    input [31:0] IR,
    output reg [31:0] Imm
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
        case(ImmGen)
            OP:begin//add,sub,and,or,xor
                Imm=32'b0;
            end
            OPIMM:begin
                if(IR[14:12]==3'b000) Imm={{20{IR[31]}},IR[31:20]};//addi
                else  Imm={{27'b0},IR[24:20]};//srai,slli,srli
            end
            LUI:begin//lui
                Imm={IR[31:12],12'b0};
            end
            AUIPC:begin//auipc
                Imm={IR[31:12],12'b0};
            end
            LOAD:begin//lw
                Imm={{20{IR[31]}},IR[31:20]};
            end
            STORE:begin//sw
                Imm = {{20{IR[31]}}, IR[31:25], IR[11:7]};
            end
            BRANCH:begin//beq,blt,bltu
                Imm = {{20{IR[31]}}, IR[31], IR[7], IR[30:25], IR[11:8]};
            end
            JAL:begin//jal
                Imm = {{12{IR[31]}}, IR[31], IR[19:12], IR[20], IR[30:21]};
            end
            JALR:begin  //jalr
                Imm = {{20{IR[31]}}, IR[31:20]};
            end
            default:begin
                Imm = 32'b0;
            end
        endcase
    end
endmodule
