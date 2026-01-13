`timescale 1ns / 1ps

module inst_rom(
    input wire clk,ce,
    input wire[31:0] addr,
    output reg[31:0] inst
    );
    reg[31:0] rom[127:0];
    initial begin
        $readmemh("D:/test/inst_rom11.data",rom);
    end
    always@(*)begin
        if(ce==1)
            inst<=rom[addr[31:2]];
        else 
            inst<=0;
    end
endmodule
