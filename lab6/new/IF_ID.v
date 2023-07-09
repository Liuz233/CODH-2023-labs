`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:45:22
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
    input clk,
    input [31:0] pc_in,
    input [31:0] pc_plus_in,
    input [31:0] ir_in,
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus_out,
    output reg [31:0] ir_out,
    input clear,
    input enable
    );
    always @(posedge clk) begin
        if(clear) begin
            pc_out <= 0;
            pc_plus_out <= 0;
            ir_out <= 0;
        end
        else begin
            if(enable) begin
                pc_out <= pc_in;
                pc_plus_out <= pc_plus_in;
                ir_out <= ir_in;
            end
        end
    end
endmodule
