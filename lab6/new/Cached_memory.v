`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/11 15:16:00
// Design Name: 
// Module Name: Cached_memory
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


module Cached_memory(
    input clk_cpu,
    input rstn,
    input [9:0] real_data_addr,
    input [31:0] MEM_R2,
    input MEM_MemWrite,
    input [9:0] dra0,
    output [31:0] MEM_data_out,
    output [31:0] drd0,
    input [6:0] opcode,
    output [31:0] total,
    output [31:0] miss,
    // debug信号
    output [1:0] state_out,
    // cache 额外输入
    //input cpu_req_rw,
    //input cpu_req_valid,
    //input [31:0] cpu_data_write,
    output done
    );
    data_memory DM_inst(
        .clk (clk_cpu),
        .a (real_data_addr[9:0]),
        .d (MEM_R2),
        .dpra (dra0[9:0]),
        .we (MEM_MemWrite),
        //.spo (MEM_data_out),
        .dpo (drd0)
    );
    wire [9:0] cache_memory_a;
    wire [9:0] memory_cache_a;
    wire [127:0] cache_memory_d;
    wire [127:0] memory_cache_d;
    wire [1:0] state;
    wire cache_memory_valid, cache_memory_ready;
    wire memory_cache_valid, memory_cache_ready;

    Data_cache cache_inst(
        .clk (clk_cpu),
        .rstn (rstn),
        .in_a (real_data_addr[9:0]),
        .in_d (MEM_R2),
        .opcode (opcode),
        .out_d (MEM_data_out),
        .done (done),
        .total (total),
        .miss (miss),
        .cache_memory_a (cache_memory_a),
        .cache_memory_d (cache_memory_d),
        .memory_cache_a (memory_cache_a),
        .memory_cache_d (memory_cache_d),
        .cache_memory_valid (cache_memory_valid),
        .cache_memory_ready (cache_memory_ready),
        .memory_cache_valid (memory_cache_valid),
        .memory_cache_ready (memory_cache_ready),
        .state (state)
    );
    Data_mem mem_inst(
        .clk (clk_cpu),
        .rstn (rstn),
        .cache_memory_a (cache_memory_a),
        .cache_memory_d (cache_memory_d),
        .memory_cache_a (memory_cache_a),
        .memory_cache_d (memory_cache_d),
        .cache_memory_valid (cache_memory_valid),
        .cache_memory_ready (cache_memory_ready),
        .memory_cache_valid (memory_cache_valid),
        .memory_cache_ready (memory_cache_ready),
        .state (state)
    );

    assign state_out = state;
endmodule
