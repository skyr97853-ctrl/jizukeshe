`timescale 1ns / 1ps


module regflile_tb();
    reg re1;
    reg[4:0] raddr1;
    reg re2;
    reg[4:0] raddr2;
    reg[4:0] waddr;
    reg we;
    reg[31:0] wdata;
    reg rst,clk;
    wire[31:0] rdata1;
    wire[31:0] rdata2;
    regfile regfile1(re1,raddr1,re2,raddr2,waddr,we,wdata,rst,clk,rdata1,rdata2);
    
    always #5 clk=~clk;
    

    
    initial begin
        clk = 0;
        rst = 1;
        re1 = 0; re2 = 0;
        we = 0;
        waddr = 5'd0;
        wdata = 32'd0;
        raddr1 = 5'd0;
        raddr2 = 5'd0;

        #20;

        rst = 1;
        re1 = 1; re2 = 1;
        raddr1 = 5'd1;
        raddr2 = 5'd2;
        #20;

        rst = 0;
        raddr1 = 5'd0;
        raddr2 = 5'd0;
        #20;

        waddr = 5'd3;
        wdata = 32'h1234_5678;
        we = 1;
        re1 = 0; re2 = 0;
        #10;
        we = 0;
        #10;

        re1 = 1; re2 = 1;
        raddr1 = 5'd3;
        raddr2 = 5'd0;
        #20;

        waddr = 5'd0;
        wdata = 32'hDEAD_BEEF;
        we = 1;
        #10;
        we = 0;
        #10;

        raddr1 = 5'd0;
        #20;


        re1 = 0;
        #20;

        waddr = 5'd5;
        wdata = 32'hAABB_CCDD;
        we = 1;
        re1 = 0; re2 = 0;
        #10;
        we = 0;

        re1 = 1; raddr1 = 5'd5;
        #20;

        waddr = 5'd6;
        wdata = 32'h1111_2222;
        we = 0;
        #20;

        re1 = 1; raddr1 = 5'd6; 
        #20;
        
        $finish;
    end
endmodule
