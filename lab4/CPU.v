`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/30 11:40:53
// Design Name: 
// Module Name: CPU
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


module cpu_top(
    input clk_cpu,
    input rstn,
    output [31:0] pc_chk,
    output [31:0] npc,
    output [31:0] pc,
    output [31:0] IR,
    output [31:0] CTL,
    output [31:0] A,
    output [31:0] B,
    output [31:0] IMM,
    output [31:0] Y,
    output [31:0] MDR,
    //input [31:0] addr,
    output [31:0] dout_rf,
    output [31:0] dout_dm,
    output [31:0] dout_im,
    //input [31:0] din,   
    // input we_dm,
    // input we_im,
    // input clk_ld,
    // input debug,
    output [15:0] led,
    output reg [31:0] cycles,
    output done
    );
    reg we_dm=0,we_im=0,debug=0;
    reg clk_ld;
    reg [31:0] addr=32'b0;
    reg [31:0]din=32'b0;
    wire clk;
    wire [31:0] led_out,num;
    wire [31:0] wd,pc_plus4,pc_plusimm,Imm,pc_unjalr;
    wire [6:0] ALUOP,ImmGen;
    wire [1:0] SrcA,Muxsel;
    wire [1:0] MemtoReg;//0:y,1:mdr,2:pc+4
    wire [2:0] Branch;//1:beq 2:blt 3:bltu 4:jal
    wire MMIOSIG,Registerwrite,SrcB,led_we,mmio;
    wire [2:0]alu1t,alu2t;
    wire EN,DM_we;
    wire Memwe,JALMux;//Memwe for dm
    wire [31:0] ALU_a;
    wire [31:0] ALU_b;
    wire [2:0] f,t;
    wire [31:0] DM_a,DM_d;
    wire pcmuxsel1,pcmuxsel2;
    assign clk=(debug==1)?clk_ld:clk_cpu;
    assign pc_chk=pc;
    assign done=(pc==npc);//
    always@(posedge clk_cpu,posedge rstn)
    begin
        if(rstn)
            cycles<=32'b0;
        else if(pc!=npc)
            cycles<=cycles+1;
        else 
            cycles<=cycles;
    end
    assign CTL=wd;//{wd[3:0],{1'b0},mmio,Registerwrite,SrcA[1:0],SrcB,ALUOP[6:0],Branch[2:0],MemtoReg[1:0],ImmGen[6:0],Memwe,EN,JALMUX,MMIOSIG};
    assign IMM=Imm;
    assign led=led_out;
    control  u_control (
    .IR                      ( IR           [31:0] ),
    .inst                    ( IR           [6:0]  ),

    .Registerwrite           ( Registerwrite         ),
    .ImmGen                  ( ImmGen         [6:0]  ),
    .ALUOP                   ( ALUOP          [6:0]  ),
    .EN                      ( EN                    ),
    .MMIOSIG                 ( MMIOSIG               ),
    .MemtoReg                ( MemtoReg       [1:0]  ),
    .SrcB                    ( SrcB                  ),
    .SrcA                    ( SrcA           [1:0]  ),
    .Branch                  ( Branch         [2:0]  ),
    .JALMUX                  ( JALMUX                ),
    .Memwe                   ( Memwe                 )
    );
    reg32  PC(
    .clk                     ( clk_cpu          ),//?
    .rstn                    ( rstn         ),
    .D                       ( npc ),
    .en                      ( 1           ),
    .Q                       ( pc )
    );
    ALU_32  PC_4 ( .a( pc), .b (32'h4), .f(3'b001), .y(pc_plus4), .t( alu1t));//pc+4
    ALU_32  ALUimm (.a( pc), .b({Imm[30:0],1'b0}), .f(3'b001), .y(pc_plusimm), .t( alut2));
    Branchcontrol  u_Branchcontrol (.zero(t), .Branch(Branch), .sel(pcmuxsel1));
    MUX2 PCMUX1(.a(pc_plus4), .b(pc_plusimm), .sel(pcmuxsel1), .out(pc_unjalr));
    MUX2 PCMUX2(.a(pc_unjalr), .b(Y & ~1), .sel(JALMUX), .out(npc));
    dist_IM IM (
    .a(addr),        // input wire [9 : 0] a
    .d(din),        // input wire [31 : 0] d
    .dpra(pc>>2),  // input wire [9 : 0] dpra
    .clk(clk),    // input wire clk
    .we(we_im),      // input wire we
    .spo(dout_im),    // output wire [31 : 0] spo
    .dpo(IR)    // output wire [31 : 0] dpo
    );
    RF  u_RF (
    .clk                     ( clk         ),
    .ra1                     ( IR [19:15]  ),
    .ra2                     ( IR [24:20]  ),
    .ra0                     ( addr         ),
    .wa                      ( IR   [11:7]  ),
    .wd                      ( wd           ),
    .we                      ( Registerwrite   ),

    .rd1                     ( A ),
    .rd2                     ( B ),
    .rd0                     ( dout_rf )
    );
    Immgen Imm_gen(
        .ImmGen (ImmGen),
        .IR (IR),
        .Imm (Imm)
    );
    ALU_CONTROL  ALU_control (
    .ALUOP                   ( ALUOP    ),
    .IR                      ( IR       ),

    .f                       ( f        )
    );
    MUX4 ALUMUX1 (.a(pc), .b(A), .c(0), .d(0), .sel(SrcA), .out(ALU_a));
    MUX2 ALUMUX2 (.a(B), .b(Imm), .sel(SrcB), .out(ALU_b));
    ALU_32  ALU (
    .a                       ( ALU_a  ),
    .b                       ( ALU_b ),
    .f                       ( f     ),

    .y                       (  Y     ),
    .t                       ( t      )
   );
   assign DM_a=(debug==1)?addr:((Y-32'h00002000)>>2);
   assign DM_d=(debug==1)?din:B;
   assign DM_we=(debug==1)?we_dm:Memwe;
   dist_DM DM (
   .a(DM_a),      // input wire [9 : 0] a
   .d(DM_d),      // input wire [31 : 0] d
   .clk(clk),  // input wire clk
   .we(DM_we),    // input wire we
   .spo(MDR)  // output wire [31 : 0] spo
    );
    assign dout_dm=MDR;
    MMIOcontrol  mmio_control (
    .MMIOSIG                 ( MMIOSIG         ),
    .addr                    ( Y               ),
    .led_we                  ( led_we          ),
    .mmio                    ( mmio            )
    );
    reg32  LED(.clk(clk_cpu), .rstn(rstn), .D(B), .en(led_we), .Q(led_out));
    Count clk_num(.clk(clk_cpu), .en(EN), .init(32'b0), .clear(rstn), .Q(num ));
    MUXcontrol  mux_control (.MemtoReg(MemtoReg[1:0] ), .mmio (mmio ), .sel(Muxsel));
    MUX4 WDMUX (.a(Y), .b(MDR), .c(num), .d(pc_plus4), .sel(Muxsel), .out(wd));
endmodule
