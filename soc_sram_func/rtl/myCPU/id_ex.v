`timescale 1ns / 1ps
`include "defines.v"

module id_ex(
        input clk,
        input [5:0]id_aluop,
        input [31:0]id_reg1,
        input [31:0]id_reg2,
        input [4:0]id_wd,
        input id_wreg,
   
        output reg [5:0]ex_aluop,
        output reg [31:0]ex_reg1,
        output reg [31:0]ex_reg2,
        output reg [4:0]ex_wd,
        output reg ex_wreg,
        
        input wire idDelay_i,
        input wire nextIsDelay_i,
        output reg exDelay_o,
        output reg isDelay_o,
     
        input wire[31:0] id_inst0,
        input wire[3:0] id_lsop,
        output reg[31:0] ex_inst,
        output reg[3:0] ex_lsop,
        input [5:0]stall,
        
        // 新增 PC 传递接口
        input [31:0] id_pc,
        output reg [31:0] ex_pc
    );
    always@(posedge clk) begin
        if(stall[2]==1&&stall[3]==0)begin
                ex_aluop<=6'b0;
                ex_reg1<=32'b0;
                ex_reg2<=32'b0;
                ex_wd<=5'b0;
                ex_wreg<=0;
                exDelay_o<=0;
                isDelay_o<=0;
                ex_inst<=32'b0;
                ex_lsop<=4'b0;
                ex_pc <= 32'b0; // Clear PC
        end else if(stall[2]==0)begin
                ex_aluop<=id_aluop;
                ex_reg1<=id_reg1;
                ex_reg2<=id_reg2;
                ex_wd<=id_wd;
                ex_wreg<=id_wreg;
                exDelay_o<=idDelay_i;
                isDelay_o<=nextIsDelay_i;
                ex_inst<=id_inst0;
                ex_lsop<=id_lsop;
                ex_pc <= id_pc; // Pass PC
        end
    end
endmodule