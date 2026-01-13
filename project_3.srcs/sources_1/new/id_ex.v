`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 10:45:29
// Design Name: 
// Module Name: id_ex
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


module id_ex(
        input clk,
        input [13:0]id_aluop,
        input [31:0]id_reg1,
        input [31:0]id_reg2,
        input [4:0]id_wd,
        input id_wreg,
        output reg [13:0]ex_aluop,
        output reg [31:0]ex_reg1,
        output reg [31:0]ex_reg2,
        output reg [4:0]ex_wd,
        output reg ex_wreg,
        
        input wire idDelay_i,
        input wire nextIsDelay_i,
        output reg exDelay_o,
        output reg isDelay_o,
        
        input wire[31:0] id_inst0,
        input wire[1:0] id_lsop,
        output reg[31:0] ex_inst,
        output reg[1:0] ex_lsop,
        input [5:0]stall
        
    );
        always@(posedge clk) begin
        if(stall[2]==1&&stall[3]==0)begin
                ex_aluop<=14'b0;
                ex_reg1<=32'b0;
                ex_reg2<=32'b0;
                ex_wd<=5'b0;
                ex_wreg<=0;
                exDelay_o<=0;
                isDelay_o<=0;
                ex_inst<=32'b0;
                ex_lsop<=2'b0;
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
        end

        end
endmodule
