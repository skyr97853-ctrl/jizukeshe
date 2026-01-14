`timescale 1ns / 1ps
`include "defines.v"

module mycpu_top(
    input         clk,
    input         resetn,       // 低电平复位
    input  [5 :0] ext_int,      // 中断信号

    // 指令 SRAM 接口
    output        inst_sram_en,
    output [3 :0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,

    // 数据 SRAM 接口
    output        data_sram_en,
    output [3 :0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,

    // Debug 接口
    output [31:0] debug_wb_pc,
    output [3 :0] debug_wb_rf_wen,
    output [4 :0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

    wire rst = ~resetn; // 转换为高电平复位供内部使用

    // CPU 内部信号连接
    wire [31:0] cpu_inst_addr;
    wire cpu_inst_en;
    
    wire [31:0] cpu_data_addr;
    wire cpu_data_en;
    wire cpu_data_we;       // CPU 输出的 1位 写使能
    wire [31:0] cpu_data_w; // CPU 输出的写数据
    wire [3 :0] cpu_mem_lsop; // 用于判断是 sb/sh/sw

    // Debug 信号 (从 pipeline_cpu 引出)
    wire wb_wreg;
    
    // 实例化 pipeline_cpu
    pipeline_cpu cpu0(
        .clk(clk),
        .rst(rst),
        
        // 指令存储器
        .rom_inst_i(inst_sram_rdata),
        .rom_ce_o(inst_sram_en),
        .rom_addr_o(inst_sram_addr),
        
        // 数据存储器
        .ram_addr_o(data_sram_addr),
        .ram_ce_o(data_sram_en),
        .ram_we_o(cpu_data_we),
        .ram_data_i(cpu_data_w),
        .ram_data_o(data_sram_rdata),
        
        // 关键：用于生成 data_sram_wen 的 Load/Store Op
        .mem_lsop_out(cpu_mem_lsop),

        // Debug 接口信号
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_wen_bit(wb_wreg), // 1bit 信号
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

    // 指令 SRAM 写信号常为 0
    assign inst_sram_wen   = 4'b0;
    assign inst_sram_wdata = 32'b0;

    // Debug 写使能扩展 (1位 -> 4位)
    assign debug_wb_rf_wen = {4{wb_wreg}};

    // -----------------------------------------------------------------
    // 数据 SRAM 写信号生成逻辑 (处理 sb, sh, sw)
    // -----------------------------------------------------------------
    reg [3:0] byte_sel;
    reg [31:0] final_wdata;

    always @(*) begin
        byte_sel = 4'b0000;
        final_wdata = cpu_data_w;
        
        if (cpu_data_we) begin
            case (cpu_mem_lsop)
                `lsop_sb: begin 
                    // sb: 根据地址低2位选择字节，并将数据复制到对应位置
                    final_wdata = {4{cpu_data_w[7:0]}};
                    byte_sel = 4'b0001 << data_sram_addr[1:0];
                end
                `lsop_sh: begin 
                    // sh: 根据地址第1位选择半字
                    final_wdata = {2{cpu_data_w[15:0]}};
                    byte_sel = data_sram_addr[1] ? 4'b1100 : 4'b0011;
                end
                `lsop_sw: begin 
                    // sw: 写全字
                    final_wdata = cpu_data_w;
                    byte_sel = 4'b1111;
                end
                default: byte_sel = 4'b0000;
            endcase
        end
    end

    assign data_sram_wen   = byte_sel;
    assign data_sram_wdata = final_wdata;

endmodule