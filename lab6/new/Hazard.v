`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/17 19:45:04
// Design Name: 
// Module Name: Hazard
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


module Hazard(
    input [4:0] ID_R1idx,
    input [4:0] ID_R2idx,
    input [6:0] ID_opcode,
    input [4:0] EX_rdidx,
    input [6:0] EX_opcode,
    input EX_pc_choice,
    input MEM_DONE,
    output reg pc_enable,
    output reg IF_ID_enable,
    output reg IF_ID_clear,
    output reg ID_EX_clear,
    output reg ID_EX_enable,
    output reg EX_MEM_enable,
    output reg MEM_WB_enable
    );
    wire [2:0] ID_type;
    wire [2:0] EX_type;
    sort_type ID_type_inst(
        .opcode (ID_opcode),
        .type (ID_type)
    );
    sort_type EX_type_inst(
        .opcode (EX_opcode),
        .type (EX_type)
    );
    always @(*) begin
        if(!MEM_DONE) begin
            pc_enable = 0;
            IF_ID_enable = 0;
            IF_ID_clear = 0;
            ID_EX_clear = 0;
            ID_EX_enable = 0;
            EX_MEM_enable = 0;
            MEM_WB_enable = 0;
        end
        else if(EX_type == 6 && (ID_type != 2 && ID_type != 5)) begin    // lw + xxx-type
            ID_EX_enable = 1;
            EX_MEM_enable = 1;
            MEM_WB_enable = 1;
            if(ID_type == 0 || ID_type == 4) begin  // R-type
                if(EX_rdidx == ID_R1idx || EX_rdidx == ID_R2idx) begin
                    pc_enable = 0;
                    IF_ID_enable = 0;
                    IF_ID_clear = 0;
                    ID_EX_clear = 1;
                end
                else begin
                    pc_enable = 1;
                    IF_ID_enable = 1;
                    IF_ID_clear = 0;
                    ID_EX_clear = 0;
                end
            end
            else begin  // I-type, S-type, B-type
                if(EX_rdidx == ID_R1idx) begin
                    pc_enable = 0;
                    IF_ID_enable = 0;
                    IF_ID_clear = 0;
                    ID_EX_clear = 1;
                end
                else begin
                    pc_enable = 1;
                    IF_ID_enable = 1;
                    IF_ID_clear = 0;
                    ID_EX_clear = 0;
                end
            end
        end
        else if(EX_type == 4 || EX_type == 5 || EX_type == 7) begin // branch & jmp
            ID_EX_enable = 1;
            EX_MEM_enable = 1;
            MEM_WB_enable = 1;
            if (EX_pc_choice) begin // branch or jmp activate
                pc_enable = 1;
                IF_ID_enable = 1;
                IF_ID_clear = 1;
                ID_EX_clear = 1;
            end
            else begin
                pc_enable = 1;
                IF_ID_enable = 1;
                IF_ID_clear = 0;
                ID_EX_clear = 0;
            end
        end
        else begin
            ID_EX_enable = 1;
            EX_MEM_enable = 1;
            MEM_WB_enable = 1;
            pc_enable = 1;
            IF_ID_enable = 1;
            IF_ID_clear = 0;
            ID_EX_clear = 0;
        end
    end
endmodule
