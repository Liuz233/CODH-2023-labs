`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:43:10
// Design Name: 
// Module Name: Imm
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


module Imm(
    input [2:0] ImmGenWay,
    input [31:0] ir,
    output [31:0] imm
    );
    reg [31:0] Imm;
    always @(*) begin
        case (ImmGenWay)
            0: Imm = {{20{ir[31]}}, ir[31:20]};
            1: Imm = {ir[31:12], {12{1'b0}}};
            2: Imm = {{20{ir[31]}}, ir[31:25], ir[11:7]};
            3: Imm = {{20{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8]};
            4: Imm = {{19{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0};
            5: Imm = {{27{1'b0}}, ir[24:20]};
            default: Imm = 1;
        endcase
    end
    assign imm = Imm;
endmodule
