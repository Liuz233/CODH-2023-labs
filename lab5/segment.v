`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/05 20:49:31
// Design Name: 
// Module Name: segment
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


module segment(
    input clk,
    input rstn,
    input [31:0] cycles,
    output reg [7:0] seg,
    output reg [7:0] AN
    );
    wire pulse_50hz;
    reg [31:0] cnt;
    reg [3:0] seg_data;
    reg [2:0] cnt_seg;
    always@(posedge clk)
    begin
        if(rstn)
            cnt<=32'b0;
        else if(cnt>=1000)
            cnt<=32'b0;
        else 
            cnt<=cnt+32'b1;
    end
    assign pulse_50hz=(cnt==32'b1);
    always @(posedge clk)
    begin
        if(rstn)
            cnt_seg<=3'b000;
        else if(pulse_50hz)
            cnt_seg<=cnt_seg+1;
    end
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
        3'b000: begin AN<=8'b11111110;seg_data<=cycles[3:0] ; end
        3'b001: begin AN<=8'b11111101;seg_data<=cycles[7:4]; end
        3'b010: begin AN<=8'b11111011;seg_data<=cycles[11:8] ; end
        3'b011: begin AN<=8'b11110111;seg_data<=cycles[15:12]; end
        3'b100: begin AN<=8'b11101111;seg_data<=cycles[19:16]; end
        3'b101: begin AN<=8'b11011111;seg_data<=cycles[23:20]; end
        3'b110: begin AN<=8'b10111111;seg_data<=cycles[27:24]; end
        3'b111: begin AN<=8'b01111111;seg_data<=cycles[31:28]; end
        default:AN <= 8'b11110000;
        endcase
   
        if(rstn) 
        begin
            AN <= 8'b11111110;
            seg_data<=0;
        end
  
    end
endmodule
