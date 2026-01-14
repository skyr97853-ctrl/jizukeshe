`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/04 10:21:04
// Design Name: 
// Module Name: ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ctrl(    
    input rst,
    input stallreq_from_id,
    output reg [5:0]stall
    );
    always@(*)begin
        if(rst==1)begin
            stall<=6'b0;
        end
        else if((rst==0)&&(stallreq_from_id==1))begin
            stall=6'b000111;
        end 
        else begin
            stall=6'b000000;
        end
        
        
    end
endmodule
