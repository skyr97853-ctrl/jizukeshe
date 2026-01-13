`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/20 10:25:58
// Design Name: 
// Module Name: pipeline_cpu
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
    //decided by ctrl
    wire rst;
    wire stallreq_from_id;
    wire [5:0]stall;
    ctrl ctrl0(rst,stallreq_from_id,stall);
    
    pc pc0(rst,clk,rom_addr_o,rom_ce_o,
    branchF_o,branchAddr_o,stall);
    wire [31:0] id_inst;
    if_id if_id0(clk,rom_inst_i,id_inst,
    rom_addr_o,pc_i,stall);
    
    //regfile
    wire re1;
    wire [4:0]raddr1;
    wire re2;
    wire[4:0]raddr2;
    wire[31:0]rdata1;
    wire[31:0]rdata2;
    regfile regfile0(re1,raddr1,re2,raddr2,wb_wd,wb_wreg,
    wb_wdata,rst,clk,rdata1,rdata2);
    
    //id_ex
    wire [13:0]id_aluop;
    wire [31:0]id_reg1;
    wire [31:0]id_reg2;
    wire [4:0]id_wd;
    wire id_wreg;
    wire [13:0]ex_aluop;
    wire [31:0]ex_reg1;
    wire [31:0]ex_reg2;
    wire [4:0]ex_wd;
    wire ex_wreg;
    wire exDelay_o;
    wire isDelay_o456;//isDelay_o already exists
    wire[31:0] id_inst0;
    wire[1:0] id_lsop;
    wire[31:0] ex_inst;
    wire[1:0] ex_lsop;
    id_ex id_ex0(clk,id_aluop,id_reg1,id_reg2,
    id_wd,id_wreg,ex_aluop,ex_reg1,ex_reg2,
    ex_wd,ex_wreg,isDelay_o,nextIsDelay_o,
    exDelay_o,isDelay_o456,id_inst0,id_lsop,
    ex_inst,ex_lsop,stall);
    
    //decide by id
    wire[31:0] pc_i;
    //wire isDelay_i;
    wire isDelay_o;
    wire nextIsDelay_o;
    wire branchF_o;
    wire[31:0]branchAddr_o;
    id id0(id_inst,rdata1,rdata2,id_aluop,id_reg1,id_reg2,
    id_wd,id_wreg,raddr2,re2,raddr1,re1,pc_i,isDelay_o456,
    isDelay_o,nextIsDelay_o,branchF_o,branchAddr_o,
    id_inst0,id_lsop,mem_wdata0,mem_wd0,mem_wreg0,
    ex_wdata0,ex_wd0, ex_wreg0,ex_lsop0,stallreq_from_id);
    
    //ex_mem
    wire [31:0]ex_wdata0;
    wire [4:0]ex_wd0;
    wire ex_wreg0;
    wire [31:0]mem_data;
    wire [4:0]mem_wd;
    wire mem_wreg;
    wire exDelay_i;
    wire memDelay_o;
    wire[1:0]ex_lsop0;
    wire[31:0]ex_memaddr;
    wire[31:0]ex_reg20;
    wire [1:0]mem_lsop;
    wire[31:0]mem_memaddr;
    wire[31:0]mem_reg2;
    ex_mem ex_mem0(clk,ex_wdata0,ex_wd0,
    ex_wreg0,mem_data,mem_wd,mem_wreg,
    exDelay_i,memDelay_o,ex_lsop0,ex_memaddr,
    ex_reg20,mem_lsop,mem_memaddr,mem_reg2,stall);
    
    alu alu0(ex_aluop,ex_reg1,ex_reg2,ex_wd,
    ex_wreg,ex_wdata0,ex_wd0,ex_wreg0,
    exDelay_o,exDelay_i,ex_inst,ex_lsop,
    ex_lsop0,ex_memaddr,ex_reg20);
    
    //mem_wb
    wire [31:0] mem_wdata0;
    wire[4:0]mem_wd0;
    wire mem_wreg0;
    wire [31:0]wb_wdata;
    wire [4:0] wb_wd;
    wire wb_wreg;
        
    mem_wb mem_wb0(clk,mem_wdata0,mem_wd0,
    mem_wreg0,wb_wdata,wb_wd,wb_wreg,stall);
    
    //decided by mem
    wire isDelay_o1;
    mem mem0(mem_data,mem_wd,mem_wreg,
    mem_wdata0,mem_wd0,mem_wreg0,memDelay_o,
    isDelay_o1,mem_lsop,mem_memaddr,mem_reg2,
    ram_data_o,ram_addr_o,ram_we_o,ram_ce_o,
    ram_data_i);

endmodule
