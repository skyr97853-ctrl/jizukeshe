`timescale 1ns / 1ps

module data_ram(
        input clk,
        input wire[31:0]addr,
        input wire ce,
        input wire we,
        input wire[31:0] data_i,
        output reg[31:0] data_o
    );
        reg[31:0] ram[511:0];
        always@(*)begin
            if(ce==1&&we==0)
                data_o<=ram[addr[31:2]];
            else 
                data_o<=0;
        end
        always@(posedge clk)begin
            if(ce==1&&we==1)
                ram[addr[31:2]]<=data_i;
        end
endmodule
