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
    input cvalid,
    input [31:0] a,
    //input [31:0] dpra,
    input [31:0] d,
    input cpu_req_rw,
    output [31:0] spo,
    //output [31:0] dpo,
    output [31:0] miss,
    output [31:0] total,
    output cready
    );
    // reg cvalid = 1'b1;
    // reg [31:0] a = 32'b0;
    // reg [31:0] dpra = 32'b0;
    // reg [31:0] d = 32'b0;
    // reg cpu_req_rw = 1'b0;
    // wire [31:0] spo,dpo,miss,total;
    // wire cready;
    //
    wire [127:0] din,dout;
    wire mready,mvalid,mem_req_rw;
    wire [9:0] mem_addr;
    wire ccvalid;
    assign ccvalid = (a[15:8]==8'h7f) ? 1'b0 : cvalid;//mmio
    Dcache u_Dcache (
    .clk                     ( cpu_clk                 ),
    .rstn                    ( cpu_rstn                ),
    .addr                    ( ((a-32'h00002000)>>2)   ),
    .cpu_req_rw              ( cpu_req_rw          ),
    .cvalid                  ( ccvalid              ),
    .d                       ( d           [31:0]  ),//整体输入
    .dout                    ( dout        [127:0] ),//mem输出
    .mready                  ( mready              ),

    .spo                     ( spo         [31:0]  ),//整体输出
    .cready                  ( cready              ),
    .mem_addr                ( mem_addr    [9:0]   ),
    .mem_req_rw              ( mem_req_rw          ),
    .mvalid                  ( mvalid              ),
    .miss                    (            miss     ),
    .total                    (total                ),
    .din                     ( din         [127:0] )//对mem输入
    );
    Dmem u_Dmem (
    .clk                     ( cpu_clk                      ),
    .rstn                    ( cpu_rstn                     ),
    .addr                    ( mem_addr    [9:0] ),
    .rw                      ( mem_req_rw                       ),
    .mvalid                  ( mvalid                   ),
    .din                     ( din     [127:0]          ),
    //.dpra                    ( dpra    [9:0] ),

    .dout                    ( dout    [127:0]          ),
    .mready                  ( mready                   )
    //.dpo                     ( dpo     [31:0] )
    );

endmodule
