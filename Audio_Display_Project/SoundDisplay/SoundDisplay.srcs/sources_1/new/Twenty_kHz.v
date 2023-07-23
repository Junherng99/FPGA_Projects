`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2022 14:27:24
// Design Name: 
// Module Name: Twenty_kHz
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


module Flex_Clk(
    input Clock,
    input [31:0]m,
    output reg My_Clock = 0
    );
     
        reg [31:0] COUNT = 31'd0;
                
        always @(posedge Clock)
            begin
            //Cutoff Value "m" = (10^8/40000) - 1 = 2499
            COUNT <= (COUNT == m) ? 0 : COUNT + 1;
            My_Clock <= (COUNT == 0) ? ~My_Clock : My_Clock;
            end
                
endmodule
