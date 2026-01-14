`define func_add        6'b100000
`define func_addu       6'b100001
`define func_sub        6'b100010
`define func_subu       6'b100011
`define func_slt        6'b101010
`define func_sltu       6'b101011
`define func_and        6'b100100
`define func_or         6'b100101
`define func_xor        6'b100110
`define func_nor        6'b100111
`define func_sll        6'b000000
`define func_srl        6'b000010
`define func_sra        6'b000011
`define func_sllv       6'b000100
`define func_srlv       6'b000101 // Note: Standard MIPS srlv is 000110, srav is 000111. Checking standard.
// Standard: sllv 04, srlv 06, srav 07.
`define func_srlv_real  6'b000110
`define func_srav       6'b000111
`define func_jr         6'b001000
`define func_jalr       6'b001001
`define func_mfhi       6'b010000
`define func_mthi       6'b010001
`define func_mflo       6'b010010
`define func_mtlo       6'b010011
`define func_mult       6'b011000
`define func_multu      6'b011001
`define func_div        6'b011010
`define func_divu       6'b011011
`define func_syscall    6'b001100
`define func_break      6'b001101

`define op_type         6'b000000
`define op_regimm       6'b000001
`define op_j            6'b000010
`define op_jal          6'b000011
`define op_beq          6'b000100
`define op_bne          6'b000101
`define op_blez         6'b000110
`define op_bgtz         6'b000111
`define op_addi         6'b001000
`define op_addiu        6'b001001
`define op_slti         6'b001010
`define op_sltiu        6'b001011
`define op_andi         6'b001100
`define op_ori          6'b001101
`define op_xori         6'b001110
`define op_lui          6'b001111
`define op_lb           6'b100000
`define op_lh           6'b100001
`define op_lw           6'b100011
`define op_lbu          6'b100100
`define op_lhu          6'b100101
`define op_sb           6'b101000
`define op_sh           6'b101001
`define op_sw           6'b101011

// ALU Operations (extended to 6 bits or encoded efficiently)
// Using 6 bits to simplify mapping
`define alu_nop         6'b000000
`define alu_add         6'b000001
`define alu_addu        6'b000010
`define alu_sub         6'b000011
`define alu_subu        6'b000100
`define alu_slt         6'b000101
`define alu_sltu        6'b000110
`define alu_and         6'b000111
`define alu_or          6'b001000
`define alu_xor         6'b001001
`define alu_nor         6'b001010
`define alu_sll         6'b001011
`define alu_srl         6'b001100
`define alu_sra         6'b001101
`define alu_lui         6'b001110
`define alu_sllv        6'b001111
`define alu_srlv        6'b010000
`define alu_srav        6'b010001
`define alu_mult        6'b010010
`define alu_multu       6'b010011
`define alu_div         6'b010100
`define alu_divu        6'b010101
`define alu_mfhi        6'b010110
`define alu_mflo        6'b010111
`define alu_mthi        6'b011000
`define alu_mtlo        6'b011001
`define alu_link        6'b011010 // for jal, jalr (pass pc+8)

// Load/Store Operations (4 bits)
`define lsop_nop        4'b0000
`define lsop_lw         4'b0001
`define lsop_sw         4'b0010
`define lsop_lb         4'b0011
`define lsop_lbu        4'b0100
`define lsop_lh         4'b0101
`define lsop_lhu        4'b0110
`define lsop_sb         4'b0111
`define lsop_sh         4'b1000