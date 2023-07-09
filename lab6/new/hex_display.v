`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/05 13:32:10
// Design Name: 
// Module Name: hex_display
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

//4bit数据显示（1个数码管）
module hex_convert (
    input [3:0] data_in,
    output reg A,B,C,D,E,F,G
);
    always @(*) begin
        case (data_in)
            0: {A,B,C,D,E,F,G} = -7'b111_1110-1;
            1: {A,B,C,D,E,F,G} = -7'b011_0000-1;
            2: {A,B,C,D,E,F,G} = -7'b110_1101-1;
            3: {A,B,C,D,E,F,G} = -7'b111_1001-1;
            4: {A,B,C,D,E,F,G} = -7'b011_0011-1;
            5: {A,B,C,D,E,F,G} = -7'b101_1011-1;
            6: {A,B,C,D,E,F,G} = -7'b101_1111-1;
            7: {A,B,C,D,E,F,G} = -7'b111_0000-1;
            8: {A,B,C,D,E,F,G} = -7'b111_1111-1;
            9: {A,B,C,D,E,F,G} = -7'b111_1011-1;
            10: {A,B,C,D,E,F,G} = -7'b111_0111-1;
            11: {A,B,C,D,E,F,G} = -7'b001_1111-1;
            12: {A,B,C,D,E,F,G} = -7'b100_1110-1;
            13: {A,B,C,D,E,F,G} = -7'b011_1101-1;
            14: {A,B,C,D,E,F,G} = -7'b100_1111-1;
            15: {A,B,C,D,E,F,G} = -7'b100_0111-1;
        endcase
    end
endmodule
//16bit数据显示（4个数码管）
module hex16_convert (
    input clk,
    input [15:0] data_in,
    output A,B,C,D,E,F,G,
    output reg [7:0] AN = 8'b1111_1110
);
    wire clk_100k;              //分时时钟
    CLK_100kHZ clk_inst(
        .clk (clk),
        .led (clk_100k)
    );
    reg [3:0] input_data;

    always @(posedge clk_100k) begin
        AN[7:4] <= 4'b1111;
        case (AN[3:0])
            4'b1110: AN[3:0] <= 4'b1101;
            4'b1101: AN[3:0] <= 4'b1011;
            4'b1011: AN[3:0] <= 4'b0111;
            4'b0111: AN[3:0] <= 4'b1110;
            default: AN[3:0] <= 4'b1110;
        endcase
    end
    always @(*) begin
        case (AN[3:0])
            4'b1110: input_data = data_in[3:0];
            4'b1101: input_data = data_in[7:4];
            4'b1011: input_data = data_in[11:8];
            4'b0111: input_data = data_in[15:12];
            default: input_data = data_in[3:0];
        endcase 
    end
    hex_convert hex_inst(
        .data_in (input_data),
        .A (A),
        .B (B),
        .C (C),
        .D (D),
        .E (E),
        .F (F),
        .G (G)
    );
endmodule
//32bit数据显示（8个数码管）
module hex32_convert (
    input clk,
    input [31:0] data_in,
    output A,B,C,D,E,F,G,
    output reg [7:0] AN = 8'b1111_1110
);
    wire clk_100k;              //分时时钟
    CLK_100kHZ clk_inst(
        .clk (clk),
        .led (clk_100k)
    );
    reg [3:0] input_data;

    always @(posedge clk_100k) begin
        case (AN[7:0])
            8'b1111_1110: AN <= 8'b1111_1101;
            8'b1111_1101: AN <= 8'b1111_1011;
            8'b1111_1011: AN <= 8'b1111_0111;
            8'b1111_0111: AN <= 8'b1110_1111;
            8'b1110_1111: AN <= 8'b1101_1111;
            8'b1101_1111: AN <= 8'b1011_1111;
            8'b1011_1111: AN <= 8'b0111_1111;
            8'b0111_1111: AN <= 8'b1111_1110;
            default: AN <= 8'b1111_1110;
        endcase
    end
    always @(*) begin
        case (AN[7:0])
            8'b1111_1110: input_data = data_in[3:0];
            8'b1111_1101: input_data = data_in[7:4];
            8'b1111_1011: input_data = data_in[11:8];
            8'b1111_0111: input_data = data_in[15:12];
            8'b1110_1111: input_data = data_in[19:16];
            8'b1101_1111: input_data = data_in[23:20];
            8'b1011_1111: input_data = data_in[27:24];
            8'b0111_1111: input_data = data_in[31:28];
            default: input_data = data_in[3:0];
        endcase 
    end
    hex_convert hex_inst(
        .data_in (input_data),
        .A (A),
        .B (B),
        .C (C),
        .D (D),
        .E (E),
        .F (F),
        .G (G)
    );
endmodule

module CLK_100kHZ (
    input clk,
    output reg led = 0
);
    reg [9:0] cnt = 10'h0;
    wire pulse_100kHZ;
    always @(posedge clk) begin
        if(cnt >= 1000)
        cnt <= 10'h0;
        else
        cnt <= cnt + 10'h1;
    end
    assign pulse_100kHZ = (cnt == 10'h1);
    always @(posedge clk) begin
    if(pulse_100kHZ)
    led <= ~led;
    end
endmodule