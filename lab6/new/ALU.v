`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:43:30
// Design Name: 
// Module Name: ALU
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

module ALU(
    input [31: 0] a, 
    input [31: 0] b,         //两操作数
    input [2:0] f,                  //功能选择
    output reg [31: 0] y,           //运算结果
    output reg [2:0] t              //比较标志
    );
    reg eq, lt, ltu;
    reg signed [31: 0] as;
    reg signed [31: 0] bs;
    
    always @(*) begin
        as = a;
        bs = b;
        case (f)
            0: begin
                y = a - b;
                eq = (a == b) ? 1 : 0;
                ltu = (a < b) ? 1 : 0;
                lt = (as < bs) ? 1 : 0;
                t = {ltu, lt, eq};
            end
            1: begin
                y = a + b;
                t = 3'b0;
            end
            2: begin
                y = a & b;
                t = 3'b0;
            end
            3: begin
                y = a | b;
                t = 3'b0;
            end
            4: begin
                y = a ^ b;
                t = 3'b0;
            end
            5: begin
                y = a >> b[4:0];
                t = 3'b0;
            end
            6: begin
                y = a << b[4:0];
                t = 3'b0;
            end
            7: begin
                y = as >>> bs[4:0];
                t = 3'b0;
            end
        endcase
    end
endmodule

