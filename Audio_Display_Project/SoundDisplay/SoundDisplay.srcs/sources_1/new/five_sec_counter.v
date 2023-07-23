`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2022 00:52:38
// Design Name: 
// Module Name: five_sec_counter
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


module five_sec_counter(
    input Main_Clock,
    input btnD,
    output reg [31:0] FiveCounter = 0,
    output reg trigger = 0,
    output reg released = 0
    );

wire My_Clock1mHz;
Flex_Clk MyClock1(.Clock(Main_Clock), .m(32'd499999), .My_Clock(My_Clock1mHz));

wire pb_deb;
debounce deb(.clk(My_Clock1mHz),  .pbD(btnD),  .pb_out(pb_deb));
reg press = 0;
reg counterR = 0;



always @(posedge My_Clock1mHz)
begin

   if ((pb_deb == 0) && (press == 1))
    begin
    press <= 0;
    end
   
    if ((pb_deb == 1) && (trigger == 0) && (press == 0))
    begin
    trigger <= 1;
    press <= 1;
    end
    
//    if (released == 1)
//    begin
//    press <= 0;
//    end
    
    
    if (trigger == 1)
    begin
    FiveCounter <= (FiveCounter == 500) ? 0 : FiveCounter + 1;
    end
    
    if ((FiveCounter == 500))
    begin
    trigger <= 0;
    end
    
 
   
        
end
endmodule
