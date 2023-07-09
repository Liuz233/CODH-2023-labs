`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:42:54
// Design Name: 
// Module Name: Registers
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


module Registers(
    input clk,                  //时钟
    input rstn,
    input [4:0] ra1, ra2,       //读地址
    output [31:0] rd1, rd2,     //读数据
    input [4:0] wa,             //写地址
    input [31:0] wd,            //写数据
    input we,                   //写使能
    input [4:0] ra_debug,       //调试用读地址
    output [31:0] rd_debug      //调试用读数据
    );
    reg [31:0] rf [0:31];       //寄存器数据
    wire [31:0] compare1, compare2, compare3;             //比较寄存器堆的数据与写入的数据
    assign compare1 = (ra1 == wa)?wd:rf[ra1];
    assign compare2 = (ra2 == wa)?wd:rf[ra2];
    assign compare3 = (ra_debug == wa)?wd:rf[ra_debug];

    assign rd1 = (ra1 == 0)?0:compare1;         //rf[0]始终为0
    assign rd2 = (ra2 == 0)?0:compare2;
    assign rd_debug = (ra_debug == 0)?0:compare3;
    always @(posedge clk or negedge rstn) begin //写操作
        if(!rstn) begin
            rf[0] <= 0; rf[1] <= 0; rf[2] <= 0; rf[3] <= 0; rf[4] <= 0; rf[5] <= 0; rf[6] <= 0; rf[7] <= 0; 
            rf[8] <= 0; rf[9] <= 0; rf[10] <= 0; rf[11] <= 0; rf[12] <= 0; rf[13] <= 0; rf[14] <= 0; rf[15] <= 0;
            rf[16] <= 0; rf[17] <= 0; rf[18] <= 0; rf[19] <= 0; rf[20] <= 0; rf[21] <= 0; rf[22] <= 0; rf[23] <= 0;
            rf[24] <= 0; rf[25] <= 0; rf[26] <= 0; rf[27] <= 0; rf[28] <= 0; rf[29] <= 0; rf[30] <= 0; rf[31] <= 0;
        end
        else begin 
            if(we) begin
                rf[wa] <= wd;
            end
        end
    end

endmodule

