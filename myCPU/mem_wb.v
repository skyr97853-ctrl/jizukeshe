`timescale 1ns / 1ps

module mem_wb(
        input clk,
        input [31:0] wdata0,
        input [4:0]mem_wd0,
        input mem_wreg0,
        output reg [31:0]wb_wdata,
        output reg[4:0] wb_wd,
        output reg wb_wreg,
        input [5:0]stall,
        
        // 新增 PC 传递接口
        input [31:0] mem_pc,
        output reg [31:0] wb_pc
    );
    always@(posedge clk)begin
        if (stall[4]==1&&stall[5]==0)begin
            wb_wdata<=32'b0;
            wb_wd<=5'b0;
            wb_wreg<=1'b0;
            wb_pc<=32'b0; // Clear PC
        end else if(stall[4]==0) begin
            wb_wdata<=wdata0;
            wb_wd<=mem_wd0;
            wb_wreg<=mem_wreg0;
            wb_pc<=mem_pc; // Pass PC
        end
    end
endmodule