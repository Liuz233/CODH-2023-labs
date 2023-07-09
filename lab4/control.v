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
    output reg Registerwrite,
    output reg [6:0] ImmGen,
    output reg [6:0] ALUOP,
    output reg EN,
    output reg MMIOSIG,
    output reg [1:0] MemtoReg,
    output reg SrcB,
    output reg [1:0] SrcA,
    output reg [2:0] Branch,
    output reg JALMUX,
    output reg Memwe
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
        ImmGen=inst;
        ALUOP=inst;
        EN=1;
        MMIOSIG=0;
        MemtoReg=2'b00;
        SrcA=2'b00;
        SrcB=0;
        Branch=3'b000;
        JALMUX=0;
        Memwe=0;
        case(inst)
            OP:begin
                Registerwrite=1;
                MemtoReg=2'b00;
                SrcA=2'b01;
                SrcB=0;
            end
            OPIMM:begin
                Registerwrite=1;
                MemtoReg=2'b00;
                SrcA=2'b01;
                SrcB=1;
            end
            LUI:begin
                Registerwrite=1;
                MemtoReg=2'b00;
                SrcA=2'b10;
                SrcB=1;
            end
            AUIPC:begin
                Registerwrite=1;
                MemtoReg=2'b00;
                SrcA=2'b00;
                SrcB=1;
            end
            LOAD:begin
                Registerwrite=1;
                MMIOSIG=1;
                MemtoReg=2'b01;
                SrcA=2'b01;
                SrcB=1;
            end
            STORE:begin
                Registerwrite=0;
                MMIOSIG=1;
                SrcA=2'b01;
                SrcB=1;
                Memwe=1;
            end
            BRANCH:begin
                Registerwrite=0;
                SrcA=2'b01;
                SrcB=0;//rs1-rs2
                if(IR[14:12]==3'b000) Branch=3'b001;//beq
                else if(IR[14:12]==3'b100) Branch=3'b010;//blt
                else if(IR[14:12]==3'b110) Branch=3'b011;//bltu
            end
            JAL:begin
                MemtoReg=2'b10;
                Registerwrite=1;
                Branch=3'b100;//jal
            end
            JALR:begin
                Registerwrite=1;
                MemtoReg=2'b10;
                SrcA=2'b01;
                SrcB=1;
                JALMUX=1;
            end
            default:begin
                Registerwrite=0;
            end
        endcase
    end
endmodule
