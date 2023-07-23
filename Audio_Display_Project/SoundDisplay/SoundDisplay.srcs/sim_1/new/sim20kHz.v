`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2022 14:41:19
// Design Name: 
// Module Name: sim20kHz
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


module sim20kHz();

reg Clock = 0; 
wire My_Clock20k;

Twenty_kHz Clock20k(.Clock(Clock), .My_Clock20k(My_Clock20k)); 
    
always begin
    #5 Clock = ~Clock;
    end
    
endmodule
