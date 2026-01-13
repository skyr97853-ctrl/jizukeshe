`timescale 1ns / 1ps

module regfile(
    input wire re1,
    input wire [4:0]raddr1,
    input wire re2,
    input wire[4:0]raddr2,
    input wire[4:0]waddr,
    input wire we,
    input wire[31:0]wdata,
    input wire rst,clk,
    output reg[31:0]rdata1,
    output reg[31:0]rdata2
    );
    reg[31:0] regs[31:0];
    integer i;
    always@(posedge clk)begin
        if((rst==0)&&(we==1)&&(waddr!=0))
        regs[waddr]<=wdata;
        
    end
    always@(*)begin
        if(rst==1)
            rdata1<=0;
        else if(rst==0&&re1==1&&raddr1==0)
            rdata1<=0;
        else if(rst==0&&re1==1&&we==1&&raddr1==waddr)
            rdata1<=wdata;
        else if(rst==0&&re1==1)
            rdata1<=regs[raddr1];
        else
            rdata1<=0;
    end
    always@(*)begin
        if(rst==1)
            rdata2<=0;
        else if(rst==0&&re2==1&&raddr2==0)
            rdata2<=0;
        else if((rst==0)&&(re2==1)&&(we==1)&&(raddr2==waddr))
            rdata2<=wdata;
        else if(rst==0&&re2==1)
            rdata2<=regs[raddr2];
        else
            rdata2<=0;
    end
    initial begin
    for (i = 0; i < 32; i = i + 1)
        regs[i] = 32'd0;
    end
endmodule
