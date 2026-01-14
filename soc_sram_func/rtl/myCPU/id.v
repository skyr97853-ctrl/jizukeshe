`timescale 1ns / 1ps
`include "defines.v"

module id(
    input [31:0]inst_i,
    input [31:0]reg1_data_i,
    input [31:0]reg2_data_i,
    output reg[5:0] aluop_o, // Changed width to 6
    output[31:0] reg1_o,
    output[31:0] reg2_o,
    output reg[4:0]wd_o,
    output reg wreg,
    output[4:0]reg2_addr_o,
    output reg2_read_o,
    output[4:0]reg1_addr_o,
    output reg1_read_o,
    
    input[31:0] pc_i,
    input isDelay_i,
    output isDelay_o,
    output nextIsDelay_o,
    output branchF_o,
    output [31:0]branchAddr_o,
    
    output [31:0] inst_o,
    output reg [3:0] lsop_o, // Changed width to 4
    
    input [31:0]memwdata_b,
    input [4:0]memwd_b,
    input memwreg_b,
    input [31:0]exwdata_b,
    input[4:0]exwd_b,
    input exwreg_b,
    input [3:0]ex_lsop_i, // Changed width to 4
    output stallreq
    );
    assign inst_o=inst_i;
    
    wire[5:0] op = inst_i[31:26];
    wire[4:0] rs = inst_i[25:21];
    wire[4:0] rt = inst_i[20:16];
    wire[4:0] rd = inst_i[15:11];
    wire[4:0] sa = inst_i[10:6];
    wire[5:0] func = inst_i[5:0];
    wire[15:0] imm16 = inst_i[15:0];
    wire[25:0] instr_index = inst_i[25:0];

    // Instruction Decoding
    wire inst_type_r = (op == `op_type);
    wire inst_regimm = (op == `op_regimm);
    
    // R-type
    wire inst_add   = inst_type_r && (func == `func_add);
    wire inst_addu  = inst_type_r && (func == `func_addu);
    wire inst_sub   = inst_type_r && (func == `func_sub);
    wire inst_subu  = inst_type_r && (func == `func_subu);
    wire inst_slt   = inst_type_r && (func == `func_slt);
    wire inst_sltu  = inst_type_r && (func == `func_sltu);
    wire inst_and   = inst_type_r && (func == `func_and);
    wire inst_or    = inst_type_r && (func == `func_or);
    wire inst_xor   = inst_type_r && (func == `func_xor);
    wire inst_nor   = inst_type_r && (func == `func_nor);
    wire inst_sll   = inst_type_r && (func == `func_sll);
    wire inst_srl   = inst_type_r && (func == `func_srl);
    wire inst_sra   = inst_type_r && (func == `func_sra);
    wire inst_sllv  = inst_type_r && (func == `func_sllv);
    wire inst_srlv  = inst_type_r && (func == `func_srlv_real);
    wire inst_srav  = inst_type_r && (func == `func_srav);
    wire inst_jr    = inst_type_r && (func == `func_jr);
    wire inst_jalr  = inst_type_r && (func == `func_jalr);
    wire inst_mfhi  = inst_type_r && (func == `func_mfhi);
    wire inst_mflo  = inst_type_r && (func == `func_mflo);
    wire inst_mthi  = inst_type_r && (func == `func_mthi);
    wire inst_mtlo  = inst_type_r && (func == `func_mtlo);
    wire inst_mult  = inst_type_r && (func == `func_mult);
    wire inst_multu = inst_type_r && (func == `func_multu);
    wire inst_div   = inst_type_r && (func == `func_div);
    wire inst_divu  = inst_type_r && (func == `func_divu);

    // I-type
    wire inst_addi  = (op == `op_addi);
    wire inst_addiu = (op == `op_addiu);
    wire inst_slti  = (op == `op_slti);
    wire inst_sltiu = (op == `op_sltiu);
    wire inst_andi  = (op == `op_andi);
    wire inst_ori   = (op == `op_ori);
    wire inst_xori  = (op == `op_xori);
    wire inst_lui   = (op == `op_lui);
    wire inst_lw    = (op == `op_lw);
    wire inst_sw    = (op == `op_sw);
    wire inst_lb    = (op == `op_lb);
    wire inst_lbu   = (op == `op_lbu);
    wire inst_lh    = (op == `op_lh);
    wire inst_lhu   = (op == `op_lhu);
    wire inst_sb    = (op == `op_sb);
    wire inst_sh    = (op == `op_sh);
    wire inst_beq   = (op == `op_beq);
    wire inst_bne   = (op == `op_bne);
    wire inst_bgtz  = (op == `op_bgtz);
    wire inst_blez  = (op == `op_blez);

    // J-type
    wire inst_j     = (op == `op_j);
    wire inst_jal   = (op == `op_jal);
    
    // RegImm
    wire inst_bgez   = inst_regimm && (rt == 5'b00001);
    wire inst_bltz   = inst_regimm && (rt == 5'b00000);
    wire inst_bgezal = inst_regimm && (rt == 5'b10001);
    wire inst_bltzal = inst_regimm && (rt == 5'b10000);

    // ALU Op Assignment
    always @(*) begin
        if(inst_add || inst_addi) aluop_o = `alu_add;
        else if(inst_addu || inst_addiu) aluop_o = `alu_addu;
        else if(inst_sub) aluop_o = `alu_sub;
        else if(inst_subu) aluop_o = `alu_subu;
        else if(inst_slt || inst_slti) aluop_o = `alu_slt;
        else if(inst_sltu || inst_sltiu) aluop_o = `alu_sltu;
        else if(inst_and || inst_andi) aluop_o = `alu_and;
        else if(inst_or || inst_ori) aluop_o = `alu_or;
        else if(inst_xor || inst_xori) aluop_o = `alu_xor;
        else if(inst_nor) aluop_o = `alu_nor;
        else if(inst_sll) aluop_o = `alu_sll;
        else if(inst_srl) aluop_o = `alu_srl;
        else if(inst_sra) aluop_o = `alu_sra;
        else if(inst_sllv) aluop_o = `alu_sllv;
        else if(inst_srlv) aluop_o = `alu_srlv;
        else if(inst_srav) aluop_o = `alu_srav;
        else if(inst_lui) aluop_o = `alu_lui;
        else if(inst_mfhi) aluop_o = `alu_mfhi;
        else if(inst_mflo) aluop_o = `alu_mflo;
        else if(inst_mthi) aluop_o = `alu_mthi;
        else if(inst_mtlo) aluop_o = `alu_mtlo;
        else if(inst_mult) aluop_o = `alu_mult;
        else if(inst_multu) aluop_o = `alu_multu;
        else if(inst_div) aluop_o = `alu_div;
        else if(inst_divu) aluop_o = `alu_divu;
        else if(inst_jal || inst_bgezal || inst_bltzal || inst_jalr) aluop_o = `alu_link;
        else aluop_o = `alu_nop;
    end

    // Load/Store Op
    always @(*) begin
        if(inst_lw) lsop_o = `lsop_lw;
        else if(inst_sw) lsop_o = `lsop_sw;
        else if(inst_lb) lsop_o = `lsop_lb;
        else if(inst_lbu) lsop_o = `lsop_lbu;
        else if(inst_lh) lsop_o = `lsop_lh;
        else if(inst_lhu) lsop_o = `lsop_lhu;
        else if(inst_sb) lsop_o = `lsop_sb;
        else if(inst_sh) lsop_o = `lsop_sh;
        else lsop_o = `lsop_nop;
    end

    // WREG Control
    always @(*) begin
        if(inst_beq || inst_bne || inst_bgez || inst_bgtz || inst_blez || inst_bltz || inst_j || inst_jr || inst_sw || inst_sb || inst_sh || inst_mthi || inst_mtlo || inst_mult || inst_multu || inst_div || inst_divu)
            wreg = 0;
        else
            wreg = 1;
    end

    // Dest Register (wd)
    always @(*) begin
        if(inst_jal) wd_o = 31;
        else if(inst_bgezal || inst_bltzal) wd_o = 31;
        else if(inst_jalr) wd_o = rd;
        else if(inst_addi || inst_addiu || inst_slti || inst_sltiu || inst_andi || inst_ori || inst_xori || inst_lui || inst_lw || inst_lb || inst_lbu || inst_lh || inst_lhu)
            wd_o = rt;
        else
            wd_o = rd;
    end

    // Register Read Control
    assign reg1_read_o = !(inst_sll || inst_srl || inst_sra || inst_lui || inst_j || inst_jal || inst_mfhi || inst_mflo); // Shift imm uses sa, not rs. jal/j don't use rs.
    assign reg2_read_o = !(inst_addi || inst_addiu || inst_slti || inst_sltiu || inst_andi || inst_ori || inst_xori || inst_lui || inst_lw || inst_lb || inst_lbu || inst_lh || inst_lhu || inst_j || inst_jal || inst_jr || inst_bgez || inst_bgtz || inst_blez || inst_bltz || inst_bgezal || inst_bltzal || inst_mfhi || inst_mflo);

    assign reg1_addr_o = rs;
    assign reg2_addr_o = rt;

    // Immediate Extension
    wire zero_ext = (inst_andi || inst_ori || inst_xori || inst_lui);
    wire [31:0] imm_ext = zero_ext ? {16'b0, imm16} : {{16{imm16[15]}}, imm16};
    
    // Shift Amount (sa)
    wire [31:0] sa_ext = {27'b0, sa};

    // Operands Mux (Forwarding handled implicitly by mux vars logic below)
    wire [31:0] reg1_mux;
    wire [31:0] reg2_mux;

    // Helper: Forwarding Logic
    assign reg1_mux=((exwreg_b==1)&&(reg1_read_o==1)&&(reg1_addr_o==exwd_b))?(exwdata_b):(
       ((memwreg_b==1)&&(reg1_read_o==1)&&(memwd_b==reg1_addr_o))?(memwdata_b):(reg1_read_o?reg1_data_i:32'b0));

    assign reg2_mux=((exwreg_b==1)&&(reg2_read_o==1)&&(reg2_addr_o==exwd_b))?(exwdata_b):(
       ((memwreg_b==1)&&(reg2_read_o==1)&&(memwd_b==reg2_addr_o))?(memwdata_b):(reg2_read_o?reg2_data_i:32'b0));

    // Final Operands to ALU
    // For Shifts (imm), reg1 input to ALU is sa. For JAL/Link, we pass PC+8.
    assign reg1_o = (inst_sll || inst_srl || inst_sra) ? sa_ext : 
                    (inst_jal || inst_bgezal || inst_bltzal || inst_jalr) ? (pc_i + 8) : 
                    reg1_mux;
    
    assign reg2_o = (inst_addi || inst_addiu || inst_slti || inst_sltiu || inst_andi || inst_ori || inst_xori || inst_lui || inst_lw || inst_lb || inst_lbu || inst_lh || inst_lhu || inst_sw || inst_sb || inst_sh) ? imm_ext : 
                    (inst_jal || inst_bgezal || inst_bltzal || inst_jalr) ? 32'b0 : // Link writes PC+8 (in reg1_o) + 0
                    reg2_mux;

    // Branch Logic
    wire rs_eq_rt = (reg1_mux == reg2_mux);
    wire rs_gez   = ($signed(reg1_mux) >= 0);
    wire rs_gtz   = ($signed(reg1_mux) > 0);
    wire rs_lez   = ($signed(reg1_mux) <= 0);
    wire rs_ltz   = ($signed(reg1_mux) < 0);

    assign branchF_o = (inst_beq && rs_eq_rt) ||
                       (inst_bne && !rs_eq_rt) ||
                       (inst_bgez && rs_gez) ||
                       (inst_bgtz && rs_gtz) ||
                       (inst_blez && rs_lez) ||
                       (inst_bltz && rs_ltz) ||
                       (inst_bgezal && rs_gez) ||
                       (inst_bltzal && rs_ltz) ||
                       inst_j || inst_jal || inst_jr || inst_jalr;

    // Branch Address
    wire [31:0] pc_plus_4 = pc_i + 4;
    wire [31:0] offset_shifted = {{14{imm16[15]}}, imm16, 2'b00};
    wire [31:0] branch_target = pc_plus_4 + offset_shifted;
    wire [31:0] jump_target = {pc_plus_4[31:28], instr_index, 2'b00};
    wire [31:0] jr_target = reg1_mux;

    assign branchAddr_o = (inst_jr || inst_jalr) ? jr_target :
                          (inst_j || inst_jal) ? jump_target :
                          branch_target;

    assign isDelay_o = isDelay_i;
    assign nextIsDelay_o = branchF_o; // Simplification: any branch/jump instruction is a delay slot generator

    // Stall Request (Load Use Hazard)
    wire preinstislw = (ex_lsop_i == `lsop_lw || ex_lsop_i == `lsop_lb || ex_lsop_i == `lsop_lbu || ex_lsop_i == `lsop_lh || ex_lsop_i == `lsop_lhu);
    wire stallreqforreg1 = (preinstislw && exwreg_b && reg1_read_o && (reg1_addr_o == exwd_b));
    wire stallreqforreg2 = (preinstislw && exwreg_b && reg2_read_o && (reg2_addr_o == exwd_b));
    assign stallreq = stallreqforreg1 || stallreqforreg2;

endmodule