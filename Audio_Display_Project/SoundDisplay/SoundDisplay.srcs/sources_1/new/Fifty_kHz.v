`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2022 18:44:55
// Design Name: 
// Module Name: Fifty_kHz
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


module Twentyfive_kHz(
    input Main_Clock,
    output reg My_Clock25k = 0
);
    
reg [31:0] COUNT25k = 31'd0;
        
always @(posedge Main_Clock)
    begin
    
    COUNT25k <= (COUNT25k == 999) ? 0 : COUNT25k + 1;
    My_Clock25k <= (COUNT25k == 0) ? ~My_Clock25k : My_Clock25k;
    end
       
endmodule

