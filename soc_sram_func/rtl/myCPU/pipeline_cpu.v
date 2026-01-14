`timescale 1ns / 1ps
`include "defines.v"

module pipeline_cpu(
        input wire clk,
        input wire rst,
        input wire[31:0] rom_inst_i,
        output wire rom_ce_o,
        output wire[31:0] rom_addr_o,
        output wire[31:0] ram_addr_o,
        output wire ram_ce_o,
        output wire ram_we_o,
        output wire [31:0] ram_data_i,
        input wire[31:0] ram_data_o,
        
        // 新增接口用于 SoC 适配
        output wire [3:0] mem_lsop_out, 
        
        // Debug 接口信号
        output wire [31:0] debug_wb_pc,
        output wire debug_wb_rf_wen_bit,
        output wire [4:0] debug_wb_rf_wnum,
        output wire [31:0] debug_wb_rf_wdata
    );

    wire stallreq_from_id;
    wire [5:0] stall;
    ctrl ctrl0(rst, stallreq_from_id, stall);
    
    wire branchF_o;
    wire [31:0] branchAddr_o;

    // PC 模块
    pc pc0(rst, clk, rom_addr_o, rom_ce_o, branchF_o, branchAddr_o, stall);
    
    // IF_ID Stage
    wire [31:0] id_inst;
    wire [31:0] id_pc; 
    
    if_id if_id0(
        .clk(clk),
        .if_inst(rom_inst_i),
        .id_inst(id_inst),
        .if_pc(rom_addr_o), 
        .id_pc(id_pc),      
        .stall(stall)
    );

    // Regfile
    wire re1, re2;
    wire [4:0] raddr1, raddr2;
    wire [31:0] rdata1, rdata2;
    wire [31:0] wb_wdata;
    wire [4:0] wb_wd;
    wire wb_wreg;

    regfile regfile0(re1, raddr1, re2, raddr2, wb_wd, wb_wreg, wb_wdata, rst, clk, rdata1, rdata2);
    
    // ID 阶段信号
    wire [5:0] id_aluop;
    wire [31:0] id_reg1, id_reg2;
    wire [4:0] id_wd;
    wire id_wreg;
    wire isDelay_o, nextIsDelay_o, isDelay_o456;
    wire [31:0] id_inst0;
    wire [3:0] id_lsop;
    
    // Forwarding wires
    wire [31:0] mem_wdata0; 
    wire [4:0] mem_wd0;
    wire mem_wreg0;
    wire [31:0] ex_wdata0;
    wire [4:0] ex_wd0;
    wire ex_wreg0;
    wire [3:0] ex_lsop0;
    wire [3:0] ex_lsop;

    id id0(
        .inst_i(id_inst),
        .reg1_data_i(rdata1), .reg2_data_i(rdata2),
        .aluop_o(id_aluop),
        .reg1_o(id_reg1), .reg2_o(id_reg2),
        .wd_o(id_wd), .wreg(id_wreg),
        .reg2_addr_o(raddr2), .reg2_read_o(re2),
        .reg1_addr_o(raddr1), .reg1_read_o(re1),
        .pc_i(id_pc), 
        .isDelay_i(isDelay_o456), .isDelay_o(isDelay_o), .nextIsDelay_o(nextIsDelay_o),
        .branchF_o(branchF_o), .branchAddr_o(branchAddr_o),
        .inst_o(id_inst0),
        .lsop_o(id_lsop),
        // Forwarding inputs
        .memwdata_b(mem_wdata0), .memwd_b(mem_wd0), .memwreg_b(mem_wreg0),
        .exwdata_b(ex_wdata0), .exwd_b(ex_wd0), .exwreg_b(ex_wreg0), .ex_lsop_i(ex_lsop),
        .stallreq(stallreq_from_id)
    );

    // ID_EX Stage
    wire [5:0] ex_aluop;
    wire [31:0] ex_reg1, ex_reg2;
    wire [4:0] ex_wd;
    wire ex_wreg;
    wire exDelay_o;
    wire [31:0] ex_inst;
    wire [31:0] ex_pc; 

    id_ex id_ex0(
        .clk(clk),
        .id_aluop(id_aluop),
        .id_reg1(id_reg1), .id_reg2(id_reg2),
        .id_wd(id_wd), .id_wreg(id_wreg),
        .ex_aluop(ex_aluop),
        .ex_reg1(ex_reg1), .ex_reg2(ex_reg2),
        .ex_wd(ex_wd), .ex_wreg(ex_wreg),
        .idDelay_i(isDelay_o), .nextIsDelay_i(nextIsDelay_o),
        .exDelay_o(exDelay_o), .isDelay_o(isDelay_o456),
        .id_inst0(id_inst0), .id_lsop(id_lsop),
        .ex_inst(ex_inst), .ex_lsop(ex_lsop),
        .stall(stall),
        .id_pc(id_pc), .ex_pc(ex_pc)
    );

    // EX_MEM Stage
    wire [31:0] mem_data;
    wire [4:0] mem_wd;
    wire mem_wreg;
    wire exDelay_i;
    wire memDelay_o;
    wire [31:0] ex_memaddr, ex_reg20;
    wire [3:0] mem_lsop;
    wire [31:0] mem_memaddr, mem_reg2;
    wire [31:0] mem_pc; 

    // ------------------------------------------------------------------------
    // 修正后的 ALU 实例化
    // ------------------------------------------------------------------------
    alu alu0(
        .clk(clk), 
        .rst(rst),
        .alu_control(ex_aluop),   // 对应 alu.v 的 alu_control
        .alu_src1(ex_reg1),       // 对应 alu.v 的 alu_src1
        .alu_src2(ex_reg2),       // 对应 alu.v 的 alu_src2
        .wd_i(ex_wd),
        .wreg_i(ex_wreg),
        
        .alu_result(ex_wdata0),   // 对应 alu.v 的 alu_result，输出连接到 ex_wdata0
        .wd_o(ex_wd0),            // 对应 alu.v 的 wd_o
        .wreg_o(ex_wreg0),        // 对应 alu.v 的 wreg_o
        
        .isDelay_i(exDelay_o),    // 对应 alu.v 的 isDelay_i
        .isDelay_o(exDelay_i),    // 对应 alu.v 的 isDelay_o
        
        .inst_i(ex_inst),
        .lsop_i(ex_lsop), 
        .lsop_o(ex_lsop0),
        .memaddr_o(ex_memaddr), 
        .reg2_o(ex_reg20)
    );
    // ------------------------------------------------------------------------

    ex_mem ex_mem0(
        .clk(clk),
        .ex_wdata0(ex_wdata0), .ex_wd0(ex_wd0), .ex_wreg0(ex_wreg0),
        .mem_data(mem_data), .mem_wd(mem_wd), .mem_wreg(mem_wreg),
        .exDelay_i(exDelay_i), .memDelay_o(memDelay_o),
        .ex_lsop0(ex_lsop0),
        .ex_memaddr(ex_memaddr), .ex_reg20(ex_reg20),
        .mem_lsop(mem_lsop),
        .mem_memaddr(mem_memaddr), .mem_reg2(mem_reg2),
        .stall(stall),
        .ex_pc(ex_pc), .mem_pc(mem_pc)
    );

    // MEM Stage
    wire isDelay_o1;
    
    assign mem_lsop_out = mem_lsop;

    mem mem0(
        .wdata_i(mem_data), .wd_i(mem_wd), .wreg_i(mem_wreg),
        .wdata_o(mem_wdata0), .wd_o(mem_wd0), .wreg_o(mem_wreg0),
        .isDelay_i(memDelay_o), .isDelay_o1(isDelay_o1),
        .lsop_i(mem_lsop), .memaddr_i(mem_memaddr), .reg2_i(mem_reg2),
        .mem_data_i(ram_data_o),
        .memaddr_o(ram_addr_o), .memwe_o(ram_we_o), .memce_o(ram_ce_o), .memdata_o(ram_data_i)
    );

    // MEM_WB Stage
    wire [31:0] wb_pc; 

    mem_wb mem_wb0(
        .clk(clk),
        .wdata0(mem_wdata0), .mem_wd0(mem_wd0), .mem_wreg0(mem_wreg0),
        .wb_wdata(wb_wdata), .wb_wd(wb_wd), .wb_wreg(wb_wreg),
        .stall(stall),
        .mem_pc(mem_pc), .wb_pc(wb_pc)
    );

    // 连接 Debug 信号
    assign debug_wb_pc = wb_pc;
    assign debug_wb_rf_wen_bit = wb_wreg;
    assign debug_wb_rf_wnum = wb_wd;
    assign debug_wb_rf_wdata = wb_wdata;

endmodule
