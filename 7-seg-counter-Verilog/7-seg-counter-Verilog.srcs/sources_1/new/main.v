`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2023 01:58:14
// Design Name: 
// Module Name: main
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


module main(
    input clk,
    output reg [6:0]seg
    );
    wire My_Clock2Hz;
    
    var_clock MyClock0(.Clock(clk), .m(32'd24999999), .My_Clock(My_Clock2Hz));
    //Define Numerical Display for the 7-segment
    parameter zero = 8'b11000000; //Zero
    parameter one = 8'b11111001; //One
    parameter two = 8'b10100100; // two
    parameter three = 8'b10110000; //three
    parameter four = 8'b10011001; // four
    parameter five = 8'b10010010; //five
    parameter six = 8'b10000010; //six
    parameter seven = 8'b11111000; //seven
    parameter eight = 8'b10000000; //eight
    parameter nine = 8'b10010000; //nine
    
    reg [10:0] counter = 10'd0;
    
    always @(posedge My_Clock2Hz)
    begin
    case(counter)
    11'd0: seg <= zero;
    11'd1: seg <= one;
    11'd2: seg <= two;
    11'd3: seg <= three;
    11'd4: seg <= four;
    11'd5: seg <= five;
    11'd6: seg <= six;
    11'd7: seg <= seven;
    11'd8: seg <= eight;
    11'd9: seg <= nine;
    endcase
    counter <= (counter == 9) ? 0 : counter + 1;
    end
endmodule
