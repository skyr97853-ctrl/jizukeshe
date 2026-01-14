`timescale 1ns / 1ps
`include "defines.v"

module alu(
    input clk,  // Added clk
    input rst,  // Added rst
    input[5:0] alu_control, // Changed width
    input[31:0] alu_src1,
    input[31:0] alu_src2,
    input[4:0] wd_i,
    input wreg_i,
    output reg[31:0] alu_result,
    output[4:0] wd_o,
    output wreg_o,
    
    input isDelay_i,
    output isDelay_o,
    
    input wire[31:0] inst_i,
    input wire[3:0] lsop_i, // Changed width
    output wire[3:0] lsop_o,
    output wire[31:0]memaddr_o,
    output wire[31:0]reg2_o
    );

    assign lsop_o = lsop_i;
    assign reg2_o = alu_src2;
    assign isDelay_o = isDelay_i;
    assign wd_o = wd_i;
    assign wreg_o = wreg_i;

    // HILO Registers (Internal State for simplicity in this file structure)
    reg [31:0] hi;
    reg [31:0] lo;

    // Logic
    wire [31:0] sum_result = alu_src1 + alu_src2;
    wire [31:0] sub_result = alu_src1 - alu_src2;
    wire signed [31:0] src1_signed = alu_src1;
    wire signed [31:0] src2_signed = alu_src2;
    
    // Shift amounts: src1[4:0] for variable shifts, src1 (which is sa) for immediate shifts
    wire [4:0] shamt = alu_src1[4:0]; 

    always @(*) begin
        case (alu_control)
            `alu_add, `alu_addu: alu_result = sum_result;
            `alu_sub, `alu_subu: alu_result = sub_result;
            `alu_and: alu_result = alu_src1 & alu_src2;
            `alu_or:  alu_result = alu_src1 | alu_src2;
            `alu_xor: alu_result = alu_src1 ^ alu_src2;
            `alu_nor: alu_result = ~(alu_src1 | alu_src2);
            `alu_slt: alu_result = (src1_signed < src2_signed) ? 1 : 0;
            `alu_sltu: alu_result = (alu_src1 < alu_src2) ? 1 : 0;
            `alu_lui: alu_result = {alu_src2[15:0], 16'b0}; // id puts imm in src2
            
            // Shift operations. 
            // Note: ID logic sends `sa` (extended) to src1 for imm shifts. 
            // For var shifts, rs is in src1. 
            `alu_sll: alu_result = alu_src2 << shamt; // src2 is rt, src1 is sa
            `alu_srl: alu_result = alu_src2 >> shamt;
            `alu_sra: alu_result = $signed(alu_src2) >>> shamt;
            `alu_sllv: alu_result = alu_src2 << shamt; // src2 is rt, src1 is rs
            `alu_srlv: alu_result = alu_src2 >> shamt;
            `alu_srav: alu_result = $signed(alu_src2) >>> shamt;

            `alu_mfhi: alu_result = hi;
            `alu_mflo: alu_result = lo;
            `alu_link: alu_result = alu_src1; // ID puts PC+8 in src1
            
            default: alu_result = 0;
        endcase
    end

    // HILO Update Logic (Sequential)
    always @(posedge clk) begin
        if (rst) begin
            hi <= 0;
            lo <= 0;
        end else begin
            if (alu_control == `alu_mthi) begin
                hi <= alu_src1;
            end else if (alu_control == `alu_mtlo) begin
                lo <= alu_src1;
            end else if (alu_control == `alu_mult) begin
                {hi, lo} <= src1_signed * src2_signed;
            end else if (alu_control == `alu_multu) begin
                {hi, lo} <= alu_src1 * alu_src2;
            end else if (alu_control == `alu_div) begin
                if(alu_src2 != 0) begin
                   lo <= src1_signed / src2_signed;
                   hi <= src1_signed % src2_signed;
                end
            end else if (alu_control == `alu_divu) begin
                if(alu_src2 != 0) begin
                   lo <= alu_src1 / alu_src2;
                   hi <= alu_src1 % alu_src2;
                end
            end
        end
    end

    assign memaddr_o = {{16{inst_i[15]}},inst_i[15:0]} + alu_src1;

endmodule