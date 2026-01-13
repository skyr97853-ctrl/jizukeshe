`timescale 1ns / 1ps

module inst_fetch(
    input wire rst,clk,
    output wire[31:0] inst_o
    );
    wire[31:0] pc;
    wire ce;
    
    pc pc0(rst,clk,pc,ce);
    inst_rom inst_rom0(clk,ce,pc,inst_o);
    //rom rom_0(pc[31:2],ce,inst_o);
endmodule
