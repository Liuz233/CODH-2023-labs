`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 14:23:20
// Design Name: 
// Module Name: Dmem
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


module Dmem #(
    parameter DATA_WIDTH = 32,
              ADDR_WIDTH = 10,
              INIT_FILE = "C:/Users/Liuz/Desktop/CODH lab/lab6/data.txt"             
)(
    input clk,
    input rstn,
    input [ADDR_WIDTH-1:0] addr,
    input rw,
    input mvalid,
    input [127:0] din,
    output reg [127:0] dout,
    output reg mready
    //input [ADDR_WIDTH-1:0] dpra,
    //output [DATA_WIDTH-1:0] dpo
    );
    //reg [ADDR_WIDTH-1:0] addr_r;
    reg [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];
    initial $readmemh(INIT_FILE , ram);
    //assign dpo=ram[dpra];
    always @(posedge clk, posedge rstn)
    begin
        if(rstn) mready <= 1'b1;//准备好了
        else if(mvalid && rw==1'b1 && mready)
        begin
            ram[addr+3]=din[127:96];
            ram[addr+2]=din[95:64];
            ram[addr+1]=din[63:32];
            ram[addr]=din[31:0];
            mready<=1'b0;
        end
        else if(mvalid && rw==1'b0 && mready)
        begin
            dout = {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr]};
            mready<=1'b0;
        end
        else if(!mready)//下一个周期就等待好，不用等待valid，提高效率
        begin
            mready<=1'b1;//准备好了
        end
    end
endmodule
