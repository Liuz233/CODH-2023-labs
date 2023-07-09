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
    input cpu_clk,
    input cpu_rstn,
    //input [31:0] dra0,
    //output [31:0] drd0,
    input [5:0] rra0,
    output [31:0] rrd0,
    output [31:0] ctr_debug,
    //IF段
    output [31:0] npc,
    output [31:0] pc,
    output [31:0] ir,
    //IF/ID
    output [31:0] pc_id,
    output [31:0] ir_id,
    //ID/EX
    output [31:0] pc_ex,
    output [31:0] ir_ex,
    output [31:0] rrd1,
    output [31:0] rrd2,
    output [31:0] imm,
    //EX/MEM
    output [31:0] ir_mem,
    output [31:0] res,
    output [31:0] dwd,
    output reg cvalid,
    output [31:0] caddr,
    output [31:0] cdata,
    output io_we,
    output io_rd,
    output cpu_req_rw,
    input [31:0] dm_out,
    input cready,
    //MEM/WB
    output [31:0] ir_wb,
    output [31:0] drd,//数据寄存器读出结果
    output [31:0] res_wb,//ALU结果传递
    

    //WB
    output [31:0] rwd//写回寄存器堆数据
    );
    //reg [5:0] rra0=6'd31;
    //reg [31:0] dra0=32'b0;
    //......
    reg [31:0] PCD,PCD_plus4,IR;
    wire eFlush,dFlush;//同步清空
    wire ctrl;//同步清空==eFlush
    wire IF_ID_Write,PC_Write,we;//~dStall
    wire [31:0] pc_plus4, pc_jalr, pc_unjalr,pc_offset;//unjalr->branch/jal
    wire MUXsrc1,MUXsrc2;
    wire PCstall,Dstall,Estall,Mstall,Wflush;
    //ID
    wire [2:0] Branch;//3'b001 beq 3'b010 blt 3'b011 bltu 3'b100 jal 3'b101 jalr
    wire [5:0] EX;
    wire [1:0] M;
    wire [2:0] WB;

    reg [5:0] ID_EX_EX;
    reg  [1:0]ID_EX_M;
    reg  [2:0] ID_EX_WB,ID_EX_Branch;
    reg [31:0] PCE,PCE_plus4,A,B,Imm,IRE;
    //EX
    wire [1:0]SSrcA,SSrcB,SrcA;
    wire  SrcB;
    wire [31:0] AIN,BIN,Ain,Bin;//Ain为ALU输入
    
    wire [2:0] t,alut;

    reg [2:0] EX_MEM_WB;
    reg [1:0]EX_MEM_M;
    reg [31:0] PCM_plus4,Y,MDW,IRM;
    //MEM
    // wire [31:0] dm_out;//led_out;
    // assign led = led_out[15:0];
    wire [31:0] miss_count,total_count;
    //wire cready,cvalid,cpu_req_rw;
    wire valid;

    reg [2:0] MEM_WB_WB;
    reg [31:0] PCW_plus4,MDR,YW,IRW;

    //---------------------------------------------------
    assign ctr_debug = {cpu_rstn,eFlush,ctrl,{9'b0},ID_EX_Branch[2:0],ID_EX_EX[5:0],ID_EX_M[1:0],ID_EX_WB[2:0],EX_MEM_M[1:0],EX_MEM_WB[2:0],MEM_WB_WB[2:0]};
    // assign ctr_debug2 = total_count-miss_count;
    // assign ctr_debug3 = total_count;
    //IF
    reg32  PC(.clk(cpu_clk), .rstn(cpu_rstn), .D (npc), .en(PC_Write&&(!PCstall)), .Q(pc));
    dist_IM IM (
        .a(pc>>2),      // input wire [9 : 0] a
        .d(32'b0),      // input wire [31 : 0] d
        .clk(cpu_clk),  // input wire clk
        .we(1'b0),    // input wire we
        .spo(ir)  // output wire [31 : 0] spo
    );
    assign pc_plus4 = pc + 4;
    assign pc_jalr = res & ~1;
    MUX2 PCMUX2 (.a(pc_jalr), .b(pc_unjalr), .sel(MUXsrc1), .out(npc));
    MUX2 PCMUX1 (.a(pc_offset), .b(pc_plus4), .sel(MUXsrc2), .out(pc_unjalr));
    //IF/ID
    always@(posedge cpu_clk, posedge cpu_rstn)
    begin
        if(cpu_rstn )
        begin
            PCD <= 32'b0;
            PCD_plus4 <= 32'b0;
            IR <= 32'b0;
        end
        else if(Dstall)
        begin
            PCD <= PCD;
            PCD_plus4 <= PCD_plus4;
            IR <= IR;
        end
        else if(dFlush)
        begin
            PCD <= 32'b0;
            PCD_plus4 <= 32'b0;
            IR <= 32'b0;
        end
        else if(IF_ID_Write)
        begin
            PCD <= pc;
            PCD_plus4 <= pc_plus4;
            IR <= ir;
        end
    end
    //ID
    assign pc_id = PCD;
    assign ir_id = IR;
   control  Control (
        .IR(IR),
        .inst(IR[6:0]),
        .EX(EX[5:0]),
        .M(M),
        .WB(WB[2:0]),
        .Branch(Branch[2:0])
   );
    RF  u_RF (
    .clk                     ( cpu_clk ),
    .rstn                    ( cpu_rstn),
    .ra1                     ( IR [19:15]),
    .ra2                     ( IR [24:20]),
    .ra0                     ( rra0 ),
    .wa                      ( IRW   [11:7]  ),
    .wd                      ( rwd        ),
    .we                      ( we   ),

    .rd1                     ( rrd1 ),
    .rd2                     ( rrd2 ),
    .rd0                     ( rrd0 )
    );
    Immgen  u_Immgen (
    .ImmGen                  ( IR       [6:0] ),
    .IR                      ( IR      [31:0] ),

    .Imm                     ( imm     [31:0] )
    );
    //ID/EX
    always@(posedge cpu_clk, posedge cpu_rstn)
    begin
        if(cpu_rstn)
        begin
            ID_EX_WB <= 3'b0;
            ID_EX_M  <= 2'b0;
            ID_EX_EX <= 6'b0;
            ID_EX_Branch <=3'b0;
            PCE <= 32'b0;
            PCE_plus4 <= 32'b0;
            A  <= 32'b0;
            B <= 32'b0;
            Imm <= 32'b0;
            IRE <= 32'b0;
        end
        else if(Estall)
        begin
            ID_EX_WB <= ID_EX_WB;
            ID_EX_M  <= ID_EX_M;
            ID_EX_EX <= ID_EX_EX;
            ID_EX_Branch <=ID_EX_Branch;
            PCE <= PCE;
            PCE_plus4 <= PCE_plus4;
            A  <= A;
            B <= B;
            Imm <= Imm;
            IRE <= IRE;
        end
        else if(eFlush || ctrl)
        begin
                ID_EX_WB <= 3'b0;
                ID_EX_M  <= 2'b0;
                ID_EX_EX <= 6'b0;
                ID_EX_Branch <=3'b0;
                PCE <= 32'b0;
                PCE_plus4 <= 32'b0;
                A  <= 32'b0;
                B <= 32'b0;
                Imm <= 32'b0;
                IRE <= 32'b0;
        end
        else
        begin
            ID_EX_WB <= WB;
            ID_EX_M <= M;
            ID_EX_EX <= EX;
            ID_EX_Branch <= Branch;
            PCE <= PCD;
            PCE_plus4 <= PCD_plus4;
            A <= rrd1;
            B <= rrd2;
            Imm <= imm;
            IRE <= IR;
        end
            
    end 
    //EX
    assign pc_ex = PCE;
    assign ir_ex = IRE;
    MUX4 AinMUX (.a(A), .b(Y), .c(rwd), .d(32'b0), .sel(SSrcA), .out(AIN));
    MUX4 BinMUX (.a(B), .b(Y), .c(rwd), .d(32'b0), .sel(SSrcB), .out(BIN));
    MUX4 MUXA (.a(AIN), .b(PCE), .c(32'b0), .d(32'b0), .sel(ID_EX_EX[5:4]), .out(Ain));
    MUX2 MUXB (.a(BIN), .b(Imm), .sel(ID_EX_EX[3]), .out(Bin));
    ALU_32  ALU (
    .a                       ( Ain  ),
    .b                       ( Bin ),
    .f                       ( ID_EX_EX[2:0]),

    .y                       (  res    ),
    .t                       ( t      )
   );
   ALU_32  ALUimm (.a(PCE), .b({Imm[30:0],1'b0}), .f(3'b001), .y(pc_offset), .t( alut));
   //EX/MEM
    always@(posedge cpu_clk, posedge cpu_rstn)
    begin
        if(cpu_rstn)
        begin
            EX_MEM_WB <= 3'b0;
            EX_MEM_M  <= 2'b0;
            PCM_plus4 <= 32'b0;
            Y <= 32'b0;
            MDW <= 32'b0;
            IRM <= 32'b0;
        end
        else if(!Mstall)
        begin
            EX_MEM_WB <= ID_EX_WB;
            EX_MEM_M  <= ID_EX_M;
            PCM_plus4 <= PCE_plus4;
            Y <= res;
            MDW <= BIN;
            IRM <= IRE;
        end
    end 
    //MEM
    assign ir_mem = IRM;
    assign dwd = MDW;
    assign cpu_req_rw = EX_MEM_M[0];
    assign valid = EX_MEM_M[1];
    always@(*)
    begin
        if(Y[15:8]==8'h7f)  cvalid = 1'b0;//mmio
        else if(cready == 1'b0) cvalid = valid;
        else cvalid = 1'b0;
    end
    //assign cvalid=((cready==1'b0)?valid:1'b0);
    assign PCstall = (cvalid==1'b1 && cready==1'b0);
    assign Dstall = (cvalid==1'b1 && cready==1'b0);
    assign Estall = (cvalid==1'b1 && cready==1'b0);
    assign Mstall = (cvalid==1'b1 && cready==1'b0);
    assign Wflush = (cvalid==1'b1 && cready==1'b0);
    assign caddr = Y;
    assign cdata = MDW;
    assign io_rd = (Y[15:8]==8'h7f && IRM[6:0]==7'b0000011);
    assign io_we = (Y[15:8]==8'h7f && IRM[6:0]==7'b0100011);
    // DMS  u_DMS (
    // .cpu_clk                 ( cpu_clk            ),
    // .cpu_rstn                ( cpu_rstn           ),
    // .cvalid                  ( cvalid             ),
    // .a                       ( Y                 ),
    // .dpra                    ( dra0               ),
    // .d                       ( MDW          [31:0] ),
    // .cpu_req_rw              ( cpu_req_rw         ),

    // .spo                     ( dm_out         [31:0] ),
    // .dpo                     ( drd0         [31:0] ),
    // .miss                    ( miss_count   [31:0] ),
    // .total                   ( total_count  [31:0] ),
    // .cready                  ( cready             )
    // );
    //MEM/WB
    always@(posedge cpu_clk, posedge cpu_rstn)
    begin
        if(cpu_rstn)
        begin
            MEM_WB_WB <= 3'b0;
            PCW_plus4 <= 32'b0;
            MDR <= 32'b0;
            YW <= 32'b0;
            IRW <= 32'b0;
        end
        else 
        begin
            if(Wflush)
            begin
                MEM_WB_WB <= 3'b0;
                PCW_plus4 <= 32'b0;
                MDR <= 32'b0;
                YW <= 32'b0;
                IRW <= 32'b0;
            end
            else
            begin
                MEM_WB_WB <= EX_MEM_WB;
                PCW_plus4 <= PCM_plus4;
                MDR <= dm_out;
                YW <= Y;
                IRW <= IRM;
            end
        end
    end 
    //WB
    assign ir_wb = IRW;
    assign res_wb = YW;
    assign drd = MDR;
    MUX4 WBMUX (.a(PCW_plus4), .b(MDR), .c(YW), .d(32'b0), .sel(MEM_WB_WB[2:1]), .out(rwd));
    assign we = MEM_WB_WB[0];
    Branchcontrol  u_Branchcontrol (
    .zero                    ( t ),
    .Branch                  ( ID_EX_Branch   [2:0] ),

    .MUXsrc1                 ( MUXsrc1        ),
    .MUXsrc2                 ( MUXsrc2        ),
    .dFlush                  ( dFlush          ),
    .eFlush                  ( eFlush          )
    );
    ForwardingUnit  u_ForwardingUnit (
    .EX_MEM_WE               ( EX_MEM_WB[0]      ),
    .EX_MEM_RD               ( IRM[11:7]         ),
    .MEM_WB_WE               ( MEM_WB_WB[0]      ),
    .MEM_WB_RD               ( IRW[11:7] ),
    .rs1                     ( IRE [19:15] ),
    .rs2                     ( IRE [24:20] ),

    .SSrcA                   ( SSrcA      [1:0] ),
    .SSrcB                   ( SSrcB      [1:0] )
    );
    HazardUnit  u_HazardUnit (
    .IR                      ( IR           [31:0] ),
    .IRd                     ( IRE          [31:0] ),

    .ctrl                    ( ctrl                ),
    .PCWrite                 ( PC_Write             ),
    .IF_ID_Write             ( IF_ID_Write         )
    );
endmodule
