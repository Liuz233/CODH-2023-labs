# Lab 4 report

## 实验目的与内容

* 理解单周期CPU的结构和工作原理
* 掌握单周期CPU的设计和调试方法
* 熟练掌握数据通路和控制器的设计和verilog描述方法
* 设计单周期RISC-V CPU,可执行18条指令
* 集成串行调试单元，实现对CPU的下载测试

## 逻辑设计

### part1

单周期CPU数据通路如图所示

注意mmio的设计，led是输出端口，在sw时特殊判断，计数器接输入端口，在lw时特殊判断。那么在最终测试时，需要在汇编代码最后写入专门的sw指令和lw指令来展示结果，这一点在检查代码时已经实现。

![image-20230503140502898](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230503140502898.png)

<center>图1:单周期CPU数据通路

这里只贴出CPU顶层代码，各模块代码见附件

```verilog
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


module CPU(
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
    // input [31:0] din,   
    // input we_dm,
    // input we_im,
    // input clk_ld,
    // input debug,
    output [15:0] led
    );
    reg we_dm=0,we_im=0,clk_ld=0,debug=0;//这里其实是SDU输入信号，为了仿真方便，先将这些输入信号无视
    reg [31:0] din=32'b0;
    reg [31:0] addr=32'b0;
    wire clk;
    wire [31:0] led_out,num;
    wire [31:0] wd,pc_plus4,pc_plusimm,Imm,pc_unjalr;
    wire [6:0] ALUOP,ImmGen;
    wire [1:0] SrcA,Muxsel;
    wire [1:0] MemtoReg;//0:y,1:mdr,2:pc+4
    wire [2:0] Branch;//1:beq 2:blt 3:bltu 4:jal
    wire MMIOSIG,Registerwrite,SrcB,led_we,mmio;
    wire alu1t,alu2t;
    wire EN,DM_we;
    wire Memwe,JALMux;//Memwe for dm
    wire [31:0] ALU_a;
    wire [31:0] ALU_b;
    wire [2:0] f,t;
    wire [31:0] DM_a,DM_d;
    wire pcmuxsel1,pcmuxsel2;
    assign clk=(debug==1)?clk_ld:clk_cpu;
    assign pc_chk=pc;
    assign CTL={{5'b0},Registerwrite,SrcA[1:0],SrcB,ALUOP[6:0],Branch[2:0],MemtoReg[1:0],ImmGen[6:0],Memwe,EN,JALMUX,MMIOSIG};
    assign IMM=Imm;
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
    assign DM_a=(debug==1)?addr:((Y-32'h00002000)>>2);//复用，注意数据段从x2000开始，但在CPu中从0开始，有一个换算
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

```

### part2

和SDU顶层接线即可，为了显示方便，对CPU额外加了一个计数器，直接连到输出，以及程序结束信号，计数器的值通过其他模块处理，输出到七段数码管，程序结束信号输出到LED16R

## 仿真结果与分析

![image-20230503140919144](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230503140919144.png)

<center>图2:仿真结果

仿真结果如图所示，经过与测试程序的汇编代码逐条比对，功能全部正确实现

## 电路设计与分析

### part1

![image-20230503141226448](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230503141226448.png)

<center>图3:单周期CPURTL电路

### part2

![image-20230506145206608](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506145206608.png)

<center>图4:CPU_SDU顶层电路图</center>

右下角模块为专门处理七段数码管的模块

![image-20230506145911348](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506145911348.png)

<center>图5:综合电路图



![image-20230506150044721](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506150044721.png)

<center>图6:电路资源使用情况

![image-20230506150240244](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506150240244.png)

![image-20230506150415280](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506150415280.png)

<center>图7:电路性能

由此可见，电路最长建立时间与七段数码管处理模块有关

## 测试结果与分析

首先下载测试预先写好的指令测试程序，经过测试，t6寄存器为0，说明可以初步认为指令全部正确执行，前面的仿真也可以验证。另外程序使用时钟数为0x39

![image-20230506153030969](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506153030969.png)

<center>图8:指令测试程序结束的数据通路和寄存器值

![image-20230506153119615](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506153119615.png)

<center>图9:指令测试程序执行周期

下面导入排序程序所用的指令以及数据

![image-20230506153438057](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506153438057.png)

<center>图10:导入的需要排序的数据

输入G执行

![image-20230506153747420](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506153747420.png)

<center>图11:升序排序后结果

![image-20230506153805385](C:\Users\Liuz\Desktop\CODH lab\lab4\Lab4 report.assets\image-20230506153805385.png)

<center>图12:排序所用时钟周期数

## 总结

本次实验完成了单周期CPU以及CPU和SDU的整合和调试，把数据通路设计出来非常重要，设计出来可以先试着模拟几条指令，这样用代码写出来就是基本正确的了

出现过以下Bug

* localparam位宽不匹配

* PC+imm没有考虑jal的情况

* RF的sp寄存器没有预先赋值，且要考虑越界的情况
* 接入模块的rstn取反
* 汇编代码中用了没有设计的指令，比如mul,bge....

