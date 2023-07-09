`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 07:59:34
// Design Name: 
// Module Name: sw_DPE
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


module sw_DPE(
    input clk,
    input rstn,
    input [15:0] sw,
    input btnr,
    input btnc,
    output btnr_edge,
    output btnc_edge,
    output [31:0] data_out
    );
    wire [15:0] sw_edge;
    DP_double DP_inst0(
        .clk (clk),
        .button (sw[0]),
        .button_edge (sw_edge[0])
    );
    DP_double DP_inst1(
        .clk (clk),
        .button (sw[1]),
        .button_edge (sw_edge[1])
    );
    DP_double DP_inst2(
        .clk (clk),
        .button (sw[2]),
        .button_edge (sw_edge[2])
    );
    DP_double DP_inst3(
        .clk (clk),
        .button (sw[3]),
        .button_edge (sw_edge[3])
    );
    DP_double DP_inst4(
        .clk (clk),
        .button (sw[4]),
        .button_edge (sw_edge[4])
    );
    DP_double DP_inst5(
        .clk (clk),
        .button (sw[5]),
        .button_edge (sw_edge[5])
    );
    DP_double DP_inst6(
        .clk (clk),
        .button (sw[6]),
        .button_edge (sw_edge[6])
    );
    DP_double DP_inst7(
        .clk (clk),
        .button (sw[7]),
        .button_edge (sw_edge[7])
    );
    DP_double DP_inst8(
        .clk (clk),
        .button (sw[8]),
        .button_edge (sw_edge[8])
    );
    DP_double DP_inst9(
        .clk (clk),
        .button (sw[9]),
        .button_edge (sw_edge[9])
    );
    DP_double DP_inst10(
        .clk (clk),
        .button (sw[10]),
        .button_edge (sw_edge[10])
    );
    DP_double DP_inst11(
        .clk (clk),
        .button (sw[11]),
        .button_edge (sw_edge[11])
    );
    DP_double DP_inst12(
        .clk (clk),
        .button (sw[12]),
        .button_edge (sw_edge[12])
    );
    DP_double DP_inst13(
        .clk (clk),
        .button (sw[13]),
        .button_edge (sw_edge[13])
    );
    DP_double DP_inst14(
        .clk (clk),
        .button (sw[14]),
        .button_edge (sw_edge[14])
    );
    DP_double DP_inst15(
        .clk (clk),
        .button (sw[15]),
        .button_edge (sw_edge[15])
    );
    DP_upper DP_btnr(
        .clk (clk),
        .button (btnr),
        .button_edge (btnr_edge)
    );
    DP_upper DP_btnc (
        .clk (clk),
        .button (btnc),
        .button_edge (btnc_edge)
    );

    reg [31:0] data_output;
    always @(posedge clk) begin
        if(~rstn) begin
            data_output <= 32'b0;
        end
        else begin
            if(sw_edge[0]) begin
                data_output <= {data_output[27:0], 4'b0000};
            end
            else if (sw_edge[1]) begin
                data_output <= {data_output[27:0], 4'b0001};
            end
            else if (sw_edge[2]) begin
                data_output <= {data_output[27:0], 4'b0010};
            end
            else if (sw_edge[3]) begin
                data_output <= {data_output[27:0], 4'b0011};
            end
            else if (sw_edge[4]) begin
                data_output <= {data_output[27:0], 4'b0100};
            end
            else if (sw_edge[5]) begin
                data_output <= {data_output[27:0], 4'b0101};
            end
            else if (sw_edge[6]) begin
                data_output <= {data_output[27:0], 4'b0110};
            end
            else if (sw_edge[7]) begin
                data_output <= {data_output[27:0], 4'b0111};
            end
            else if (sw_edge[8]) begin
                data_output <= {data_output[27:0], 4'b1000};
            end
            else if (sw_edge[9]) begin
                data_output <= {data_output[27:0], 4'b1001};
            end
            else if (sw_edge[10]) begin
                data_output <= {data_output[27:0], 4'b1010};
            end
            else if (sw_edge[11]) begin
                data_output <= {data_output[27:0], 4'b1011};
            end
            else if (sw_edge[12]) begin
                data_output <= {data_output[27:0], 4'b1100};
            end
            else if (sw_edge[13]) begin
                data_output <= {data_output[27:0], 4'b1101};
            end
            else if (sw_edge[14]) begin
                data_output <= {data_output[27:0], 4'b1110};
            end
            else if (sw_edge[15]) begin
                data_output <= {data_output[27:0], 4'b1111};
            end
            else if (btnr_edge) begin
                data_output <= {4'b0000, data_output[31:4]};
            end
            else if (btnc_edge) begin
                data_output <= 32'b0;
            end
            else begin
                data_output <= data_output;
            end
        end
    end
    assign data_out = data_output;
endmodule
