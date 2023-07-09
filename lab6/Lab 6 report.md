# Lab 6 report

### 实验目的与内容

* 掌握Cache基本原理、结构、设计和调试方法
* 掌握CPU输入/输出地编址和控制方式
* 熟练掌握数据通路和控制器地设计和描述方法

修改LabH5流水线CPU，添加数据缓存(Dcache)和输入/输出单元(Input/Output Unit,IOU)

编写测试程序，排序可变长度随机数组，评估排序耗时和Cache命中率

### 逻辑设计

![1](C:\Users\Liuz\Desktop\CODH lab\lab5\Lab5 Report.assets\扫描全能王 2023-05-22 17.01 (1).jpg)

<center>图1:数据通路

数据通路依然使用多周期流水线CPU，不同的是原先的数据存储器使用了cache+bram，同时mmio模块封装为IOU

由于Cache读写可能需要多个周期，涉及多种情况，一方面要在流水线中加入Stall信号，在cache读取时，让流水线前面stall住，最后一段清空，防止无效数据流入后面流水线

![image-20230620234637566](C:\Users\Liuz\AppData\Roaming\Typora\typora-user-images\image-20230620234637566.png)

<center>图2:Cache状态机

下面是部分Dcache代码，其余代码见附件

```verilog
 always@(posedge clk,posedge rstn)
    begin
        if(rstn) 
            state<=IDLE;
        else   
            state<=next_state;
    end
    always@(*)
    begin
        en1=1'b0;en2=1'b0;
        case(state)
            IDLE: if(cvalid)
                    begin
                    en1=1'b1;//总次数+1
                    next_state=CompareTag;
                    end
                else
                    next_state=IDLE;
            CompareTag: if(hit)
                        next_state=IDLE;
                        else begin
                        en2=1'b1;//未命中计数
                        if(cache_data[cpu_req_index][V:D]==2'b11)
                                next_state=WriteBack;
                        else
                                next_state=Allocate;
                        end
            Allocate: if(!mready)
                        next_state=CompareTag;
                else 
                        next_state=Allocate;
            WriteBack: if(!mready)
                        next_state=Allocate;
                else   
                        next_state=WriteBack;
            default:next_state=IDLE;
        endcase
    end
    always@(posedge clk,posedge rstn)
    begin
        if(rstn) 
            miss<=32'b0;
        else if(en2)//未命中计数
            miss<=miss+32'b1;

    end
    always@(posedge clk,posedge rstn)
    begin
        if(rstn) 
            total<=32'b0;
        else if(en1)//未命中计数
            total<=total+32'b1;

    end
    always@(*)
    begin
        if(state==CompareTag)
        begin
            if(cache_data[cpu_req_index][131]&&cache_data[cpu_req_index][TagMSB:TagLSB]==cpu_req_tag)
                hit=1'b1;
            else   
                hit=1'b0;
        end 
        else hit=1'b0;//
    end
    always@(posedge clk)
    begin
        if(state==Allocate)
        begin
            if(mready)//准备好了
            begin
                mem_addr<={addr[9:2],2'b00};
                mem_req_rw<=1'b0;
                mvalid<=1'b1;
            end
            else
            begin
                mvalid<=1'b0;
                cache_data[cpu_req_index][BlockMSB:BlockLSB]<=dout;
                cache_data[cpu_req_index][V:D]<=2'b10;
                cache_data[cpu_req_index][TagMSB:TagLSB]<=cpu_req_tag;
            end
        end
        else if(state==WriteBack)
        begin
            if(mready)
            begin
                mem_addr<={cache_data[cpu_req_index][TagMSB:TagLSB],cpu_req_index,2'b00};
                mem_req_rw<=1'b1;
                din<=cache_data[cpu_req_index][BlockMSB:BlockLSB];
                mvalid<=1'b1;
            end
            else
            begin
                mvalid<=1'b0;
            end
        end
        else
        begin
            mvalid<=1'b0;
        end
    end
    always@(posedge clk)
    begin
        if(state==CompareTag&&hit)
        begin
            if(cpu_req_rw==1'b0)//read hit
            begin
                cready<=1'b1;
                spo<=cache_data[cpu_req_index][cpu_req_offset*32 +:32];
            end
            else//write hit
            begin
                cready<=1'b1;
                cache_data[cpu_req_index][cpu_req_offset*32 +:32]=d;
                cache_data[cpu_req_index][D]=1'b1;
            end
        end
        else   
            cready<=1'b0;
    end
```

### 仿真结果与分析

单独针对cache仿真，构造了数据涉及读命中，读未命中，写命中，写未命中的情况

仿真结果如下，注意到cache需要多个周期

![屏幕截图 2023-06-12 164632](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\屏幕截图 2023-06-12 164632.png)

<center>图3:仿真结果

### 电路设计与分析

加入IOU和cahce后RTL电路图如图所示

![image-20230620235645919](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230620235645919.png)

<center>图4:RTL电路图

![image-20230620235750148](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230620235750148.png)

<center>图5:IOU模块电路图



![image-20230621000156084](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230621000156084.png)

<center>图6:电路资源使用情况

注意到使用了大量的LUT,导致综合时间很长。这里主要在于cache和bram的接口，比如原先我在bram上加入了异步读的端口，导致bram根本无法生成真实的块存储器，从而使用了大量LUT，甚至无法综合出来。

![image-20230621000607318](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230621000607318.png)

<center>图7:时间资源使用情况

### 测试结果与分析

测试过程按照ppt设计，最终会在数码管上输出时钟数



输入G指令后,led1亮时，输入数组大小并确定，这里以0x100为例

![image-20230621001044921](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230621001044921.png)

<center>图8:数组大小

​    之后led2亮起，输入第2个数，即数组的第一个元素

![image-20230621001156250](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230621001156250.png)

<center>图9:第一个数组元素

排序完成后，输出排序所用的时钟数

![image-20230621001445176](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230621001445176.png)

<center>图10:排序使用的时钟数

![image-20230621000852348](C:\Users\Liuz\Desktop\CODH lab\lab6\Lab 6 report.assets\image-20230621000852348.png)

<center>图11：最终命中率17a4b/17a96

### 总结

这次实验实践了cache的设计，发现并解决了很多bug，总的来说实验难度比较大，收获也很大

**比如遇到的几个bug:**

因为mem接口太多导致LUT资源使用过量，综合卡住，实验被卡了一周

total,miss计数的位置错误

MEM/WB段需要clear

考虑不同信号的优先级，比如eStall和eFlush，需要先考虑哪个

很多接口接错的错误（比如单词拼错，大小写没注意，但也不会报错等等）

地址忘记做变换

地址位搞错........