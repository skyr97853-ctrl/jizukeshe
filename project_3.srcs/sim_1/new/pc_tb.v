`timescale 1ns / 1ps

module pc_tb();
    reg rst,clk;
    wire[31:0]pc;
    wire ce;
    pc pc1(rst,clk,pc,ce);
    initial begin
        clk=1;
        forever #10
        clk=~clk;
    end
    initial begin
        rst=1;
        #100;
        rst=0;
        #100;
        $finish;
    end
endmodule
