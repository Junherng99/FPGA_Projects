`timescale 1ns / 1ps

module var_clock(
    input Clock,
    input [31:0] m,
    output reg My_Clock = 0
);

//Desired clock freq obtained by: f = (initial Clock freq)/(2*(m+1))
//Simply configure m to get a new clock


reg [31:0] COUNT = 31'd0;
    
always @(posedge Clock)
    begin
    COUNT <= (COUNT == m) ? 0 : COUNT + 1;
    My_Clock <= (COUNT == 0) ? ~My_Clock : My_Clock;
    end
endmodule
