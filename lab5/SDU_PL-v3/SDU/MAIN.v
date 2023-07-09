`timescale 1ns / 1ps
module MAIN(
    input       clk,rstn,
    input       rxd,
    output      txd,
    input       [15:0] sw,
    output      [15:0] led,
    output      [7:0]  seg,
    output      [7:0]  AN,
    input       btnr,
    input       btnc,
    output swx_vld,
    output seg_rdy
//    output      Rstn
);
wire        clk_153600;
udf_FD fd(
    .k(32'h0000028b),
    .rstn(rstn),
    .clk(clk),
    .y(clk_153600)
);
wire cvalid,cpu_req_rw,cready;
wire io_we,io_rd;
wire [31:0]     ctr_debug1,ctr_debug2,ctr_debug3,miss_count,total_count;
wire [31:0]     caddr,cdata,dm_out;
wire [31:0]     npc,pc,ir,
                pc_id,ir_id,pc_ex,ir_ex,rrd1,rrd2,imm,
                ir_mem,res,dwd,ir_wb,res_wb,drd,rwd;
wire            cpu_clk,cpu_rstn;
wire [31:0]     drd0,dra0,rrd0;
wire [4:0]      rra0;
wire [31:0]     final_data;
////////////////////////////////////////////////////////
/* 可以在这里定义自己需要从CPU引出并由SDU输出的其他信号！！*/
wire [31:0]     my_signal;
////////////////////////////////////////////////////////
SDU sdu(
    .clk(clk_153600),       // 波特率符合要求的时钟
    .rstn(rstn),            // 复位信号
    .rxd(rxd),              // 用于输入
    .txd(txd),              // 用于输出
    // cpu控制时钟与置位信号
    .cpu_clk(cpu_clk),
    .cpu_rstn(cpu_rstn),
    // 以下是P指令的调试接口
    // 以下只有rra0即寄存器读地址位宽为5，其余均为32位
    .ctr_debug1(ctr_debug1),  // 3个32位的信号，可以自行定义语义
    .ctr_debug2(ctr_debug2),
    .ctr_debug3(ctr_debug3),
    .npc(npc),              // 在五级不含缓存的多周期CPU中由于其内容可由pc推断出，所以可以不设置
    .pc(pc),                // IF段前pc
    .ir(ir),                // IF段取出的指令码
    // IF/ID段间
    .pc_id(pc_id),          // IF段递给ID段的pc
    .ir_id(ir_id),          // IF段递给ID段的ir
    // ID/EX段间
    .pc_ex(pc_ex),          // ID段递给EX段的pc
    .ir_ex(ir_ex),          // ID段递给EX段的ir
    .rrd1(rrd1),            // 寄存器堆输出端1
    .rrd2(rrd2),            // 寄存器堆输出端2
    .imm(imm),              // ID阶段立即数计算结果
    // EX/MEM段间
    .ir_mem(ir_mem),        // EX段递给MEM段的ir
    .res(res),              // ALU output
    .dwd(dwd),              // 要写入数据存储器的数据
    // MEM/WB段间
    .ir_wb(ir_wb),          // MEM段递给WB段的ir
    .drd(drd),              // 数据存储器读出的数据
    .res_wb(res_wb),        // ALU的计算结果继续传递
    // WB段需要写回的数据
    .rwd(rwd),              // 需要写回到寄存器堆的数据
    // 用于D与R指令的调试接口
    .drd0(drd0),            // 数据存储器的输出
    .dra0(dra0),            // 数据存储器的输入地址
    .rrd0(rrd0),            // 寄存器堆的输出数据
    .rra0(rra0)             // 寄存器堆的输入地址，唯一的五位位宽
);
// 按照需求修改相应接口即可，接口定义详见SDU的说明
cpu_top cpu_v4(
    .cpu_clk(cpu_clk),      // 控制CPU运行的时钟
    .cpu_rstn(~rstn),    // 控制CPU复位的信号
    /* ***以下根据需要修改*** */
    // 用于D与R指令的调试接口
    //.dra0(dra0),            // 数据存储器的输入地址
    //.drd0(drd0),            // 数据存储器的输出
    .rra0(rra0),            // 寄存器堆的输入地址，唯一的五位位宽
    .rrd0(rrd0),            // 寄存器堆的输出数据
    // 自由定义部分
    .ctr_debug(ctr_debug1),
    // .ctr_debug2(ctr_debug2),
    // .ctr_debug3(ctr_debug3),
    // IF段
    .npc(npc),              // 下一个pc值
    .pc(pc),                // IF段前pc
    .ir(ir),                // IF段取出的指令码
    // IF/ID段间
    .pc_id(pc_id),          // IF段递给ID段的pc
    .ir_id(ir_id),          // IF段递给ID段的ir
    // ID/EX段间
    .pc_ex(pc_ex),          // ID段递给EX段的pc
    .ir_ex(ir_ex),          // ID段递给EX段的ir
    .rrd1(rrd1),            // 寄存器堆输出端1
    .rrd2(rrd2),            // 寄存器堆输出端2
    .imm(imm),
    // EX/MEM段间
    .ir_mem(ir_mem),        // EX段递给MEM段的ir
    .res(res),              // ALU output
    .dwd(dwd),              // 要写入数据存储器的数据
    // MEM/WB段间
    .ir_wb(ir_wb),          // MEM段递给WB段的ir
    .drd(drd),              // 数据存储器读出的数据
    .res_wb(res_wb),        // ALU的计算结果继续传递
    .cvalid(cvalid),
    .caddr(caddr),
    .cdata(cdata),
    .io_we(io_we),
    .io_rd(io_rd),
    .cpu_req_rw(cpu_req_rw),
    .dm_out(final_data),
    .cready(cready),
    // WB段写回
    .rwd(rwd)               // 需要写回到寄存器堆的数据
    );
    DMS  u_DMS (
    .cpu_clk                 ( cpu_clk            ),
    .cpu_rstn                ( ~rstn           ),
    .cvalid                  ( cvalid             ),
    .a                       ( caddr                 ),
    //.dpra                    ( dra0               ),
    .d                       ( cdata          [31:0] ),
    .cpu_req_rw              ( cpu_req_rw         ),

    .spo                     ( dm_out         [31:0] ),
    //.dpo                     ( drd0         [31:0] ),
    .miss                    ( miss_count   [31:0] ),
    .total                   ( total_count  [31:0] ),
    .cready                  ( cready             )
    );
    assign ctr_debug2=(total_count-miss_count);
    assign ctr_debug3=total_count;
    
    wire [31:0] io_addr,io_dout,io_din,hex_data;
    assign io_addr = caddr;
    assign io_dout = cdata;
    assign final_data = (io_rd | io_we)? io_din:dm_out;//mmio/cache
    // assign ctr_debug2 = {28'b0,(io_rd|io_we),final_data[0],io_din[0],dm_out[0]};
    // assign ctr_debug3 = {14'b0,io_dout[15:0],io_rd,io_we};
    IOU  u_IOU (
    .clk                     ( clk              ),
    .clk_cpu                 ( cpu_clk          ),
    .rstn                    ( rstn             ),
    .io_addr                 ( io_addr   [31:0] ),
    .io_dout                 ( io_dout   [31:0] ),
    .io_we                   ( io_we            ),
    .io_rd                   ( io_rd            ),
    .sw                      ( sw        [15:0] ),
    .btnr                    ( btnr             ),
    .btnc                    ( btnc             ),

    .io_din                  ( io_din    [31:0] ),
    .led                     ( led       [15:0] ),
    .hex_data                ( hex_data  [31:0] ),
    .swx_vld                  (swx_vld          ),
    .seg_rdy                  (seg_rdy)
    );
    segment  u_segment (
    .clk                     ( clk            ),
    .rstn                    ( ~rstn           ),
    .cycles                  ( hex_data       ),

    .seg                     ( seg     [7:0]  ),
    .AN                      ( AN      [7:0]  )
    );
endmodule