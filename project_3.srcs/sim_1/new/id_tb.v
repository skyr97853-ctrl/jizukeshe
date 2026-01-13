`timescale 1ns / 1ps

module id_tb();
    reg[31:0]inst_i;
    reg[31:0]reg1_data_i;
    reg[31:0]reg2_data_i;
    wire[13:0] aluop_o;
    wire[31:0] reg1_o;
    wire[31:0] reg2_o;
    wire[4:0]wd_o;
    wire wreg;
    wire[4:0]reg2_addr_o;
    wire reg2_read_o;
    wire[4:0]reg1_addr_o;
    wire reg1_read_o;
    
    id id0(inst_i,reg1_data_i,reg2_data_i,aluop_o,
    reg1_o,reg2_o,wd_o,wreg,
    reg2_addr_o,reg2_read_o,reg1_addr_o,reg1_read_o);
    
    reg[31:0] regs[30:0];
    initial begin
        $readmemh("D:/MyCode/EPGA/project_3/project_3.srcs/sim_1/new/inst_rom.data",regs);
    end
    integer i;
    initial begin
        reg1_data_i=32'h12345678;
        reg2_data_i=32'h00001234;
        for(i=0;i<31;i=i+1)begin
            inst_i=regs[i];
            #20;
        end
    end
     
endmodule
