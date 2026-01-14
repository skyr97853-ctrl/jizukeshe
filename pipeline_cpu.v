`timescale 1ns / 1ps
`include "defines.v"

module pipeline_cpu(
        input wire clk,rst,
        input wire[31:0]rom_inst_i,
        output wire rom_ce_o,
        output wire[31:0]rom_addr_o,
        output wire[31:0]ram_addr_o,
        output wire ram_ce_o,
        output wire ram_we_o,
        output wire [31:0]ram_data_i,
        input wire[31:0] ram_data_o
    );

    wire stallreq_from_id;
    wire [5:0]stall;
    ctrl ctrl0(rst,stallreq_from_id,stall);
    
    wire branchF_o;
    wire [31:0]branchAddr_o;

    pc pc0(rst,clk,rom_addr_o,rom_ce_o,
    branchF_o,branchAddr_o,stall);
    
    wire [31:0] id_inst;
    wire [31:0] pc_i; // Connect PC to ID
    assign pc_i = rom_addr_o; // Assuming IF/ID passes PC or we take current (delay slot handling might need PC pipeline, but usually passed via if_id)
    // Wait, pc_i in id is usually ID stage PC. rom_addr_o is IF stage PC.
    // The provided code snippet had "input[31:0] pc_i" in ID but didn't clearly show where it came from in pipeline_cpu.
    // Standard pipeline passes PC through IF/ID.
    // Let's assume if_id passes PC.
    wire [31:0] id_pc;
    
    if_id if_id0(clk,rom_inst_i,id_inst,
    rom_addr_o,id_pc,stall); // Modified if_id to pass PC if supported, else use rom_addr_o (which is next PC). 
    // *Constraint Check*: I don't have if_id.v code. 
    // However, the original pipeline_cpu.v had:
    // if_id if_id0(clk,rom_inst_i,id_inst, rom_addr_o,pc_i,stall); 
    // This implies if_id outputs `pc_i` (the 5th port). 
    // So `id_pc` (wire) connects to `pc_i` (port) of if_id.

    //regfile
    wire re1;
    wire [4:0]raddr1;
    wire re2;
    wire[4:0]raddr2;
    wire[31:0]rdata1;
    wire[31:0]rdata2;
    wire [31:0]wb_wdata;
    wire [4:0] wb_wd;
    wire wb_wreg;

    regfile regfile0(re1,raddr1,re2,raddr2,wb_wd,wb_wreg,
    wb_wdata,rst,clk,rdata1,rdata2);
    
    //id_ex
    wire [5:0]id_aluop; // Expanded
    wire [31:0]id_reg1;
    wire [31:0]id_reg2;
    wire [4:0]id_wd;
    wire id_wreg;
    wire [5:0]ex_aluop; // Expanded
    wire [31:0]ex_reg1;
    wire [31:0]ex_reg2;
    wire [4:0]ex_wd;
    wire ex_wreg;
    wire exDelay_o;
    wire isDelay_o456;
    wire[31:0] id_inst0;
    wire[3:0] id_lsop; // Expanded
    wire[31:0] ex_inst;
    wire[3:0] ex_lsop; // Expanded

    wire isDelay_o;
    wire nextIsDelay_o;
    
    // Wire declarations for forwarding in ID
    wire [31:0] mem_wdata0; 
    wire [4:0] mem_wd0;
    wire mem_wreg0;
    wire [31:0] ex_wdata0;
    wire [4:0] ex_wd0;
    wire ex_wreg0;
    wire [3:0] ex_lsop0; // Expanded

    id id0(id_inst,rdata1,rdata2,id_aluop,id_reg1,id_reg2,
    id_wd,id_wreg,raddr2,re2,raddr1,re1,id_pc,isDelay_o456,
    isDelay_o,nextIsDelay_o,branchF_o,branchAddr_o,
    id_inst0,id_lsop,mem_wdata0,mem_wd0,mem_wreg0,
    ex_wdata0,ex_wd0, ex_wreg0,ex_lsop,stallreq_from_id);

    id_ex id_ex0(clk,id_aluop,id_reg1,id_reg2,
    id_wd,id_wreg,ex_aluop,ex_reg1,ex_reg2,
    ex_wd,ex_wreg,isDelay_o,nextIsDelay_o,
    exDelay_o,isDelay_o456,id_inst0,id_lsop,
    ex_inst,ex_lsop,stall);

    //ex_mem
    wire [31:0]mem_data;
    wire [4:0]mem_wd;
    wire mem_wreg;
    wire exDelay_i;
    wire memDelay_o;
    
    wire[31:0]ex_memaddr;
    wire[31:0]ex_reg20;
    wire [3:0]mem_lsop; // Expanded
    wire[31:0]mem_memaddr;
    wire[31:0]mem_reg2;

    // ALU needs clk/rst now
    alu alu0(clk, rst, ex_aluop,ex_reg1,ex_reg2,ex_wd,
    ex_wreg,ex_wdata0,ex_wd0,ex_wreg0,
    exDelay_o,exDelay_i,ex_inst,ex_lsop,
    ex_lsop0,ex_memaddr,ex_reg20);

    ex_mem ex_mem0(clk,ex_wdata0,ex_wd0,
    ex_wreg0,mem_data,mem_wd,mem_wreg,
    exDelay_i,memDelay_o,ex_lsop0,ex_memaddr,
    ex_reg20,mem_lsop,mem_memaddr,mem_reg2,stall);
    
    //mem_wb
    wire [31:0] mem_wdata_out; // Data from MEM stage to MEM_WB
    
    mem mem0(mem_data,mem_wd,mem_wreg,
    mem_wdata0,mem_wd0,mem_wreg0,memDelay_o,
    isDelay_o1,mem_lsop,mem_memaddr,mem_reg2,
    ram_data_o,ram_addr_o,ram_we_o,ram_ce_o,
    ram_data_i, mem_wdata_out); // Added output port mem_wdata_out (mapped to mem_wdata0 in previous naming but logic is inside mem)
    // Wait, check mem instantiation in original:
    // mem mem0(mem_data, ..., mem_wdata0, ...);
    // In original mem.v: output wdata_o. 
    // So mem_wdata0 is the output of mem module.
    
    mem_wb mem_wb0(clk,mem_wdata0,mem_wd0,
    mem_wreg0,wb_wdata,wb_wd,wb_wreg,stall);
    
    // The previous mem0 instantiation in original file seemed to match ports. 
    // I kept the structure but just need to ensure `lsop` width is consistent.

endmodule