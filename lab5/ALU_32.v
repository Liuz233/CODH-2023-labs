`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/30 16:27:17
// Design Name: 
// Module Name: ALU_32
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


module ALU_32#(parameter WIDTH = 32)(
    input [WIDTH-1:0]a,b,
    input [2:0] f,
    output reg[WIDTH-1:0] y,
    output reg[2:0] t
);
    reg signed [WIDTH-1:0] signed_a;
    reg signed [WIDTH-1:0] signed_b;
    always@(*)
    begin
        signed_a=0;
        signed_b=0;
        t=0;
        case(f)
        0:begin
            y=a-b;
            signed_a=a;
            signed_b=b;
            if(y==0) t[0]=1;
            else     t[0]=0;
            if(a<b)  t[2]=1;
            else     t[2]=0;
            if(signed_a<signed_b) t[1]=1;
            else     t[1]=0;

        end  
        1:begin
            y=a+b;
        end
        2:begin
            y=a&b;
        end  
        3:begin
            y=a|b;
        end  
        4:begin
            y=a^b;
        end 
        5:begin
            y=a>>b[4:0];
        end  
        6:begin
            y=a<<b[4:0];
        end
        7:begin
            signed_a=a;
            y=signed_a>>>b[4:0];
        end
        default:begin
            signed_a=a;
            y=signed_a>>>b[4:0];
        end    
        endcase 
    end
endmodule
