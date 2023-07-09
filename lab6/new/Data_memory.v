`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/11 21:11:27
// Design Name: 
// Module Name: Data_memory
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


module Data_mem(
    input clk,
    input rstn,
    input [9:0] cache_memory_a,
    input [127:0] cache_memory_d,
    input [9:0] memory_cache_a,
    output reg [127:0] memory_cache_d,

    input cache_memory_valid,
    output reg cache_memory_ready,
    output reg memory_cache_valid,
    input memory_cache_ready,
    input [1:0] state
    );
    parameter IDLE=0;
    parameter CompareTag=1;
    parameter Allocate=2;
    parameter WriteBack=3;

    reg [31:0] mem[0:1023];

    integer i = 0;
    initial begin
        for(i = 0; i < 1024; i = i + 1) begin
            mem[i] <= 32'd0;
            
        end
    end
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            mem[cache_memory_a] <= mem[cache_memory_a];
            cache_memory_ready <= 1;
            memory_cache_valid <= 0;
        end
        else begin
            if(state == Allocate) begin
                if(memory_cache_ready && memory_cache_valid) begin
                    memory_cache_valid <= 0;
                    memory_cache_d <= {mem[{memory_cache_a[9:2],2'b00}],mem[{memory_cache_a[9:2],2'b01}],mem[{memory_cache_a[9:2],2'b10}],mem[{memory_cache_a[9:2],2'b11}]};
                end
                else begin
                    memory_cache_valid <= 1;
                end
            end
            else if(state == WriteBack) begin
                memory_cache_valid <= 0;
                if(cache_memory_ready && cache_memory_valid) begin
                    cache_memory_ready <= 0;
                    mem[cache_memory_a] <= cache_memory_d[31:0];
                    mem[cache_memory_a + 1] <= cache_memory_d[63:32];
                    mem[cache_memory_a + 2] <= cache_memory_d[95:64];
                    mem[cache_memory_a + 3] <= cache_memory_d[127:96];
                end
                else begin
                    cache_memory_ready <= 1;
                end
            end
            else begin
                memory_cache_valid <= 0;
                cache_memory_ready <= 1;
            end
            /* if(cache_memory_ready && cache_memory_valid) begin
                cache_memory_ready <= 0;
                mem[cache_memory_a] <= cache_memory_d[31:0];
                mem[cache_memory_a + 1] <= cache_memory_d[63:32];
                mem[cache_memory_a] <= cache_memory_d[95:64];
                mem[cache_memory_a] <= cache_memory_d[127:96];
            end
            else if(memory_cache_ready && memory_cache_valid) begin
                memory_cache_valid <= 0;
            end
            else begin
                cache_memory_ready <= 1;
                memory_cache_valid <= 0;
                mem[cache_memory_a] <= mem[cache_memory_a];
            end */
        end
    end
endmodule
