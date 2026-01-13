`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 10:50:57
// Design Name: 
// Module Name: ex_mem
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


module ex_mem(
        input clk,
        input [31:0]ex_wdata0,
        input [4:0]ex_wd0,
        input ex_wreg0,
        output reg [31:0]mem_data,
        output reg [4:0]mem_wd,
        output reg mem_wreg,
        
        input wire exDelay_i,
        output reg memDelay_o,
        
        input wire[1:0]ex_lsop0,
        input wire[31:0]ex_memaddr,
        input wire[31:0]ex_reg20,
        output reg[1:0]mem_lsop,
        output reg[31:0]mem_memaddr,
        output reg[31:0]mem_reg2,
        input [5:0]stall
    );
        always@(posedge clk) begin
            if(stall[3]==1&&stall[4]==0)begin
                mem_data<=32'b0;
                mem_wd<=5'b0;
                mem_wreg<=1'b0;
                memDelay_o<=1'b0;
                mem_lsop<=2'b0;
                mem_memaddr<=32'b0;
                mem_reg2<=32'b0;            
            end else if(stall[3]==0)begin
                mem_data<=ex_wdata0;
                mem_wd<=ex_wd0;
                mem_wreg<=ex_wreg0;
                memDelay_o<=exDelay_i;
                mem_lsop<=ex_lsop0;
                mem_memaddr<=ex_memaddr;
                mem_reg2<=ex_reg20;
            end
                
        end
endmodule
