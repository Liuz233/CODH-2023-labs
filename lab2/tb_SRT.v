`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 23:37:20
// Design Name: 
// Module Name: tb_SRT
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


`timescale  1ns / 1ps

module tb_SRT();

// SRT Parameters
parameter PERIOD  = 10;


// SRT Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   Run                                  = 0 ;

// SRT Outputs
wire  done                                 ;
wire  [15:0]  cycle                        ;


initial
begin
    clk=0;
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rstn=0; Run=0;
    #(PERIOD*2) rstn  =  1;
    #(PERIOD) rstn=0;
    #(PERIOD*2) Run=1;
    #(PERIOD) Run=0; 
    #(PERIOD*1147483)  rstn=1;//二次启动，注意先rstn,并复原，再run
    #(PERIOD) rstn=0;
    #(PERIOD*2) Run=1;
    #(PERIOD) Run=0;
end

SRT  u_SRT (
    .clk                     ( clk           ),
    .rstn                    ( rstn          ),
    .Run                     ( Run           ),

    .done                    ( done          ),
    .cycle                   ( cycle  [15:0] )
);

endmodule
