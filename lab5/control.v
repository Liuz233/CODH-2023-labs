`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/01 11:02:49
// Design Name: 
// Module Name: control
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


module control(
    input [31:0] IR,
    input [6:0] inst,
    output reg [5:0] EX,//SrcA[1:0],SrcB,f[2:0]
    output reg M,//MemWrite
    output reg [2:0] WB,//MUXSrc3[1:0],we,
    output reg [2:0] Branch
    );
    wire [2:0] f;
    localparam [6:0]    OP=7'b0110011,
                        OPIMM=7'b0010011,
                        LUI=7'b0110111,
                        AUIPC=7'b0010111,
                        LOAD=7'b0000011,
                        STORE=7'b0100011,
                        BRANCH=7'b1100011,
                        JAL=7'b1101111,
                        JALR=7'b1100111;
    ALU_CONTROL  u_ALU_CONTROL (
        .ALUOP                   (inst),
        .IR                      ( IR ),
        .f                       ( f )
    );
    always@(*)
    begin
        EX = 6'b0;
        M = 1'b0;
        WB = 3'b0;
        Branch = 3'b00;
        case(inst)
            OP:begin
                EX = {{3'b000},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            OPIMM:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            LUI:begin
                EX = {{3'b101},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            AUIPC:begin
                EX = {{3'b011},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            LOAD:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b0;   
                WB = 3'b011;
            end
            STORE:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b1;
                WB = 3'b000;
            end
            BRANCH:begin
                EX = {{3'b000},f[2:0]};//rs1-rs2
                M = 1'b0;
                WB = 3'b000;
                if(IR[14:12]==3'b000) Branch=3'b001;//beq
                else if(IR[14:12]==3'b100) Branch=3'b010;//blt
                else if(IR[14:12]==3'b110) Branch=3'b011;//bltu
            end
            JAL:begin
                EX = {{3'b000},f[2:0]};//不需要alu
                M = 1'b0;
                WB = 3'b001;
                Branch=3'b100;//jal
            end
            JALR:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b0;
                WB = 3'b001;
                Branch = 3'b101;//jalr
            end
            default:begin
                EX = 6'b0;
                M = 1'b0;
                WB = 3'b0;
                Branch = 3'b00;
            end
        endcase
    end
endmodule
