`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/11 16:42:42
// Design Name: 
// Module Name: IOU
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

// io_addr: 外设地址
// io_dout: 输出外设数据
// io_din: 来自外设的输入数据
// io_we: 写外设控制信号
// io_rd: 读外设控制信号
// 7fxx:mmio
// led_data:00 -> 17c0
// swt_data:04 -> 17c1
// seg_rdy: 08 -> 17c2
// seg_data:0c -> 17c3
// swx_vld: 10 -> 17c4
// swx_data:14 -> 17c5
// cnt_data:18 -> 17c6
module IOU(
    input clk,
    input clk_cpu,
    input rstn,
    // IO_BUS
    input [31:0] io_addr,
    input [31:0] io_dout,
    input io_we,
    input io_rd,
    output reg [31:0] io_din,
    // 外设
    input [15:0] sw,
    input btnr,
    input btnc,
    output [15:0] led,
    // output A,B,C,D,E,F,G,
    // output [7:0] AN,
    // total & miss & final output
    //input pc,
    //input npc,
    output hex_data
    //output hex_choice
    //input [31:0] total,
    //input [31:0] miss
    );

    wire [31:0] sw_data_out;
    wire btnr_edge, btnc_edge;
    sw_DPE DPE_inst(
        .clk (clk),
        .rstn (rstn),
        .sw (sw),
        .btnr (btnr),
        .btnc (btnc),
        .btnr_edge (btnr_edge),
        .btnc_edge (btnc_edge),
        .data_out (sw_data_out)
    );

    // mmio寄存器
    // 写: led_data, seg_data, cnt_data
    // 读: swt_data, seg_rdy, swx_vld, swx_data, cnt_data
    reg [15:0] led_data;
    reg [31:0] swt_data;
    reg seg_rdy;
    reg [31:0] seg_data;
    reg swx_vld;
    reg [31:0] swx_data;
    reg [31:0] cnt_data;
    // 时钟计数器
    reg [31:0] clock_counter;
    // mmio部分
    
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            led_data <= 0;
            seg_data <= 0;
            cnt_data <= 0;
        end
        else if (io_we) begin
            case (io_addr[3:0])
                0: led_data <= io_dout[15:0];
                3: begin
                    if(seg_rdy) seg_data <= io_dout;
                end
                6: begin
                    cnt_data <= io_dout;
                end
                default: begin
                    led_data <= led_data;
                    seg_data <= seg_data;
                    cnt_data <= clock_counter;
                end
            endcase
        end
        else begin
            led_data <= led_data;
            seg_data <= seg_data;
            cnt_data <= clock_counter;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            swt_data <= 0;
            swx_data <= 0;
        end 
        else begin
            swt_data <= {16'b0, sw[15:0]};
            if(btnc_edge) begin
                swx_data <= sw_data_out;
            end
            else begin
                swx_data <= swx_data;
            end
        end
    end
    always @(*) begin
        if(io_rd) begin
            case (io_addr[3:0])
                0: io_din = {16'b0, led_data};
                1: io_din = swt_data;
                2: io_din = {31'b0, seg_rdy};
                3: io_din = seg_data;
                4: io_din = {31'b0, swx_vld};
                5: io_din = swx_data;
                6: io_din = cnt_data;
                default: io_din = 32'b0;
            endcase
        end
        else begin
            io_din = 32'b0;
        end
    end
    // seg_rdy 查询式输出
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            seg_rdy <= 1;
        end
        else begin
            if(io_we) begin
                if(io_addr[3:0] == 3) begin
                    seg_rdy <= 0;
                end
                else seg_rdy <= seg_rdy;
            end
            else if(btnc_edge || btnr_edge) begin
                seg_rdy <= 1;
            end
            else seg_rdy <= seg_rdy;
        end
    end
    // swx_vld 查询式输入
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            swx_vld <= 0;
        end
        else begin
            if(io_rd && io_addr[3:0] == 5) begin
                swx_vld <= 0;
            end
            else begin
                swx_vld <= 1;
            end
        end
    end
    // 数码管分时显示
    wire [31:0] final_output_data;
    //wire hex_choice;
    //assign hex_choice = (io_we && io_addr[3:0] == 4'b0011) || (pc == npc+32'hc);
    assign hex_choice = (io_we && io_addr[3:0] == 4'b0011);
    assign final_output_data = (hex_choice)?seg_data:sw_data_out;

    /* always @(*) begin
        if(pc != npc) begin
            final_output_data = sw_data_out;
        end
        else begin
            final_output_data = seg_data;
        end
    end */
    hex32_convert hex_out(
        .clk (clk),
        .data_in (final_output_data),
        .A (A),
        .B (B),
        .C (C),
        .D (D),
        .E (E),
        .F (F),
        .G (G),
        .AN (AN)
    );
    assign led = led_data;
    // 时钟计数器
    always @(posedge clk_cpu or negedge rstn) begin
        if(~rstn) begin
            clock_counter <= 0;
        end
        else begin
            clock_counter <= clock_counter + 1;
        end
    end
endmodule
