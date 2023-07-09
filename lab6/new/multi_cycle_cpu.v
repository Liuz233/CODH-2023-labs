`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:53:08
// Design Name: 
// Module Name: multi_cycle_cpu
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


module multi_cycle_cpu(
    input rstn,
    input clk,
    input clk_cpu,  //cpu工作时钟
    // D R指令的调试接口
    input [31:0] dra0,  //数据存储器的输入地址
    input [4:0] rra0,  //寄存器堆的输入地址
    output [31:0] drd0,  //数据存储器的输出数据
    output [31:0] rrd0, //寄存器堆的输出数据

    // debug用，测试信号
    output pcenable,
    output ifidenable,
    output ifidclear,
    output idexclear,
    output expcchoice,
    output [31:0] alua, alub,
    output [1:0] asrc,
    output bsrc,
    output [31:0] exaluresult,
    output [31:0] wbfinaldata,
    output [1:0] aluaforward,alubforward,
    output memdone,
    output [1:0] state,
    output [31:0] memdataout,
    output [9:0] dataaddr,
    output [31:0] memr2,
    output [4:0] exr2idx,
    output [4:0] memrdidx,
    output memregwrite,
    output [4:0] exrdidx,
    output exjmp,
    output exbranchcheck,
    output hex_choice,

    // 自由定义部分
    output [31:0] ctr_debug1,
    output [31:0] ctr_debug2,
    output [31:0] ctr_debug3,

    // IF段
    output [31:0] npc,
    output [31:0] pc,
    output [31:0] ir,

    // ID段
    output [31:0] pc_id,
    output [31:0] ir_id,

    // EX段
    output [31:0] pc_ex,
    output [31:0] ir_ex,
    output [31:0] rrd1,        //寄存器堆输出1
    output [31:0] rrd2,        //寄存器堆输出2
    output [31:0] imm,

    // MEM段
    output [31:0] ir_mem,
    output [31:0] res,          //alu计算结果
    output [31:0] dwd,          //写入数据存储器的数据

    // WB段
    output [31:0] ir_wb,
    output [31:0] drd,          // 写入数据存储器的数据
    output [31:0] res_wb,       // alu计算结果
    output [31:0] rwd,          // 写回寄存器堆的数据

    // IOU
    input [15:0] sw,
    input btnr,
    input btnc,
    output [15:0] led,
    output A,B,C,D,E,F,G,
    output [7:0] AN
    );
    // IF段
    reg [31:0] IF_PC;
    wire [31:0] IF_NPC;
    wire IF_pc_enable;
    wire [31:0] IF_IR;
    wire IM_we;
    wire [31:0] IM_data_in;
    wire [31:0] IF_PC_plus_four;
    wire IF_pc_choice;
    wire [31:0] EX_ALU_result;
    wire [31:0] real_instruction_addr;
    wire [31:0] EX_branch_PC;
    wire [31:0] EX_branch_jmp_PC;

    assign IM_we = 0;
    assign IM_data_in = 0;
    assign real_instruction_addr = IF_PC >> 2;
    assign IF_PC_plus_four = IF_PC + 4;
    instruction_memory IM_inst(
        .clk (clk_cpu),
        .a (real_instruction_addr[9:0]),
        .d (IM_data_in),
        //.dpra (),
        .we (IM_we),
        .spo (IF_IR)
        //.dpo ()
    );
    always @(posedge clk_cpu or negedge rstn) begin
        if(~rstn) begin
            IF_PC <= 0;
        end
        else begin
            if(IF_pc_enable) begin
                IF_PC <= IF_NPC;
            end
            else begin
                IF_PC <= IF_PC;
            end
        end
    end
    assign IF_NPC = (IF_pc_choice)?EX_branch_jmp_PC:IF_PC_plus_four;

    assign npc = IF_NPC;
    assign pc = IF_PC;
    assign ir = IF_IR;

    // ID段
    wire [31:0] ID_PC;
    wire [31:0] ID_PC_plus_four;
    wire [31:0] ID_IR;
    wire IF_ID_enable;
    wire IF_ID_clear;
    //reg IF_ID_clear1;
    reg IF_ID_clear_out;
    always @(posedge clk_cpu) begin
        //IF_ID_clear1 <= IF_ID_clear;
        IF_ID_clear_out <= IF_ID_clear;
    end
    IF_ID if_id_inst(
        .clk (clk_cpu),
        .pc_in (IF_PC),
        .pc_plus_in (IF_PC_plus_four),
        .ir_in (IF_IR),
        .pc_out (ID_PC),
        .pc_plus_out (ID_PC_plus_four),
        .ir_out (ID_IR),
        .clear (IF_ID_clear || ~rstn),
        .enable (IF_ID_enable)
    );

    // 控制信号
    wire ID_RegWrite;
    wire [1:0] ID_RegSrc;
    wire ID_MemWrite;
    wire ID_MemRead;
    wire ID_Jmp;
    wire [1:0] ID_BranchState;
    wire [1:0] ID_ASrc;
    wire ID_BSrc;
    wire [2:0] ID_ALUOp;
    wire [2:0] ID_ImmGenWay;

    Control ctrl_inst(
        .ir (ID_IR),
        .RegWrite (ID_RegWrite),
        .RegSrc (ID_RegSrc),
        .MemRead (ID_MemRead),
        .MemWrite (ID_MemWrite),
        .Jmp (ID_Jmp),
        .BranchState (ID_BranchState),
        .ASrc (ID_ASrc),
        .BSrc (ID_BSrc),
        .ALUOp (ID_ALUOp),
        .ImmGenWay (ID_ImmGenWay)
    );

    // 寄存器
    wire [4:0] ID_R1idx;
    wire [4:0] ID_R2idx;
    wire [4:0] ID_rdidx;
    wire [6:0] ID_opcode;
    wire [31:0] ID_R1;
    wire [31:0] ID_R2;
    wire [4:0] WB_rdidx;
    reg [31:0] WB_final_data;
    wire WB_RegWrite;

    assign ID_R1idx = ID_IR[19:15];
    assign ID_R2idx = ID_IR[24:20];
    assign ID_rdidx = ID_IR[11:7];
    assign ID_opcode = ID_IR[6:0];

    Registers reg_inst(
        .clk (clk_cpu),
        .rstn (rstn),
        .ra1 (ID_R1idx),
        .ra2 (ID_R2idx),
        .rd1 (ID_R1),
        .rd2 (ID_R2),
        .wa (WB_rdidx),
        .wd (WB_final_data),
        .we (WB_RegWrite),
        .ra_debug (rra0),
        .rd_debug (rrd0)
    );

    // 立即数
    wire [31:0] ID_IMM;

    Imm imm_inst(
        .ImmGenWay (ID_ImmGenWay),
        .ir (ID_IR),
        .imm (ID_IMM)
    );

    assign pc_id = ID_PC;
    assign ir_id = ID_IR;

    // EX段
    // 控制信号
    wire EX_RegWrite;
    wire [1:0] EX_RegSrc;
    wire EX_MemWrite;
    wire EX_MemRead;
    wire EX_Jmp;
    wire [1:0] EX_BranchState;
    wire [1:0] EX_ASrc;
    wire EX_BSrc;
    wire [2:0] EX_ALUOp;
    wire [2:0] EX_ImmGenWay;
    
    wire [31:0] EX_PC;
    wire [31:0] EX_PC_plus_four;
    wire [31:0] EX_IR;
    wire [31:0] EX_R1;
    wire [31:0] EX_R2;
    wire [31:0] EX_IMM;
    wire [4:0] EX_R1idx;
    wire [4:0] EX_R2idx;
    wire [4:0] EX_rdidx;
    wire [6:0] EX_opcode;
    wire ID_EX_enable;

    wire ID_EX_clear;
    //reg ID_EX_clear1;
    reg ID_EX_clear_out;
    always @(posedge clk_cpu) begin
        //ID_EX_clear1 <= ID_EX_clear;
        ID_EX_clear_out <= ID_EX_clear;
    end

    ID_EX id_ex_inst(
        .clk (clk_cpu),

        .RegWrite_in (ID_RegWrite),
        .RegSrc_in (ID_RegSrc),
        .MemWrite_in (ID_MemWrite),
        .MemRead_in (ID_MemRead),
        .Jmp_in (ID_Jmp),
        .BranchState_in (ID_BranchState),
        .ASrc_in (ID_ASrc),
        .BSrc_in (ID_BSrc),
        .ALUOp_in (ID_ALUOp),
        .RegWrite_out (EX_RegWrite),
        .RegSrc_out (EX_RegSrc),
        .MemWrite_out (EX_MemWrite),
        .MemRead_out (EX_MemRead),
        .Jmp_out (EX_Jmp),
        .BranchState_out (EX_BranchState),
        .ASrc_out (EX_ASrc),
        .BSrc_out (EX_BSrc),
        .ALUOp_out (EX_ALUOp),

        .pc_in (ID_PC),
        .pc_plus_in (ID_PC_plus_four),
        .ir_in (ID_IR),
        .R1_in (ID_R1),
        .R2_in (ID_R2),
        .imm_in (ID_IMM),
        .R1idx_in (ID_R1idx),
        .R2idx_in (ID_R2idx),
        .rdidx_in (ID_rdidx),
        .opcode_in (ID_opcode),
        .pc_out (EX_PC),
        .pc_plus_out (EX_PC_plus_four),
        .ir_out (EX_IR),
        .R1_out (EX_R1),
        .R2_out (EX_R2),
        .imm_out (EX_IMM),
        .R1idx_out (EX_R1idx),
        .R2idx_out (EX_R2idx),
        .rdidx_out (EX_rdidx),
        .opcode_out (EX_opcode),

        .clear (ID_EX_clear || ~rstn),
        .enable (ID_EX_enable)
    );
    // ALU以及输入数据的MUX
    reg [31:0] EX_A_forward, EX_B_forward;
    reg [31:0] EX_ALU_A, EX_ALU_B;
    wire [2:0] EX_ALU_compare;
    wire [1:0] ALU_A_forward, ALU_B_forward;
    wire [31:0] MEM_ALU_result;

    ALU ALU_inst(
        .a (EX_ALU_A),
        .b (EX_ALU_B),
        .f (EX_ALUOp),
        .y (EX_ALU_result),
        .t (EX_ALU_compare)
    );
    always @(*) begin
        case (ALU_A_forward)
            0: EX_A_forward = WB_final_data;
            1: EX_A_forward = EX_R1;
            2: EX_A_forward = MEM_ALU_result; 
            default: EX_A_forward = EX_R1;
        endcase
        case (ALU_B_forward)
            0: EX_B_forward = WB_final_data;
            1: EX_B_forward = EX_R2;
            2: EX_B_forward = MEM_ALU_result;
            default: EX_B_forward = EX_R2;
        endcase
    end
    always @(*) begin
        case (EX_ASrc)
            0: EX_ALU_A = EX_PC;
            1: EX_ALU_A = EX_A_forward;
            2: EX_ALU_A = 0;
            default: EX_ALU_A = EX_A_forward;
        endcase
        case (EX_BSrc)
            0: EX_ALU_B = EX_IMM;
            1: EX_ALU_B = EX_B_forward;
        endcase
    end

    // 改变PC判断
    reg EX_branch_check;
    wire EX_pc_choice;
    always @(*) begin
        case (EX_BranchState)
            0: EX_branch_check = 0;
            1: EX_branch_check = (EX_ALU_compare[0] == 1);
            2: EX_branch_check = (EX_ALU_compare[1] == 1);
            3: EX_branch_check = (EX_ALU_compare[2] == 1);
        endcase
    end
    assign EX_pc_choice = (EX_Jmp || EX_branch_check);
    assign IF_pc_choice = EX_pc_choice;
    assign EX_branch_PC = EX_PC + (EX_IMM << 1);
    assign EX_branch_jmp_PC = (EX_Jmp)?EX_ALU_result:EX_branch_PC;
    assign pc_ex = EX_PC;
    assign ir_ex = EX_IR;
    assign rrd1 = EX_R1;
    assign rrd2 = EX_R2;
    assign imm = EX_IMM;

    // MEM段
    wire MEM_RegWrite;
    wire [1:0] MEM_RegSrc;
    wire MEM_MemWrite;
    wire MEM_Jmp;
    wire [31:0] MEM_PC_plus_four;
    wire [31:0] MEM_IR;
    //wire [31:0] MEM_ALU_result;
    wire [31:0] MEM_R2;
    wire [4:0] MEM_rdidx;
    wire EX_MEM_enable;
    wire MEM_DONE;
    EX_MEM ex_mem_inst(
        .clk (clk_cpu),

        .RegWrite_in (EX_RegWrite),
        .RegSrc_in (EX_RegSrc),
        .MemWrite_in (EX_MemWrite),
        .Jmp_in (EX_Jmp),
        .RegWrite_out (MEM_RegWrite),
        .RegSrc_out (MEM_RegSrc),
        .MemWrite_out (MEM_MemWrite),
        .Jmp_out (MEM_Jmp),

        .pc_plus_in (EX_PC_plus_four),
        .ir_in (EX_IR),
        .aluresult_in (EX_ALU_result),
        .R2_in (EX_B_forward),
        .rdidx_in (EX_rdidx),
        .pc_plus_out (MEM_PC_plus_four),
        .ir_out (MEM_IR),
        .aluresult_out (MEM_ALU_result),
        .R2_out (MEM_R2),
        .rdidx_out (MEM_rdidx),

        .clear (~rstn),
        .enable (EX_MEM_enable)
    );
    wire [31:0] MEM_data_out;
    wire [31:0] real_data_addr;
    assign real_data_addr = (MEM_ALU_result - 32'h2000) >> 2;
    /* data_memory DM_inst(
        .clk (clk_cpu),
        .a (real_data_addr[9:0]),
        .d (MEM_R2),
        .dpra (dra0[9:0]),
        .we (MEM_MemWrite),
        .spo (MEM_data_out),
        .dpo (drd0)
    ); */
    /* Cached_memory CM_inst(
        .clk_cpu (clk_cpu),
        .rstn (rstn),
        .real_data_addr (real_data_addr[9:0]),
        .MEM_R2 (MEM_R2),
        .MEM_MemWrite (MEM_MemWrite),
        .dra0 (dra0[9:0]),
        .MEM_data_out (MEM_data_out),
        .drd0 (drd0),
        .opcode (MEM_IR[6:0]),
        .state_out (state),
        //.cpu_req_rw (cpu_req_rw),
        //.cpu_req_valid (cpu_req_valid),
        .done (MEM_DONE)
        //.cpu_data_write ()
    ); */
    wire [31:0] cache_data_out;
    wire [31:0] iou_data_out;
    wire [31:0] total;
    wire [31:0] miss;
    Cached_memory_mmio CMM_inst(
        .clk_cpu (clk_cpu),
        .rstn (rstn),
        .real_data_addr (real_data_addr),
        .MEM_R2 (MEM_R2),
        .MEM_MemWrite (MEM_MemWrite),
        .dra0 (dra0),
        .MEM_data_out (cache_data_out),
        .drd0 (drd0),
        .opcode (MEM_IR[6:0]),
        .state_out (state),
        .total (total),
        .miss (miss),
        .done (MEM_DONE)
    );
    // iou
    wire mmio;
    assign mmio = (real_data_addr[15:4]==12'b0001_0111_1100);
    reg io_we, io_rd;
    always @(*) begin
        if(mmio) begin
            if(MEM_IR[6:0] == 7'b0000011) begin
                io_rd = 1;
                io_we = 0;
            end
            else if (MEM_IR[6:0] == 7'b0100011) begin
                io_we = 1;
                io_rd = 0;
            end
            else begin
                io_we = 0;
                io_rd = 0;
            end
        end
        else begin
            io_we = 0;
            io_rd = 0;
        end
    end
    IOU iou_inst(
        .clk (clk),
        .clk_cpu (clk_cpu),
        .rstn (rstn),
        .io_addr (real_data_addr),
        .io_dout (MEM_R2),
        .io_din (iou_data_out),
        .io_we (io_we),
        .io_rd (io_rd),
        .pc (MEM_PC_plus_four),
        .npc (IF_NPC),
        .hex_choice (hex_choice),
        //.total (total),
        //.miss (miss), 
        .sw (sw),
        .btnr (btnr),
        .btnc (btnc),
        .led (led),
        .A (A),
        .B (B),
        .C (C),
        .D (D),
        .E (E),
        .F (F),
        .G (G),
        .AN (AN)
    );
    assign ctr_debug1 = total;
    assign ctr_debug2 = miss;
    assign ctr_debug3 = {31'b0, hex_choice};
    assign MEM_data_out = (io_we | io_rd)?iou_data_out:cache_data_out;
    assign ir_mem = MEM_IR;
    assign res = MEM_ALU_result;
    assign dwd = MEM_R2;

    // WB段
    //wire WB_RegWrite;
    wire [1:0] WB_RegSrc;
    wire [31:0] WB_PC_plus_four;
    wire [31:0] WB_IR;
    wire [31:0] WB_ALU_result;
    wire [31:0] WB_data_out;
    //wire [4:0] WB_rdidx;
    wire MEM_WB_enable;

    MEM_WB mem_wb_inst(
        .clk (clk_cpu),

        .RegWrite_in (MEM_RegWrite),
        .RegSrc_in (MEM_RegSrc),
        .RegWrite_out (WB_RegWrite),
        .RegSrc_out (WB_RegSrc),

        .pc_plus_in (MEM_PC_plus_four),
        .ir_in (MEM_IR),
        .aluresult_in (MEM_ALU_result),
        .memdata_in (MEM_data_out),
        .rdidx_in (MEM_rdidx),
        .pc_plus_out (WB_PC_plus_four),
        .ir_out (WB_IR),
        .aluresult_out (WB_ALU_result),
        .memdata_out (WB_data_out),
        .rdidx_out (WB_rdidx),
        
        .clear (~rstn),
        .enable (MEM_WB_enable)
    );

    always @(*) begin
        case (WB_RegSrc)
            0: WB_final_data = WB_PC_plus_four;
            1: WB_final_data = WB_ALU_result;
            2: WB_final_data = WB_data_out;
            default: WB_final_data = WB_ALU_result;
        endcase
    end

    assign ir_wb = WB_IR;
    assign drd = WB_data_out;
    assign res_wb = WB_ALU_result;
    assign rwd = WB_final_data;

    // forwarding unit
    Forwarding forward_inst(
        .EX_R1idx (EX_R1idx),
        .EX_R2idx (EX_R2idx),
        .MEM_rdidx (MEM_rdidx),
        .WB_rdidx (WB_rdidx),
        .MEM_RegWrite (MEM_RegWrite),
        .WB_RegWrite (WB_RegWrite),
        .ALU_A_forward (ALU_A_forward),
        .ALU_B_forward (ALU_B_forward)
    );
    // hazard unit
    Hazard hazard_inst(
        .ID_R1idx (ID_R1idx),
        .ID_R2idx (ID_R2idx),
        .ID_opcode (ID_opcode),
        .EX_rdidx (EX_rdidx),
        .EX_opcode (EX_opcode),
        .EX_pc_choice (EX_pc_choice),
        .pc_enable (IF_pc_enable),
        .IF_ID_enable (IF_ID_enable),
        .IF_ID_clear (IF_ID_clear),
        .ID_EX_clear (ID_EX_clear),
        .ID_EX_enable (ID_EX_enable),
        .EX_MEM_enable (EX_MEM_enable),
        .MEM_WB_enable (MEM_WB_enable),
        .MEM_DONE (MEM_DONE)
    ); 
    
    //assign IF_pc_enable = 1;
    //assign ID_EX_enable = 1;
    //assign EX_MEM_enable = 1;
    //assign MEM_WB_enable = 1;
    //assign ctr_debug = 0;
    // debug用，测试信号
    assign pcenable = IF_pc_enable;
    assign ifidenable = IF_ID_enable;
    assign ifidclear = IF_ID_clear_out;
    assign idexclear = ID_EX_clear_out;
    assign alua = EX_ALU_A;
    assign alub = EX_ALU_B;
    assign asrc = EX_ASrc;
    assign bsrc = EX_BSrc;
    assign exaluresult = EX_ALU_result;
    assign wbfinaldata = WB_final_data;
    assign aluaforward = ALU_A_forward;
    assign alubforward = ALU_B_forward;
    assign memdone = MEM_DONE;
    assign memdataout = MEM_data_out;
    assign dataaddr = real_data_addr[9:0];
    assign memr2 = MEM_R2;
    assign exr2idx = EX_R2idx;
    assign memrdidx = MEM_rdidx;
    assign memregwrite = MEM_RegWrite;
    assign exrdidx = EX_rdidx;
    assign expcchoice = EX_pc_choice;
    assign exjmp = EX_Jmp;
    assign exbranchcheck = EX_branch_check;
endmodule
