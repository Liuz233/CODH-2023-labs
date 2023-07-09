`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 16:28:31
// Design Name: 
// Module Name: reg32
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


module reg32(
    input clk,
    input rstn,
    input [31:0] D,
    input en,
    output reg [31:0] Q
    );
    always@(posedge clk,posedge rstn)
    begin
        if(rstn)
            Q<=32'b0;
        else if(en)
            Q<=D;
        else
            Q<=Q;
    end
endmodule
