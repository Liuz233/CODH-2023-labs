`timescale 1ns / 1ps

module test_sdu_dm(
    input clk,
    input rstn,
    input run,//
    output done,
    output [15:0] cycles,
    input rxd,
    output txd
    // output check_rstn,
    // output check_run
    );

    wire [31:0] addr;//[31:0]
    wire [31:0] dout;
    wire [31:0] din;
    wire we;
    wire clk_ld;
   // wire rstns;
    //wire runs;
    //wire check_rstn;
    // assign check_rstn=rstns;
    // assign check_run=runs;
    SRT  u_SRT (
    .clk                     ( clk          ),
    .rstn                    ( ~rstn           ),
    .Run                     ( run            ),
    .addr                    ( addr          ),
    .din                     ( din            ),
    .we                      ( we             ),
    .clk_ld                  ( clk_ld         ),

    .done                    ( done           ),
    .cycles                  ( cycles         ),
    .dout                    ( dout           )
    );
        
    sdu_dm(
        .clk(clk),
        .rstn(rstn),
        .rxd(rxd),
        .txd(txd),
        .addr(addr),
        .dout(dout),
        .din(din),
        .we(we),
        .clk_ld(clk_ld)
    );
    
endmodule
