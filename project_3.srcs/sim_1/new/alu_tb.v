`timescale 1ns / 1ps

module alu_tb();
    reg[13:0] alu_control;
    reg[31:0] alu_src1;
    reg[31:0] alu_src2;
    reg[4:0] wd_i;
    reg wreg_i;
    wire[32:0] alu_result;
    wire[4:0] wd_o;
    wire wreg_o;
    alu alu0(alu_control,alu_src1,alu_src2,wd_i,wreg_i,alu_result,wd_o,wreg_o);
    
    integer i;
    initial begin
            alu_control=14'b10_0000_0000_0000;
            alu_src1=32'h12345678;
            alu_src2=32'hff123456;
            wd_i=10;
            wreg_i=1;
            for(i=0;i<14;i=i+1) begin
                    #20;
                    alu_control=alu_control>>1;
            end
            $finish;
    end
endmodule
