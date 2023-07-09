`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 12:51:37
// Design Name: 
// Module Name: SRT
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


module SRT(
    input clk,
    input rstn,
    input Run,
    output done,
    output [15:0] cycles,
    // output reg [7:0] seg,
    // output reg [7:0] AN
    //SDU_DM
    input [31:0] addr,
    output [31:0] dout,
    input [31:0] din,
    input we,
    input clk_ld
    //output rstns,
    //output runs
    );
    localparam  [3:0]   s1=4'b0000,
                        s2=4'b0001,
                        s3=4'b0010,
                        s4=4'b0011,
                        s5=4'b0100,
                        s6=4'b0101,
                        s7=4'b0110,
                        s8=4'b0111,
                        s9=4'b1000;
   // assign rstns=rstn;//
    // reg  [3:0] seg_data;
    // reg  [2:0] cnt_seg;
    reg [3:0] cs;
    reg [3:0] ns;
    reg state;
    // reg [31:0] cnt;
    // wire pulse_50hz;
    // wire [31:0] cycle;
//存储器接口
    reg [8:0] addr_srt;
    wire [8:0] addrs;
    reg [31:0] data;
    wire [31:0] datas;
    wire [31:0] spo;
    wire [31:0] dpo;
    reg we_srt;
    wire wes;
    wire clks;
    wire [8:0] dpra=0;
////冲突接口

//计数器控制循环
    wire [31:0] I,J;
    reg Clear_I,Clear_J,Clear_C;
    reg En_I,En_J,En_C;
//A,B寄存器
    wire [31:0] A,B,N;
    reg En_A,En_B,En_N;
//多路选择器
    reg [1:0] sel_IJ;
    reg sel_AB;

//边界条件
    wire ZI,ZJ;
    wire run;
     signal_edge ed(
         .clk(clk),
         .button(Run),
         .button_edge(run)
     );
    //assign runs=run;//
    //assign run=Run;
    // always@(posedge clk)
    // begin
    //     if(rstn)
    //     cnt<=32'b0;
    //     else if(cnt>=1000)//
    //     cnt<=32'b0;
    //     else cnt<=cnt+32'b1;
    // end
    // assign pulse_50hz=(cnt==32'b1);//产生用于分时复用的信号
    // always @(posedge clk)
    // begin
    //     if(rstn)
    //         cnt_seg<=3'b000;
    //     else if(pulse_50hz)
    //         cnt_seg<=cnt_seg+1;
    // end
//状态机
    always@(posedge clk,posedge rstn)
    begin
        if(rstn) cs<=s1;
        else cs<=ns;
    end
    always@(*)
    begin
        ns=cs; we_srt=0;
        Clear_I=0;Clear_J=0;Clear_C=0;
        En_I=0;En_J=0;En_C=1;
        En_A=0;En_B=0;En_N=0;
        sel_IJ=0; sel_AB=0;
        case(cs)
            s1:begin
                Clear_I=1;
                Clear_C=1;
                sel_IJ=2'b00;
                En_N=1;//存下N
                En_C=0;
                if(run) ns=s2;
                else ns=s1;
            end
            s2:begin
                Clear_J=1;
                sel_IJ=2'b01;
                En_A=1;
                ns=s3;
            end
            s3:begin
                En_J=1;
                ns=s4;
            end
            s4:begin
                sel_IJ=2'b10;
                En_B=1;
                ns=s5;
            end
            s5:begin
                if(A>B) ns=s6;
                else ns=s8;
            end
            s6:begin
                sel_IJ=2'b10;
                sel_AB=1'b0;
                we_srt=1;
                ns=s7;
            end
            s7:begin
                sel_IJ=2'b01;
                sel_AB=1'b1;
                we_srt=1;
                ns=s8;
            end
            s8:begin
                sel_IJ=2'b01;
                En_A=1;
                if(!ZJ) ns=s3;
                else if(!ZI) begin
                    En_I=1;
                    ns=s2;
                end
                else ns=s9;
                
            end
            s9:begin
                En_C=0;
                if(run) ns=s1;
                else ns=s9;
            end
            default:begin
                En_C=0;
                if(run) ns=s1;
                else ns=cs;
            end
        endcase      
    end
    assign done=(cs==s9)?1:0;//状态机结果
    always@(*)//多路选择器
    begin
        case(sel_IJ)
        2'b00: addr_srt=9'b0;
        2'b01: addr_srt=I;
        2'b10: addr_srt=J;
        default: addr_srt=9'b0;
        endcase
        case(sel_AB)
        1'b0: data=A;
        1'b1: data=B;
        default: data=A;
        endcase
    end
     always@(*)
     begin
         if(run) state=0;
         else if(done) state=1;
         else state=state;
     end
    assign ZJ=(J==N)?1:0;
    assign ZI=(I==(N-1))?1:0;
    //端口选择
    assign addrs=(state==0)?addr_srt:addr;
    assign dout=spo;
    assign datas=(state==0)?data:din;
    assign wes=(state==0)?we_srt:we;
    assign clks=(state==0)?clk:clk_ld;
    //    always @(cnt_seg)
    // begin
  
    //     case (seg_data )
    //     4'd0 : seg <= 8'b11000000;   //0
    //     4'd1 : seg <= 8'b11111001;   //1
    //     4'd2 : seg <= 8'b10100100;   //2
    //     4'd3 : seg <= 8'b10110000;   //3
    //     4'd4 : seg <= 8'b10011001;   //4
    //     4'd5 : seg <= 8'b10010010;   //5
    //     4'd6 : seg <= 8'b10000010;   //6
    //     4'd7 : seg <= 8'b11111000;   //7
    //     4'd8 : seg <= 8'b10000000;   //8
    //     4'd9 : seg <= 8'b10010000;   //9
    //     4'ha : seg <= 8'b00001000;   //a
    //     4'hb : seg <= 8'b00000000;   //b
    //     4'hc : seg <= 8'b01000110;   //c
    //     4'hd : seg <= 8'b01000000;   //d
    //     4'he : seg <= 8'b00000110;   //e
    //     4'hf : seg <= 8'b00001110;   //f
    //     default : seg <= 8'b11000000;   //0
    //     endcase
 
    //      case (cnt_seg)
    //     3'b000: begin AN<= 8'b11111110;seg_data<=cycle[3:0] ; end
    //     3'b001: begin AN<= 8'b11111101;seg_data<=cycle[7:4]; end
    //     3'b010: begin AN <= 8'b11111011;seg_data<=cycle[11:8] ; end
    //     3'b011: begin  AN <= 8'b11110111; seg_data<=cycle[15:12]; end
    //     3'b100: begin  AN <= 8'b11101111; seg_data<=cycle[19:16]; end
    //     3'b101: begin  AN <= 8'b11011111; seg_data<=cycle[23:20]; end
    //     3'b110: begin  AN <= 8'b10111111; seg_data<=cycle[27:24]; end
    //     3'b111: begin  AN <= 8'b01111111; seg_data<=cycle[31:28]; end
    //     default:AN <= 8'b00000000;
    //     endcase
   
    //     if(rstn) 
    //     begin
    //         AN <= 8'b11111110;
    //         seg_data<=0;
    //     end
  
    //end
    Count  Loop_i(
    .clk                     ( clk           ),
    .en                      ( En_I            ),
    .init                    ( 32'b1          ),
    .clear                   ( Clear_I        ),
    .Q                       ( I )
    );
    Count  Loop_j(
    .clk                     ( clk           ),
    .en                      ( En_J            ),
    .init                    ( I          ),
    .clear                   ( Clear_J        ),
    .Q                       ( J             )
    );
    Count  cyclenum(
    .clk                     ( clk           ),
    .en                      ( En_C            ),
    .init                    ( 32'b0          ),
    .clear                   ( Clear_C        ),
    .Q                       ( cycles            )
    );
    //
    //
    reg32  regA (
    .clk                     ( clk          ),
    .rstn                    ( rstn         ),
    .D                       ( spo     [31:0] ),
    .en                      ( En_A           ),

    .Q                       ( A     [31:0] )
    );
    reg32  regB (
    .clk                     ( clk          ),
    .rstn                    ( rstn         ),
    .D                       ( spo     [31:0] ),
    .en                      ( En_B           ),

    .Q                       ( B     [31:0] )
    );
    reg32  regN (
    .clk                     ( clk          ),
    .rstn                    ( rstn         ),
    .D                       ( spo     [31:0] ),
    .en                      ( En_N           ),

    .Q                       ( N     [31:0] )
    );
    dm dm0 (
    .a(addrs),        // input wire [8 : 0] a
    .d(datas),        // input wire [31 : 0] d
    .dpra(dpra),  // input wire [8 : 0] dpra
    .clk(clks),    // input wire clk
    .we(wes),      // input wire we
    .spo(spo),    // output wire [31 : 0] spo
    .dpo(dpo)    // output wire [31 : 0] dpo
    );
endmodule
