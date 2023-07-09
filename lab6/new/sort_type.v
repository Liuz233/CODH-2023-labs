`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/23 14:34:19
// Design Name: 
// Module Name: sort_type
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


module sort_type(
    input [6:0] opcode,
    output reg [2:0] type
    );
    // type
    // 0: R-type add, sub, and, or, xor
    // 1: I-type addi, slli, srli, srai 
    // 2: U-type auipc, lui
    // 3: S-type sw
    // 4: B-type beq, blt, bltu
    // 5: J-type jal
    // 6: I-type lw
    // 7: I-type jalr
    always @(*) begin
        case (opcode)
            // R-type
            7'b0110011: type = 0;
            // I-type
            // addi, slli, srli, srai
            7'b0010011: type = 1;
            // lw
            7'b0000011: type = 6;
            // jalr
            7'b1100111: type = 7;
            // U-type
            // auipc
            7'b0010111: type = 2;
            // lui
            7'b0110111: type = 2;
            // S-type sw
            7'b0100011: type = 3;
            // B-type
            7'b1100011: type = 4;
            // J-type
            7'b1101111: type = 5;
            default: type = 0;
        endcase
    end
endmodule
