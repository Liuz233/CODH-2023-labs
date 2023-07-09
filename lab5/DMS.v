`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/21 11:48:50
// Design Name: 
// Module Name: DMS
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


module DMS(
    input cpu_clk,
    input cpu_rstn,
    input [31:0] a,
    input [31:0] dpra,
    input [31:0] d,
    input dwe,
    output [31:0] spo,
    output [31:0] dpo,
    output [31:0] led_out
    );
    wire we;
    wire [31:0] dm_out;
    wire [31:0] ain;
    wire [31:0] clk_num;
    assign ain=(a==32'h00007f00||a==32'h00007f20)? 32'b0: ((a-32'h00002000)>>2);
    assign spo=(a==32'h00007f20)? clk_num : dm_out;
    assign we=(a==32'h00007f00||a==32'h00007f20)?1'b0:dwe;
    dist_DM DM(
    .a(ain),        // input wire [9 : 0] a
    .d(d),        // input wire [31 : 0] d
    .dpra(dpra),  // input wire [9 : 0] dpra
    .clk(cpu_clk),    // input wire clk
    .we(we),      // input wire we
    .spo(dm_out),    // output wire [31 : 0] spo
    .dpo(dpo)    // output wire [31 : 0] dpo
    );
    reg32  LED(
    .clk                     ( cpu_clk      ),
    .rstn                    ( cpu_rstn      ),
    .D                       ( d ),
    .en                      ( (a==32'h00007f00)),

    .Q                       ( led_out )
    );
    Count  count (
    .clk                     ( cpu_clk           ),
    .en                      ( 1'b1               ),
    .init                    ( 32'b0            ),
    .clear                   ( cpu_rstn         ),

    .Q                       ( clk_num          )
    );
endmodule
