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
    // IF_ID Stage
    // Assuming if_id passes PC (or related address) for link instructions. 
    // Based on typical connection:
    wire [31:0] id_pc;
    if_id if_id0(clk,rom_inst_i,id_inst,
    rom_addr_o,id_pc,stall);

    // Regfile
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
    
    // ID_EX Stage
    wire [5:0]id_aluop;    // 6 bits
    wire [31:0]id_reg1;
    wire [31:0]id_reg2;
    wire [4:0]id_wd;
    wire id_wreg;
    wire [5:0]ex_aluop;    // 6 bits
    wire [31:0]ex_reg1;
    wire [31:0]ex_reg2;
    wire [4:0]ex_wd;
    wire ex_wreg;
    wire exDelay_o;
    wire isDelay_o456;
    wire[31:0] id_inst0;
    wire[3:0] id_lsop;     // 4 bits
    wire[31:0] ex_inst;
    wire[3:0] ex_lsop;     // 4 bits

    wire isDelay_o;
    wire nextIsDelay_o;
    
    // Forwarding/Hazard Logic Wires
    wire [31:0] mem_wdata0; 
    wire [4:0] mem_wd0;
    wire mem_wreg0;
    wire [31:0] ex_wdata0;
    wire [4:0] ex_wd0;
    wire ex_wreg0;
    wire [3:0] ex_lsop0;   // 4 bits

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

    // EX_MEM Stage
    wire [31:0]mem_data;
    wire [4:0]mem_wd;
    wire mem_wreg;
    wire exDelay_i;
    wire memDelay_o;
    
    wire[31:0]ex_memaddr;
    wire[31:0]ex_reg20;
    wire [3:0]mem_lsop;    // 4 bits
    wire[31:0]mem_memaddr;
    wire[31:0]mem_reg2;

    // ALU (Note: added clk and rst for HILO regs)
    alu alu0(clk, rst, ex_aluop,ex_reg1,ex_reg2,ex_wd,
    ex_wreg,ex_wdata0,ex_wd0,ex_wreg0,
    exDelay_o,exDelay_i,ex_inst,ex_lsop,
    ex_lsop0,ex_memaddr,ex_reg20);

    ex_mem ex_mem0(clk,ex_wdata0,ex_wd0,
    ex_wreg0,mem_data,mem_wd,mem_wreg,
    exDelay_i,memDelay_o,ex_lsop0,ex_memaddr,
    ex_reg20,mem_lsop,mem_memaddr,mem_reg2,stall);
    
    // MEM Stage
    wire isDelay_o1;
    // Corrected mem instantiation (16 arguments)
    // mem_wdata0 is the output from MEM stage to WB stage (and forwarding)
    mem mem0(
        .wdata_i(mem_data),
        .wd_i(mem_wd),
        .wreg_i(mem_wreg),
        .wdata_o(mem_wdata0),
        .wd_o(mem_wd0),
        .wreg_o(mem_wreg0),
        
        .isDelay_i(memDelay_o),
        .isDelay_o1(isDelay_o1),
        
        .lsop_i(mem_lsop),
        .memaddr_i(mem_memaddr),
        .reg2_i(mem_reg2),
        .mem_data_i(ram_data_o),
        
        .memaddr_o(ram_addr_o),
        .memwe_o(ram_we_o),
        .memce_o(ram_ce_o),
        .memdata_o(ram_data_i)
    );
    
    // MEM_WB Stage
    mem_wb mem_wb0(clk,mem_wdata0,mem_wd0,
    mem_wreg0,wb_wdata,wb_wd,wb_wreg,stall);

endmodule