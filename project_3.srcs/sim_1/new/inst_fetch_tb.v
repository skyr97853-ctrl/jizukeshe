`timescale 1ns / 1ps


module inst_fetch_tb();
    reg rst,clk;
    wire [31:0] inst_o;
    inst_fetch inst_fetch0(rst,clk,inst_o);
    
    always #10 clk = ~clk;
    initial begin
        clk=1;
        rst=1;
        #100;
        rst=0;
        #100;
        $finish;
    end
endmodule
