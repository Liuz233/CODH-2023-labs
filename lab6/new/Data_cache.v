`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/11 12:14:48
// Design Name: 
// Module Name: Data_cache
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

// address为10位
// cache为1KB，共256个字，一个块内4个字，共64个块
// 64个块用6位表示，即index为6位；offset为2位；tag为2位
module Data_cache(
    // 与外界交互
    input clk,
    input rstn,
    input [9:0] in_a,  //输入地址
    input [31:0] in_d,  //输入数据
    input [6:0] opcode,
    output reg [31:0] out_d,//输出数据
    output reg done,        //cache与mem交互完成标志
    output reg [31:0] total,
    output reg [31:0] miss,
    // 与mem交互
    // cache_memory_xxx: cache -> memory 过程
    // memory_cache_xxx: memory -> cache 过程
    output reg [9:0] cache_memory_a,
    output reg [127:0] cache_memory_d,
    output reg [9:0] memory_cache_a,
    input [127:0] memory_cache_d,
    //output reg mem_read_write,
    output [1:0] state,
    // valid & ready
    output reg cache_memory_valid,
    input cache_memory_ready,
    input memory_cache_valid,
    output reg memory_cache_ready
    );
    parameter VALID = 131;
    parameter DIRTY = 130;
    parameter TAGMSB = 129;
    parameter TAGLSB = 128;
    parameter BLOCKMSB = 127;
    parameter BLOCKLSB = 0;

    parameter ZERO = 0;
    parameter CompareTag = 1;
    parameter Allocate = 2;
    parameter WriteBack = 3;

    // cache
    reg [VALID: 0] cache [0:63];
    
    //初始化cache
    integer i = 0;
    initial begin
        for(i = 0; i < 64; i = i + 1) begin
            cache[i] = 132'b0;
        end
    end

    // 状态机
    reg [1:0] curr_state, next_state;

    // 命中状态
    wire hit;

    // index tag offset
    wire [5:0] address_index;
    wire [1:0] address_tag;
    wire [1:0] address_offset;

    assign address_offset = in_a[1:0];
    assign address_index = in_a[7:2];
    assign address_tag = in_a[9:8];

    // 判断是否需要访存
    wire read_or_write;
    wire read, write;
    assign read_or_write = read || write;
    assign read = (opcode == 7'b0000011);
    assign write = (opcode == 7'b0100011);
    // 状态机转换
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            curr_state <= ZERO;
        end
        else begin
            curr_state <= next_state;
        end
    end
    always @(*) begin
        case (curr_state)
            ZERO: begin
                if(read_or_write) next_state = CompareTag;
                else next_state = ZERO;
            end
            CompareTag: begin
                if(hit) next_state = ZERO;
                else if(cache[address_index][VALID:DIRTY] == 2'b11) next_state = WriteBack;
                else next_state = Allocate;
            end
            Allocate: begin
                if(memory_cache_valid && memory_cache_ready) begin
                    next_state = CompareTag;
                end
                else begin
                    next_state = Allocate;
                end
            end
            WriteBack: begin
                if(cache_memory_ready && cache_memory_valid) begin
                    next_state = Allocate;
                end
                else begin
                    next_state = WriteBack;
                end
            end
        endcase
    end

    //hit判断
    assign hit = (curr_state == CompareTag && cache[address_index][VALID] == 1 && cache[address_index][TAGMSB:TAGLSB] == address_tag);
    // done: 是否停止流水线？1: 不停止 0: 停止流水线
    always @(*) begin
        if(curr_state == CompareTag && hit) begin
            done = 1;
        end
        else if(curr_state == ZERO && next_state == ZERO) begin
            done = 1;
        end
        else begin
            done = 0;
        end
    end
    // cache行为
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cache[address_index] <= 0;
        end
        else begin
            if(curr_state == CompareTag && hit) begin
                if(write) begin
                    case (address_offset)
                        0: cache[address_index][31:0] <= in_d;
                        1: cache[address_index][63:32] <= in_d;
                        2: cache[address_index][95:64] <= in_d;
                        3: cache[address_index][127:96] <= in_d;
                    endcase
                    cache[address_index][DIRTY] <= 1;
                    cache[address_index][VALID] <= 1;
                    cache[address_index][TAGMSB:TAGLSB] <= cache[address_index][TAGMSB:TAGLSB];
                end
                else begin
                    cache[address_index] <= cache[address_index];
                end
                
            end
            else if (curr_state == Allocate) begin
                if(memory_cache_valid && memory_cache_ready) begin
                    //memory_cache_ready <= 0;
                    cache[address_index][BLOCKMSB:BLOCKLSB] <= memory_cache_d;
                    cache[address_index][VALID:DIRTY] <= 2'b10;
                    cache[address_index][TAGMSB:TAGLSB] <= address_tag;
                end
                else begin
                    cache[address_index] <= cache[address_index];
                end
            end
            else if(curr_state == WriteBack) begin
                cache[address_index] <= cache[address_index];
            end
            else begin
                cache[address_index] <= cache[address_index];
            end
        end
    end
    always @(*) begin
        case (address_offset)
            0: out_d = cache[address_index][31:0];
            1: out_d = cache[address_index][63:32];
            2: out_d = cache[address_index][95:64];
            3: out_d = cache[address_index][127:96];
        endcase
    end
    // memory行为
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cache_memory_valid <= 0;
            memory_cache_ready <= 1;
        end
        else begin
            if(curr_state == WriteBack) begin
                if(cache_memory_valid && cache_memory_ready) begin
                    cache_memory_valid <= 0;
                end
                else begin
                    cache_memory_valid <= 1;
                end
                cache_memory_a <= {cache[address_index][TAGMSB:TAGLSB],address_index, 2'b00};
                cache_memory_d <= cache[address_index][BLOCKMSB:BLOCKLSB];
                //mem_read_write <= 0;
            end
            else if (curr_state == Allocate) begin
                //mem_read_write <= 1;
                memory_cache_a <= {in_a[9:2], 2'b00};
                
                if(!memory_cache_ready || !memory_cache_valid) begin
                    memory_cache_ready <= 1;
                    //cache[address_index] <= cache[address_index];
                end
                else begin
                    memory_cache_ready <= 0;
                end
            end
        end
    end
    // 缺页与总访存次数
    reg miss_flag;
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            total <= 0;
            miss_flag <= 0;
            miss <= 0;
        end
        else begin
            case (curr_state)
                ZERO: begin
                    if(read_or_write) begin
                        total <= total + 1;
                    end
                    else begin
                        total <= total;
                    end
                    miss <= miss;
                    miss_flag <= 0;
                end
                Allocate: begin
                    if(~miss_flag) begin
                        miss <= miss + 1;
                    end
                    else begin
                        miss <= miss;
                    end
                    miss_flag <= 1;
                    total <= total;
                end
                default: begin
                    miss <= miss;
                    total <= total;
                    miss_flag <= 0;
                end
            endcase
        end
    end
    assign state = curr_state;
endmodule

