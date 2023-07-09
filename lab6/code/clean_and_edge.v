`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/05 13:30:22
// Design Name: 
// Module Name: clean
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


module jitter_clr (
    input clk,
    input button,
    output button_clean
);
    reg [3:0] cnt;
    always @(posedge clk) begin
        if(button == 1'b0) begin
            cnt <= 4'h0;
        end
        else if (cnt < 4'h8) begin
            cnt <= cnt + 1'b1;
        end
    end
    assign button_clean = cnt[3];
endmodule

module upper_edge (
    input clk,
    input button,
    output button_edge
);
    reg button_1, button_2;
    always @(posedge clk) begin
        button_1 <= button;
    end
    always @(posedge clk) begin
        button_2 <= button_1;
    end
    assign button_edge = button_1 & (~button_2);
endmodule

module double_edge (
    input clk,
    input button,
    output button_edge
);
    reg button_1, button_2;
    always @(posedge clk) begin
        button_1 <= button;
    end
    always @(posedge clk) begin
        button_2 <= button_1;
    end
    assign button_edge = button_1 & (~button_2) | (~button_1) & button_2;
endmodule
