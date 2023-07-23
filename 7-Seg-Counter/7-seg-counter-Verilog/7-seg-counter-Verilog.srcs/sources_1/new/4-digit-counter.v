`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2023 18:04:08
// Design Name: 
// Module Name: 4-digit-counter
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


module four_digit_counter(
    input clk,
    output reg [6:0] seg,
    output reg [3:0] an
    );
    wire count_spd;
    wire My_Clock200Hz;
    wire My_Clock20kHz;
    wire My_Clock2kHz;
    var_clock MyClock0(.Clock(clk), .m(32'd2499), .My_Clock(My_Clock20kHz));
    var_clock MyClock1(.Clock(clk), .m(32'd249999), .My_Clock(My_Clock200Hz));
    var_clock MyClock2(.Clock(clk), .m(32'd24999), .My_Clock(My_Clock2kHz));
    var_clock Count_Spd(.Clock(clk), .m(32'd4999999), .My_Clock(count_spd)); //10Hz for now
    
    
    reg [3:0]selector = 3'd0;
    reg [14:0]total = 14'd0;
    reg [4:0]thousands = 4'd0;
    reg [4:0]hundreds = 4'd0;
    reg [4:0]tens = 4'd0;
    reg [4:0]ones = 4'd0;
    
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
    
    //selector clock needs to syn
    always @(posedge My_Clock200Hz)
    begin
    selector <= (selector == 3) ? 0 : selector + 1; //One to update tens digit anode, 0 for ones digit
    end 
    
     always @(selector)
       begin
       case(selector)
       4'd0: an <= 4'b1110;
       4'd1: an <= 4'b1101;
       4'd2: an <= 4'b1011;
       4'd3: an <= 4'b0111;
       endcase
       end
    
    
    always @(posedge count_spd)
    begin
    ones <= (ones == 9) ? 0 : ones + 1;
    tens <= (tens == 9) && (ones == 9) ? 0 : (ones == 9) ? tens + 1 : tens;
    hundreds <= (hundreds == 9) && (tens == 9) && (ones == 9) ? 0 : (tens == 9)&&(ones == 9) ? hundreds + 1 : hundreds;
    thousands <= (thousands == 9) && (hundreds == 9)&&(tens == 9)&&(ones == 9) ? 0 : (hundreds == 9)&&(tens == 9)&&(ones == 9) ? thousands + 1 : thousands;
    end
    
    
    always @(posedge clk) //note that this frequency has to be fast enough to avoid "shadows" on the displays.
    begin
    
    case(selector)  //to display the correct number when cycling through the 4 displays
    4'd0:begin
    
    case(ones) //ones digit case
    4'd0 : seg = zero;
    4'd1 : seg = one;
    4'd2 : seg = two;
    4'd3 : seg = three;
    4'd4 : seg = four;
    4'd5 : seg = five;
    4'd6 : seg = six;
    4'd7 : seg = seven;
    4'd8 : seg = eight;
    4'd9 : seg = nine;
    endcase
    end
    
    4'd1: begin //choose 2nd anode display
    
    case(tens) //tens digit case
    4'd0 : seg = zero;
    4'd1 : seg = one;
    4'd2 : seg = two;
    4'd3 : seg = three;
    4'd4 : seg = four;
    4'd5 : seg = five;
    4'd6 : seg = six;
    4'd7 : seg = seven;
    4'd8 : seg = eight;
    4'd9 : seg = nine;
    endcase
    end
    
    4'd2: begin
    
    case(hundreds) //hundreds digit case
    4'd0 : seg = zero;
    4'd1 : seg = one;
    4'd2 : seg = two;
    4'd3 : seg = three;
    4'd4 : seg = four;
    4'd5 : seg = five;
    4'd6 : seg = six;
    4'd7 : seg = seven;
    4'd8 : seg = eight;
    4'd9 : seg = nine;
    endcase
    end
    
    4'd3: begin
    case(thousands) //thousands digit case
    4'd0 : seg = zero;
    4'd1 : seg = one;
    4'd2 : seg = two;
    4'd3 : seg = three;
    4'd4 : seg = four;
    4'd5 : seg = five;
    4'd6 : seg = six;
    4'd7 : seg = seven;
    4'd8 : seg = eight;
    4'd9 : seg = nine;
    endcase
    end
    
    endcase
    end
    
endmodule
