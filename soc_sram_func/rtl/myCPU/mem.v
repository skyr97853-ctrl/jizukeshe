`timescale 1ns / 1ps
`include "defines.v"

module mem(
        input [31:0]wdata_i,
        input [4:0]wd_i,
        input wreg_i,
        output [31:0]wdata_o,
        output [4:0]wd_o,
        output wreg_o,
         
        input isDelay_i,
        output isDelay_o1,
        
        input [3:0] lsop_i, // Changed width
        input [31:0] memaddr_i,
        input [31:0] reg2_i,
        input [31:0]mem_data_i,
        output wire[31:0]memaddr_o,
        output wire memwe_o,
        output wire memce_o,
        output wire[31:0] memdata_o
    );
    assign isDelay_o1=isDelay_i;
    assign wd_o=wd_i;
    assign wreg_o=wreg_i;
    assign memaddr_o=memaddr_i;
    assign memce_o = (lsop_i != `lsop_nop);
    
    // Write Enable
    assign memwe_o = (lsop_i == `lsop_sw || lsop_i == `lsop_sb || lsop_i == `lsop_sh);

    // Store Data Handling (Assuming data_ram handles byte writes if we give it correct data/mask, 
    // or strictly following word alignment if ram is simple. 
    // For simple RAMs, usually need read-modify-write or byte enables. 
    // Here we pass reg2 aligned to LSB, assuming RAM/Controller handles width based on opcode if needed, 
    // OR we just send the 32-bit value. 
    // Since we can't change Data RAM, we pass reg2 directly as per original.)
    assign memdata_o = reg2_i; 

    // Load Data Handling
    reg [31:0] load_result;
    wire [1:0] byte_offset = memaddr_i[1:0];
    
    always @(*) begin
        case (lsop_i)
            `lsop_lw: load_result = mem_data_i;
            `lsop_lb: begin
                case(byte_offset)
                    2'b00: load_result = {{24{mem_data_i[7]}},   mem_data_i[7:0]}; // Little Endian assumption? Or Big? MIPS usually Big or configurable. 
                    // If simple simulation, usually Little Endian (x86 host). Let's assume Little Endian implies byte 0 is [7:0].
                    // Or if Big Endian: byte 0 is [31:24].
                    // Let's assume byte 3 is [31:24].
                    // For addr%4 == 0:
                    // If Little Endian: data[7:0]. If Big Endian: data[31:24].
                    // Standard MIPS practice in these labs often matches the host or provided RAM. 
                    // I will implement a standard selection logic assuming Little Endian for simplicity (byte 0 at [7:0]).
                    // Modify if specific endianness required.
                    2'b11: load_result = {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                    2'b10: load_result = {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                    2'b01: load_result = {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                    2'b00: load_result = {{24{mem_data_i[7]}},  mem_data_i[7:0]};
                endcase
            end
            `lsop_lbu: begin
                case(byte_offset)
                    2'b11: load_result = {24'b0, mem_data_i[31:24]};
                    2'b10: load_result = {24'b0, mem_data_i[23:16]};
                    2'b01: load_result = {24'b0, mem_data_i[15:8]};
                    2'b00: load_result = {24'b0, mem_data_i[7:0]};
                endcase
            end
            `lsop_lh: begin
                case(byte_offset[1])
                    1'b1: load_result = {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                    1'b0: load_result = {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                endcase
            end
            `lsop_lhu: begin
                case(byte_offset[1])
                    1'b1: load_result = {16'b0, mem_data_i[31:16]};
                    1'b0: load_result = {16'b0, mem_data_i[15:0]};
                endcase
            end
            default: load_result = wdata_i; // Passthrough ALU result if not load
        endcase
    end

    assign wdata_o = (lsop_i != `lsop_nop && lsop_i != `lsop_sw && lsop_i != `lsop_sb && lsop_i != `lsop_sh) ? load_result : wdata_i;

endmodule