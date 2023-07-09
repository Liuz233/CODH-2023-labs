`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 21:49:47
// Design Name: 
// Module Name: Dcache
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


module Dcache(
    input clk,
    input rstn,
    //
    input [9:0] addr,
    input cpu_req_rw,
    input cvalid,
    input [31:0] d,
    output reg [31:0] spo,
    output reg cready,
    //
    output reg [9:0] mem_addr,
    output reg mem_req_rw,
    output reg mvalid,
    output reg [127:0] din,
    output reg [31:0] miss,
    output reg [31:0] total,
    input [127:0] dout,
    input mready
    );

    parameter V = 131;
    parameter D = 130;
    parameter TagMSB = 129;
    parameter TagLSB = 128;
    parameter BlockMSB = 127;
    parameter BlockLSB = 0;
    
    parameter IDLE = 0;
    parameter CompareTag = 1;
    parameter Allocate = 2;
    parameter WriteBack = 3;
    
    reg [131:0] cache_data[0:63];
    reg [1:0] state,next_state;
    reg hit;

    reg en1=0;
    reg en2=0;
    wire [5:0] cpu_req_index;
    wire [1:0] cpu_req_tag;
    wire [1:0] cpu_req_offset;

    assign cpu_req_index = addr[7:2];
    assign cpu_req_tag = addr[9:8];
    assign cpu_req_offset = addr[1:0];

     integer i;
     initial 
     begin
         for(i=0; i<64 ; i=i+1)
             cache_data[i]=132'd0;
     end

    always@(posedge clk,posedge rstn)
    begin
        if(rstn) 
            state<=IDLE;
        else   
            state<=next_state;
    end
    always@(*)
    begin
        en1=1'b0;en2=1'b0;
        case(state)
            IDLE: if(cvalid)
                    begin
                    en1=1'b1;//总次数+1
                    next_state=CompareTag;
                    end
                else
                    next_state=IDLE;
            CompareTag: if(hit)
                        next_state=IDLE;
                        else begin
                        en2=1'b1;//未命中计数
                        if(cache_data[cpu_req_index][V:D]==2'b11)
                                next_state=WriteBack;
                        else
                                next_state=Allocate;
                        end
            Allocate: if(!mready)
                        next_state=CompareTag;
                else 
                        next_state=Allocate;
            WriteBack: if(!mready)
                        next_state=Allocate;
                else   
                        next_state=WriteBack;
            default:next_state=IDLE;
        endcase
    end
    always@(posedge clk,posedge rstn)
    begin
        if(rstn) 
            miss<=32'b0;
        else if(en2)//未命中计数
            miss<=miss+32'b1;

    end
    always@(posedge clk,posedge rstn)
    begin
        if(rstn) 
            total<=32'b0;
        else if(en1)//未命中计数
            total<=total+32'b1;

    end
    always@(*)
    begin
        if(state==CompareTag)
        begin
            if(cache_data[cpu_req_index][131]&&cache_data[cpu_req_index][TagMSB:TagLSB]==cpu_req_tag)
                hit=1'b1;
            else   
                hit=1'b0;
        end 
        else hit=1'b0;//
    end
    always@(posedge clk)
    begin
        if(state==Allocate)
        begin
            if(mready)//准备好了
            begin
                mem_addr<={addr[9:2],2'b00};
                mem_req_rw<=1'b0;
                mvalid<=1'b1;
            end
            else
            begin
                mvalid<=1'b0;
                cache_data[cpu_req_index][BlockMSB:BlockLSB]<=dout;
                cache_data[cpu_req_index][V:D]<=2'b10;
                cache_data[cpu_req_index][TagMSB:TagLSB]<=cpu_req_tag;
            end
        end
        else if(state==WriteBack)
        begin
            if(mready)
            begin
                mem_addr<={cache_data[cpu_req_index][TagMSB:TagLSB],cpu_req_index,2'b00};
                mem_req_rw<=1'b1;
                din<=cache_data[cpu_req_index][BlockMSB:BlockLSB];
                mvalid<=1'b1;
            end
            else
            begin
                mvalid<=1'b0;
            end
        end
        else
        begin
            mvalid<=1'b0;
        end
    end
    always@(posedge clk)
    begin
        if(state==CompareTag&&hit)
        begin
            if(cpu_req_rw==1'b0)//read hit
            begin
                cready<=1'b1;
                spo<=cache_data[cpu_req_index][cpu_req_offset*32 +:32];
            end
            else//write hit
            begin
                cready<=1'b1;
                cache_data[cpu_req_index][cpu_req_offset*32 +:32]=d;
                cache_data[cpu_req_index][D]=1'b1;
            end
        end
        else   
            cready<=1'b0;
    end
endmodule
