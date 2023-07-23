`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2022 19:25:41
// Design Name: 
// Module Name: debounce
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


module debounce(input clk,
                input pbD,
                output pb_out);

wire Q1,Q2,Q2_bar,Q0;
dff d1(clk, pbD,Q1);
dff d2(clk, Q1,Q2);

assign Q2_bar = ~Q2;
assign pb_out = Q1 & Q2_bar;

endmodule
