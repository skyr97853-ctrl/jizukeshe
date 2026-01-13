`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 10:54:35
// Design Name: 
// Module Name: mem_wb
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


module mem_wb(
        input clk,
        input [31:0] wdata0,
        input [4:0]mem_wd0,
        input mem_wreg0,
        output reg [31:0]wb_wdata,
        output reg[4:0] wb_wd,
        output reg wb_wreg,
        input [5:0]stall
    );
    always@(posedge clk)begin
        if (stall[4]==1&&stall[5]==0)begin
            wb_wdata<=32'b0;
            wb_wd<=5'b0;
            wb_wreg<=1'b0;
        end else if(stall[4]==0) begin
            wb_wdata<=wdata0;
            wb_wd<=mem_wd0;
            wb_wreg<=mem_wreg0;
        end

    end
endmodule
