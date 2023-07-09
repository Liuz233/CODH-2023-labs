`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 11:35:37
// Design Name: 
// Module Name: MAV
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


module MAV(
    input clk,
    input rstn,
    input en,
    input  [15:0] d,
    output reg [7:0] seg,
    output reg [7:0] AN//
    );
    reg  [15:0] m;
    reg  [31:0] cnt;
    wire button_edge;
    wire pulse_50hz;
    reg  [15:0] nm1,nm2,nm3,nm4;
    reg  [15:0] m1,m2,m3,m4;
    reg  [2:0] cs,ns;
    reg  [3:0] seg_data;
    reg  [1:0] cnt_seg;
    always@(posedge clk)
    begin
        if(rstn)
        cnt<=32'b0;
        else if(cnt>=1000)//
        cnt<=32'b0;
        else cnt<=cnt+32'b1;
    end
    assign pulse_50hz=(cnt==32'b1);//产生用于分时复用的信号
    signal_edge ed(
        .clk(clk),
        .button(en),
        .button_edge(button_edge)
    );
    always @(posedge clk)
    begin
        if(rstn)
            cnt_seg<=2'b00;
        else if(pulse_50hz)
            cnt_seg<=cnt_seg+1;
    end
    //这里是状态机
    always@(posedge clk,posedge rstn)
    begin
        if(rstn) 
        begin
            cs<=3'b0;
            m1<=0;m2<=0;m3<=0;m4<=0;
        end
        else 
        begin
            cs<=ns;
            m1<=nm1;m2<=nm2;m3<=nm3;m4<=nm4;
        end
    end
    always@(*)
    begin
        nm1=m1;nm2=m2;nm3=m3;nm4=m4;
        ns=cs;
        case(cs)
        3'b000:begin
            m=0;
            if(button_edge) 
            begin
                nm1=0;nm2=0;nm3=0;nm4=d;
                ns=3'b001;
            end
            else ns=cs;
        end
        3'b001:begin
            m=m4;
            if(button_edge) 
            begin
                nm1=0;nm2=0;nm3=m4;nm4=d;
                ns=3'b010;
            end
            else ns=cs;
        end
        3'b010:begin
            m=m4;
            if(button_edge) 
            begin
                nm1=0;nm2=m3;nm3=m4;nm4=d;
                ns=3'b011;
            end
            else ns=cs;
        end
        3'b011:begin
            m=m4;
            if(button_edge) 
            begin
                nm1=m2;nm2=m3;nm3=m4;nm4=d;
                ns=3'b100;
            end
            else ns=cs;
        end
        3'b100:begin
            m=(m1+m2+m3+m4)>>2;
            if(button_edge) 
            begin
                nm1=m2;nm2=m3;nm3=m4;nm4=d;
                ns=3'b100;
            end
            else ns=cs;
        end
        default: begin
            m=(m1+m2+m3+m4)>>2;
            if(button_edge) 
            begin
                nm1=m2;nm2=m3;nm3=m4;nm4=d;
                ns=3'b100;
            end
            else ns=cs;
        end
        endcase
    end
    //end
    always @(cnt_seg)
    begin
  
        case (seg_data )
        4'd0 : seg <= 8'b11000000;   //0
        4'd1 : seg <= 8'b11111001;   //1
        4'd2 : seg <= 8'b10100100;   //2
        4'd3 : seg <= 8'b10110000;   //3
        4'd4 : seg <= 8'b10011001;   //4
        4'd5 : seg <= 8'b10010010;   //5
        4'd6 : seg <= 8'b10000010;   //6
        4'd7 : seg <= 8'b11111000;   //7
        4'd8 : seg <= 8'b10000000;   //8
        4'd9 : seg <= 8'b10010000;   //9
        4'ha : seg <= 8'b00001000;   //a
        4'hb : seg <= 8'b00000000;   //b
        4'hc : seg <= 8'b01000110;   //c
        4'hd : seg <= 8'b01000000;   //d
        4'he : seg <= 8'b00000110;   //e
        4'hf : seg <= 8'b00001110;   //f
        default : seg <= 8'b11000000;   //0
        endcase
 
         case (cnt_seg)
        2'b00: begin AN<= 8'b11111110;seg_data<=m[3:0] ; end
        2'b01: begin AN<= 8'b11111101;seg_data<=m[7:4]; end
        2'b10: begin AN <= 8'b11111011;seg_data<=m[11:8] ; end
        2'b11: begin  AN <= 8'b11110111; seg_data<=m[15:12]; end
        default:AN <= 8'b11110000;
        endcase
   
        if(rstn) 
        begin
            AN <= 8'b11111110;
            seg_data<=0;
        end
  
    end
endmodule
