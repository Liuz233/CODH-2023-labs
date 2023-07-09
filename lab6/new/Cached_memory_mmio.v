`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/13 22:46:04
// Design Name: 
// Module Name: Cached_memory_mmio
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


module Cached_memory_mmio(
    input clk_cpu,
    input rstn,
    input [31:0] real_data_addr,
    input [31:0] MEM_R2,
    input MEM_MemWrite,
    input [31:0] dra0,
    output [31:0] MEM_data_out,
    output [31:0] drd0,
    input [6:0] opcode,
    output [1:0] state_out,
    output [31:0] total,
    output [31:0] miss,
    output done
    /* // mmio
    input [15:0] led_data_in,
    output reg[15:0] led_data_out,
    input [31:0] swt_data_in,
    output reg [31:0] swt_data_out,
    input seg_rdy_in,
    output reg seg_rdy_out,
    input [31:0] seg_data_in,
    output reg [31:0] seg_data_out,
    input swx_vld_in,
    output reg swx_vld_out,
    input [31:0] swx_data_in,
    output reg [31:0] swx_data_out,
    input [31:0] cnt_data_in,
    output reg [31:0] cnt_data_out */
    );
    wire [6:0] new_opcode;
    Cached_memory CM_inst(
        .clk_cpu (clk_cpu),
        .rstn (rstn),
        .real_data_addr (real_data_addr[9:0]),
        .MEM_R2 (MEM_R2),
        .MEM_MemWrite (MEM_MemWrite),
        .dra0 (dra0[9:0]),
        .MEM_data_out (MEM_data_out),
        .drd0 (drd0),
        .opcode (new_opcode),
        .state_out (state_out),
        .total (total),
        .miss (miss),
        .done (done)
    );
    wire mmio;
    //wire [31:0] mmio_data_output;
    assign mmio = (real_data_addr[15:4]==12'b0001_0111_1100);
    assign new_opcode = (mmio)?7'b0:opcode;
    
endmodule
