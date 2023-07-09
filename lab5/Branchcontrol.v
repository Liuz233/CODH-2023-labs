`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/02 14:37:52
// Design Name: 
// Module Name: Branchcontrol
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


module Branchcontrol(
    input [2:0] zero,
    input [2:0] Branch,//3'b001 beq 3'b010 blt 3'b011 bltu 3'b100 jal 3'b101 jalr
    output reg MUXsrc1,
    output reg MUXsrc2,
    output reg dFlush,
    output reg eFlush
    );
    always@(*)
    begin
        MUXsrc1=1'b1; MUXsrc2=1'b1;
        dFlush = 1'b1; eFlush = 1'b1;
        if(Branch==3'b101) begin MUXsrc1=1'b0; MUXsrc2=1'b1; end
        else if(Branch==3'b100) begin MUXsrc1=1'b1; MUXsrc2=1'b0; end
        else if(Branch==3'b001&&zero[0]) begin MUXsrc1=1'b1; MUXsrc2=1'b0; end
        else if(Branch==3'b010&&zero[1]) begin MUXsrc1=1'b1; MUXsrc2=1'b0; end
        else if(Branch==3'b011&&zero[2]) begin MUXsrc1=1'b1; MUXsrc2=1'b0; end
        else begin MUXsrc1=1'b1; MUXsrc2=1'b1; dFlush = 1'b0; eFlush = 1'b0;end//不是跳转
    end
endmodule
