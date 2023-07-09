`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:46:01
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input clk,
    // 控制信号
    input RegWrite_in,
    input [1:0] RegSrc_in,
    output reg RegWrite_out,
    output reg [1:0] RegSrc_out,
    // 其他寄存器
    input [31:0] pc_plus_in,
    input [31:0] ir_in,
    input [31:0] aluresult_in,
    input [31:0] memdata_in,
    input [4:0] rdidx_in,
    output reg [31:0] pc_plus_out,
    output reg [31:0] ir_out, 
    output reg [31:0] aluresult_out,
    output reg [31:0] memdata_out,
    output reg [4:0] rdidx_out,

    input clear,
    input enable
    );

    always @(posedge clk) begin
        if(clear) begin
            RegWrite_out <= 0;
            RegSrc_out <= 1;
            pc_plus_out <= 0;
            ir_out <= 0;
            aluresult_out <= 0;
            memdata_out <= 0;
            rdidx_out <= 0;
        end
        else begin
            if(enable) begin
                RegWrite_out <= RegWrite_in;
                RegSrc_out <= RegSrc_in;
                pc_plus_out <= pc_plus_in;
                ir_out <= ir_in;
                aluresult_out <= aluresult_in;
                memdata_out <= memdata_in;
                rdidx_out <= rdidx_in;
            end
            else begin
                RegWrite_out <= RegWrite_out;
                RegSrc_out <= RegSrc_out;
                pc_plus_out <= pc_plus_out;
                ir_out <= ir_out;
                memdata_out <= memdata_out;
                rdidx_out <= rdidx_out;
            end
        end

    end
endmodule
