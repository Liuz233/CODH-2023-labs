`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/02 10:53:10
// Design Name: 
// Module Name: MMIOcontrol
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


module MMIOcontrol(
    input MMIOSIG,
    input [31:0] addr,
    output reg led_we,
    output reg mmio
    );
    always@(*)
    begin
        if(MMIOSIG==1&&addr==32'h00007f00) //led
        begin
            led_we=1;
            mmio=0;
        end
        else if(MMIOSIG==1&&addr==32'h00007f20)//clk
        begin
            led_we=0;
            mmio=1;
        end
        else 
        begin
            led_we=0;
            mmio=0;
        end
    end
endmodule
