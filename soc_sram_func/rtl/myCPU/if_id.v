`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 10:43:08
// Design Name: 
// Module Name: if_id
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


module if_id(
        input clk,
        input [31:0]if_inst,
        output reg [31:0]id_inst,
        input wire[31:0] if_pc,
        output reg[31:0] id_pc,
        input [5:0]stall
    );
    always@(posedge clk)begin
    if(stall[1]==1&&stall[2]==0)begin
        id_inst<=32'b0;
        id_pc<=32'b0;
    end else if(stall[1]==0)begin
        id_inst<=if_inst;
        id_pc<=if_pc;
       end
    end
endmodule
