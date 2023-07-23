`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2022 05:35:28
// Design Name: 
// Module Name: seven_seg_counter
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


module seven_seg_counter(
    input Main_Clock,
    input wire [7:0]y,
    input wire [14:0]morsecode,
    input wire Unlock,
    input wire [3:0]shift,
    input wire pbR_press,
    input [15:0]sw,
    input wire [3:0] T1_count,
    output reg [3:0]an = 4'b1111,
    output reg[7:0]seg = 8'b11111111
    );
    
    wire [7:0]floor_y;
    wire [7:0]mod_y;
    reg [1:0] selector = 0;
    assign floor_y = (y%10 > 5) ? y/10 + 1 : y/10; 
    assign mod_y = y%10;
    
    wire My_Clock25kHz;
    reg pbR_Temp = 0;
    
    
    Twentyfive_kHz Clock25k(.Main_Clock(Main_Clock),.My_Clock25k(My_Clock25kHz));
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
    
    always @(posedge My_Clock25kHz)
    begin
    if (sw[0] == 1)begin
    selector <= 3;
    end
    
    else
    begin
    selector <= (selector == 3) ? 0 : selector + 1; //One to update tens digit anode, 0 for ones digit
    end
    
    end 
    

    
    
    always @(selector)
    begin
    
    case(selector)
    2'd0: an = 4'b1110;
    2'd1: an = 4'b1101;
    2'd2: an = 4'b0111;
    2'd3: an = 4'b1011;  
    endcase
    end
    
    
    
    always @(*)
    begin

    if (pbR_press == 1)
    begin
    pbR_Temp = 1;
    end
       


   if (Unlock == 1) 
   begin
    case (selector)
    2'd0: begin
            case(mod_y) //ones digit case
            4'b0101 : seg = zero;
            4'b0110 : seg = nine;
            4'b0111 : seg = eight;
            4'b1000 : seg = seven;
            4'b1001 : seg = six;
            4'b0000 : seg = five;
            4'b0001 : seg = four;
            4'b0010 : seg = three;
            4'b0011 : seg = two;
            4'b0100 : seg = one;
            //flipped coordinates with one beginning at mod_y = 4 because of 64 vertical pixels
            endcase
            end
    
    2'd1: begin
                    case(floor_y) //tens digit case
                    4'b0000 : seg = six;
                    4'b0001 : seg = five;
                    4'b0010 : seg = four;
                    4'b0011 : seg = three;
                    4'b0100 : seg = two;
                    4'b0101 : seg = one;
                    4'b0110 : seg = zero; //Flipped coordinates
                    
         
                    4'b0111 : seg = seven;
                    4'b1000 : seg = eight;
                    4'b1001 : seg = nine;
                    endcase
                    end              
            
      2'd2: begin      
          
            if(morsecode==15'b011011011011011)            // represent 0 in morse code
            begin
            seg[7:0]= 8'b11000000; 
            end
            
           else if(morsecode==15'b001011011011011)          // 1
                begin
                seg[7:0]= 8'b11111001;
                end
                
           else if(morsecode ==15'b001001011011011)          //2
                begin
                seg[7:0]= 8'b10100100;
                end
                
           else if(morsecode==15'b001001001011011)          // 3
                begin
                seg[7:0]= 8'b10110000;
                end
                
            else if(morsecode==15'b001001001001011)              // 4
                begin
                seg[7:0]= 8'b10011001;
                end
                
            else if(morsecode==15'b001001001001001)      // 5
                begin
                seg[7:0]= 8'b10010010;
                end
                
                
            else if(morsecode==15'b011001001001001)      // 6
                begin
                seg[7:0]= 8'b10000010;
                end
                
                
            else if(morsecode==15'b011011001001001)      // 7
                begin
                seg[7:0]= 8'b11111000;
                end
                
                
            else if(morsecode==15'b011011011001001)      // 8
                begin
                seg[7:0]= 8'b10000000;
                end
                
                
            else if(morsecode==15'b011011011011001)      // 9
                begin
                seg[7:0]= 8'b10010000;
                end
                
                
            else if(morsecode==15'b000000000001011)      // A
                begin
                seg[7:0]= 8'b10001000;
                end
                
                
            else if(morsecode==15'b000011001001001)      // B
                begin
                seg[7:0]= 8'b10000011;
                end
                
            else if(morsecode==15'b000011001011001)      // C
                begin
                seg[7:0]= 8'b10100111;
                end
                
            else if(morsecode==15'b000000011001001)      // d
                begin
                seg[7:0]= 8'b10100001;
                end
                
                
            else if(morsecode==15'b000000000000001)      // E
                begin
                seg[7:0]= 8'b10000110;
                end
                
                
            else if(morsecode==15'b000001001011001)      // F
                begin
                seg[7:0]= 8'b10001110;
                end
                
            else if(morsecode==15'b000000011011001)      // G
                begin
                seg[7:0]= 8'b11000010;
                end
                
                
            else if(morsecode==15'b000001001001001)      // H
                begin
                seg[7:0]= 8'b10001001;
                end
                
            else if(morsecode==15'b000000000001001)      // I
                begin
                seg[7:0]= 8'b11001111;
                end
                
            else if(morsecode==15'b000001011011011)      // J
                begin
                seg[7:0]= 8'b11100001;
                end
                
            else if(morsecode==15'b000001011001001)      // L
                begin
                seg[7:0]= 8'b11000111;
                end
                
            else if(morsecode==15'b000000000011001)      // N
                begin
                seg[7:0]= 8'b10101011;
                end
                
            else if(morsecode==15'b000000011011011)      // O
                begin
                seg[7:0]= 8'b11000000;
                end
                
            else if(morsecode==15'b000001011011001)      // P
                begin
                seg[7:0]= 8'b10001100;
                end
                
            else if(morsecode==15'b000011011001011)      // Q
                begin
                seg[7:0]= 8'b10011000;
                end
                
            else if(morsecode==15'b000000001011001)      // r
                begin
                seg[7:0]= 8'b10101111;
                end
                
            else if(morsecode==15'b000000001001001)      // S
                begin
                seg[7:0]= 8'b10010010;
                end
                
                
            else if(morsecode==15'b000000000000011)      // t
                begin
                seg[7:0]= 8'b10000111;
                end
                
           else if(morsecode==15'b000000001001011)      // U
                begin
                seg[7:0] = 8'b11000001;
                end
                
                
            else if(morsecode==15'b000011001011011)      // y
                begin
                seg[7:0]= 8'b10010001;
                end
                
            else
            begin
            seg[7:0] = 8'b11000000;
            end
                
            end
            
            
        2'd3: seg = 8'b11111111;    
           endcase 
 end
 
if (Unlock == 0) 
begin
        if (selector == 1 || selector == 0 || (sw == 16'b0000000000000000 && selector == 3))
        begin
        seg = 8'b11111111;
        end
    if (selector == 3)
            begin
                  if(sw == 16'b0000000000000001)
                  begin
                          case (T1_count)
                          3'd0: seg = zero;
                          3'd1: seg = one;
                          3'd2: seg = two;
                          3'd3: seg = three;
                          3'd4: seg = four;
                          3'd5: seg = five;
                          endcase
                          end
                         end

else if (selector == 2)
               begin

               
//                 if ((shift==5) || (pbR_Temp ==1))
//                 begin       
                 if(morsecode==15'b011011011011011)            // represent 0 in morse code
                 begin
                 if (Unlock == 0)
                 begin
                 seg[7:0]= 8'b11000000;
                 pbR_Temp =0;
                 end
                 end
                 
                 if(morsecode==15'b001011011011011)          // 1
                     begin
                 
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b11111001;
                     end
                     end
                     
                     if(morsecode ==15'b001001011011011)          //2
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10100100;
                     end
                     end
                     
                     if(morsecode==15'b001001001011011)          // 3
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10110000;
                     end
                     end
                     
                     if(morsecode==15'b001001001001011)              // 4
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10011001;
                     end
                     end
                     
                     if(morsecode==15'b001001001001001)      // 5
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10010010;
                     end
                     end
                     
                     
                     if(morsecode==15'b011001001001001)      // 6
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10000010;
                     end
                     end
                     
                     
                     if(morsecode==15'b011011001001001)      // 7
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b11111000;
                     end
                     end
                     
                     
                     if(morsecode==15'b011011011001001)      // 8
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10000000;
                     end
                     end
                     
                     
                     if(morsecode==15'b011011011011001)      // 9
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10010000;
                     end
                     end
                     
                     
                     if(morsecode==15'b000000000001011)      // A
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10001000;
                     end
                     end
                     
                     
                     if(morsecode==15'b000011001001001)      // B
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10000011;
                     end
                     end
                     
                     if(morsecode==15'b000011001011001)      // C
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10100111;
                     end
                     end
                     
                     if(morsecode==15'b000000011001001)      // d
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10100001;
                     end
                     end
                     
                     
                     if(morsecode==15'b000000000000001)      // E
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10000110;
                     end
                     end
                     
                     
                     if(morsecode==15'b000001001011001)      // F
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10001110;
                     end
                     end
                     
                     if(morsecode==15'b000000011011001)      // G
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b11000010;
                     end
                     end
                     
                     
                     if(morsecode==15'b000001001001001)      // H
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10001001;
                     end
                     end
                     
                     if(morsecode==15'b000000000001001)      // I
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b11001111;
                     end
                     end
                     
                     if(morsecode==15'b000001011011011)      // J
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b11100001;
                     end
                     end
                     
                     if(morsecode==15'b000001011001001)      // L
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b11000111;
                     end
                     end
                     
                     if(morsecode==15'b000000000011001)      // N
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10101011;
                     end
                     end
                     
                     if(morsecode==15'b000000011011011)      // O
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b11000000;
                     end
                     end
                     
                     if(morsecode==15'b000001011011001)      // P
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10001100;
                     end
                     end
                     
                     if(morsecode==15'b000011011001011)      // Q
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10011000;
                     end
                     end
                     
                     if(morsecode==15'b000000001011001)      // r
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10101111;
                     end
                     end
                     
                     if(morsecode==15'b000000001001001)      // S
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10010010;
                     end
                     end
                     
                     
                     if(morsecode==15'b000000000000011)      // t
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10000111;
                     end
                     end
                     
                     if(morsecode==15'b000000001001011)      // U
                        begin
                        if(Unlock == 0)
                        begin
                        seg[7:0]= 8'b11000001;
                        end
                        end
     
                     if(morsecode==15'b000011001011011)      // y
                     begin
                     if(Unlock == 0)
                     begin
                     seg[7:0]= 8'b10010001;
                     end
                     end
                 end
//                 pbR_Temp = 0;
                 end
 
//                end    

 
 
            end
   
endmodule
