`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/09 12:50:54
// Design Name: 
// Module Name: tb_RF
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


module tb_RF(

    );
    parameter PERIOD  = 10;


// RF Inputs
reg   clk                                  = 0 ;
reg   [4:0]  ra1                           = 0 ;
reg   [4:0]  ra2                           = 0 ;
reg   [4:0]  wa                            = 0 ;
reg   [31:0]  wd                           = 0 ;
reg   we                                   = 1 ;

// RF Outputs
wire  [31:0]  rd1                          ;
wire  [31:0]  rd2                          ;


initial
begin
    clk=0;
    forever #(PERIOD/2)  clk=~clk;
end

RF  u_RF (
    .clk                     ( clk         ),
    .ra1                     ( ra1  [4:0]  ),
    .ra2                     ( ra2  [4:0]  ),
    .wa                      ( wa   [4:0]  ),
    .wd                      ( wd   [31:0] ),
    .we                      ( we          ),

    .rd1                     ( rd1  [31:0] ),
    .rd2                     ( rd2  [31:0] )
);
initial
begin
    ra1=0;
    ra2=0;
    wa=0;
    wd=0;
    repeat(42)
    begin
        @(posedge clk)
        begin
            wa=$random;
            ra1=wa;
            ra2=wa;
            wd=$random;
        end
    end
    #5 wa=0; ra1=0; ra2=0;
    #10
    $finish;
end
endmodule
