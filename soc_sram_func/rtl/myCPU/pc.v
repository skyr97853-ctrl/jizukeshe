`timescale 1ns / 1ps


module pc(
    input wire rst, clk,
    output reg [31:0]pc,
    output reg ce,
    input branchF,
    input wire[31:0] branchAddr,
    input [5:0] stall
    );
    always@(posedge clk)begin
        if(rst==1)
            ce<=0;
        else 
            ce<=1;
    end
    always@(posedge clk)begin
        if(ce==0)
            pc<=32'hbfc00000;
        else if(stall[0]==0) begin
        if(branchF==1)
            pc<=branchAddr;
        else
            pc<=pc+4;
        end

    end
endmodule
