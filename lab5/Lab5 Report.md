# Lab 5 report

### 实验目的与内容

* 理解流水线CPU的结构和工作原理
* 掌握流水线CPU的设计和调试方法，特别是流水线中的数据相关和控制相关的处理
* 熟练掌握数据通路和控制器的设计和描述方法

最终设计完整的有数据和控制相关处理的流水线CPU

### 逻辑设计

数据通路如下

![扫描全能王 2023-05-22 17.01 (1)](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\扫描全能王 2023-05-22 17.01 (1).jpg)

<center>图1:多周期流水线CPU数据通路

其中ForwardingUnit模块用于解决部分数据相关问题，HazardUnit用于解决Load-use数据相关，BranchControl用于处理跳转指令

下面只贴出Control模块，其他代码见附件

```verilog
`timescale 1ns / 1ps

module control(
    input [31:0] IR,
    input [6:0] inst,
    output reg [5:0] EX,//SrcA[1:0],SrcB,f[2:0]
    output reg M,//MemWrite
    output reg [2:0] WB,//MUXSrc3[1:0],we,
    output reg [2:0] Branch
    );
    wire [2:0] f;
    localparam [6:0]    OP=7'b0110011,
                        OPIMM=7'b0010011,
                        LUI=7'b0110111,
                        AUIPC=7'b0010111,
                        LOAD=7'b0000011,
                        STORE=7'b0100011,
                        BRANCH=7'b1100011,
                        JAL=7'b1101111,
                        JALR=7'b1100111;
    ALU_CONTROL  u_ALU_CONTROL (
        .ALUOP                   (inst),
        .IR                      ( IR ),
        .f                       ( f )
    );
    always@(*)
    begin
        EX = 6'b0;
        M = 1'b0;
        WB = 3'b0;
        Branch = 3'b00;
        case(inst)
            OP:begin
                EX = {{3'b000},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            OPIMM:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            LUI:begin
                EX = {{3'b101},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            AUIPC:begin
                EX = {{3'b011},f[2:0]};
                M = 1'b0;
                WB = 3'b101;
            end
            LOAD:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b0;   
                WB = 3'b011;
            end
            STORE:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b1;
                WB = 3'b000;
            end
            BRANCH:begin
                EX = {{3'b000},f[2:0]};//rs1-rs2
                M = 1'b0;
                WB = 3'b000;
                if(IR[14:12]==3'b000) Branch=3'b001;//beq
                else if(IR[14:12]==3'b100) Branch=3'b010;//blt
                else if(IR[14:12]==3'b110) Branch=3'b011;//bltu
            end
            JAL:begin
                EX = {{3'b000},f[2:0]};//不需要alu
                M = 1'b0;
                WB = 3'b001;
                Branch=3'b100;//jal
            end
            JALR:begin
                EX = {{3'b001},f[2:0]};
                M = 1'b0;
                WB = 3'b001;
                Branch = 3'b101;//jalr
            end
            default:begin
                EX = 6'b0;
                M = 1'b0;
                WB = 3'b0;
                Branch = 3'b00;
            end
        endcase
    end
endmodule

```



### 仿真结果与分析

仿真结果如图所示

![image-20230522170755632](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230522170755632.png)

<center>图2:仿真结果

在测试程序中，如果全部指令正确，则R[31]的值恒为0，这里令rra0为31，经过bug修复后，rrd0恒为0，说明测试结果正确

### 电路设计与分析

多周期流水线CPU的RTL电路图如图所示

![image-20230522171432376](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230522171432376.png)

<center>图3:CPU RTL电路

![image-20230522171818966](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230522171818966.png)

<center>图4:综合电路图

![image-20230524083537374](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230524083537374.png)

<center>图5:电路资源使用情况

![image-20230524083641628](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230524083641628.png)

<center>图6:时间资源使用情况

### 测试结果与分析

![image-20230524082049839](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230524082049839.png)

<center>图7:测试程序上版

根据测试程序上版结果，程序运行结束时，x31中内容为0，说明指令全部测试正确

![image-20230524083014597](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230524083014597.png)

<center>图8:排序前</center>

![image-20230524083120666](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230524083120666.png)

<center>图9:排序后

排序后10个数变为升序，说明程序正确

![image-20230524083330520](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\image-20230524083330520.png)

<center>图10:时钟结果

同时时钟数显示25d，说明MMIO功能正确

### 总结

本次实验做了多周期流水线CPU，同时解决了结构相关、数据相关、跳转相关，掌握了关于多周期流水线的设计，提升了vivado编程能力

**出现的bug**

Branch用错

PCE赋值赋错

IRE用成IR

EX_MEM_M用成ID_EX_M

clk信号接错

寄存器的结构相关

**rstn eFlush ctrl同步异步信号共用**