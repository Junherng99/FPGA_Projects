`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M, TUESDAY P.M, WEDNESDAY P.M, THURSDAY A.M., THURSDAY P.M
//
//  STUDENT A NAME: Chan Hanson 
//  STUDENT A MATRICULATION NUMBER: A0240750N
//
//  STUDENT B NAME: Ng Jun Herng
//  STUDENT B MATRICULATION NUMBER: A0216485Y   
//
//////////////////////////////////////////////////////////////////////////////////

//Tags: 
// Basic Requirement : Base Project Implementation (AVI)
// Morsecode : Morse Code Implementation
// OLED Task B : OLED Task B
// 64-level sound : Implementation of Improvements (Smooth Color Gradient)  
// waveform : Waveform Plotter to Visualise Collected Audio Data



module Improvements_Compiled(
    input Main_Clock,
    input J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    input [15:0]sw,
    input pbU,pbD,pbL,pbR,pbC,
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,   // Connect to this signal from Audio_Capture.v
    output reg [15:0]led = 0,
    output wire [3:0]an,           //an and seg are active low signals!!!!
    output wire [7:0]seg,  
    output rgb_cs, rgb_sdin, rgb_sclk, rgb_d_cn, rgb_resn, rgb_vccen, rgb_pmoden
    );
    
    parameter zero = 8'b11000000; //Zero
    parameter one = 8'b11110011; //One
    parameter two = 8'b10100100; // two
    parameter three = 8'b10110000; //three
    parameter four = 8'b10011001; // four
    parameter five = 8'b10010010; //five
    parameter six = 8'b10000010; //six
    parameter seven = 8'b11111000; //seven
    parameter eight = 8'b10000000; //eight
    parameter nine = 8'b10010000; //nine
    
    
    wire My_Clock10Hz;
    wire My_Clock100Hz;
    wire [11:0]mic_in;
    reg [15:0]oled_data = 16'h07E0;     
    wire My_Clock20kHz;
    wire My_Clock6p25mHz;
    wire My_Clock500kHz;
    wire trigger;
    wire [31:0] FiveCounter;
    reg [7:0]y_coord = 0;
    
    reg [3:0]shift=0;
    reg pbR_press=0; 
    reg Unlock = 0;
    reg [14:0]morsecode=0;
    reg [3:0]T1_count = 0; //to count volume level of basic AVI task up to 5
    wire released;
    wire My_Clock12p5mHz;
    Flex_Clk MyClock0(.Clock(Main_Clock), .m(32'd4999999), .My_Clock(My_Clock10Hz)); 
    Flex_Clk MyClock1(.Clock(Main_Clock), .m(32'd2499), .My_Clock(My_Clock20kHz));
    Flex_Clk MyClock3(.Clock(Main_Clock), .m(32'd7), .My_Clock(My_Clock6p25mHz));
    Flex_Clk MyClock2(.Clock(Main_Clock), .m(32'd3), .My_Clock(My_Clock12p5mHz));
    Flex_Clk MyClock4(.Clock(Main_Clock), .m(32'd499999), .My_Clock(My_Clock100Hz));
   
    five_sec_counter My_Counter1(.Main_Clock(Main_Clock), .btnD(pbD), .FiveCounter(FiveCounter), .trigger(trigger), .released(released));
    seven_seg_counter seven_disp(.Main_Clock(Main_Clock),.y(y_coord),.morsecode(morsecode), .Unlock(Unlock),.shift(shift),.pbR_press(pbR_press),.sw(sw),.T1_count(T1_count),.an(an),.seg(seg));

    
    Audio_Capture AC(
        .CLK(Main_Clock),                   // 100MHz clock
        .cs(My_Clock20kHz),                 // sampling clock, 20kHz
        .MISO(J_MIC3_Pin3),                 // J_MIC3_Pin3, serial mic input
        .clk_samp(J_MIC3_Pin1),             // J_MIC3_Pin1
        .sclk(J_MIC3_Pin4),                 // J_MIC3_Pin4, MIC3 serial clock
        .sample(mic_in)                     // 12-bit audio sample data
        );  
        
wire [12:0] pixel_index;
wire [8:0] x;
wire [8:0] y;
wire freeze;

//Memory Elements for Plotting
reg [11:0]y1,y2,y3,y4,y5,y6,y7,y8,y9,y10 = 0;
reg [11:0]y11,y12,y13,y14,y15,y16,y17,y18,y19,y20 = 0;
reg [11:0]y21,y22,y23,y24,y25,y26,y27,y28,y29,y30 = 0;
reg [11:0]y31,y32,y33,y34,y35,y36,y37,y38,y39,y40 = 0;
reg [11:0]y41,y42,y43,y44,y45,y46,y47,y48,y49,y50 = 0;
reg [11:0]y51,y52,y53,y54,y55,y56,y57,y58,y59,y60 = 0;
reg [11:0]y61,y62,y63,y64,y65,y66,y67,y68,y69,y70 = 0;
reg [11:0]y71,y72,y73,y74,y75,y76,y77,y78,y79,y80 = 0;
reg [11:0]y81,y82,y83,y84,y85,y86,y87,y88,y89,y90 = 0;
reg [11:0]y91,y92,y93,y94,y95,y96,y97 = 0;


reg [2:0]PBcounter = 0;

assign x = pixel_index%96;
assign y = pixel_index/96;
assign freeze = sw[15] && sw[4];



       
      
reg [31:0]LEDcounter3s=0;
reg ledcheck3s=0;
reg [31:0]LEDcounter1s=0;
reg ledcheck1s=0;
reg [31:0]count1s =0;
reg [31:0]count3s =0;
reg dash=0;
reg dot=0;
reg my_pbC_pressed =0;



reg [4:0]seq=0;

///////////////////////////////////////////////////////////////////////////////
// //4.2c AVI Task AVI2A fast clock should be used to avoid nyquist effects. //
///////////////////////////////////////////////////////////////////////////////
reg [11:0]xcount = 0;
reg [31:0]Lcount = 0;
reg [11:0] peak_value = 0;
reg [11:0] current_mic = 0;
reg [11:0] current_peak = 0;
wire [31:0] Lcycle;
wire fast;
reg fcount;
wire pb_deb;
wire rightpb;
reg [8:0]xstore = 0;
debounce deb(.clk(My_Clock12p5mHz), .pbD(pbD),  .pb_out(pb_deb));
debounce deb1(.clk(My_Clock100Hz), .pbD(pbU),  .pb_out(rightpb));

assign Lcycle = (fast == 1) ? 312500 : 625000;
assign fast = (morsecode==15'b000001001011001) ? 1 : 0;

always @(posedge trigger) //debouncer for OLED Task
begin
if (sw[1] == 1) //switching mechanism
begin

    if(PBcounter < 3)
    begin
    PBcounter <= PBcounter + 1;
    end
    
    else if (PBcounter == 3)
    begin
    PBcounter <= 0;
    end
    
    
 end   
    
    end

reg light = 0;
reg three_sec_over=0;
reg [2:0]counter=0;
reg pb_pressed=0;
reg [31:0] counterthree=0;

always @(posedge My_Clock12p5mHz)
begin

if( (rightpb==1) && (pb_pressed==0) )
begin
pb_pressed <=1;  
light <= 1;      
end

if (pb_pressed ==1) //start counting down 3seconds
begin
counterthree <= (counterthree ==  37500000) ? 0 : counterthree + 1;
end

if (counterthree == 37500000) // counting complete 
begin
three_sec_over <=1;
light <=0;
end

if (three_sec_over ==1 && rightpb==0 )
begin
pb_pressed <= 0;
three_sec_over <=0;
end

end


always @(posedge (pb_pressed))
begin
if (sw[2] == 1)
begin
counter <= (counter == 3'd4) ? 0 : counter +1;  // when all green disappear , restart
end
end


always @(posedge My_Clock6p25mHz)
begin   
/////////////////
// OLED Task A //
/////////////////


if (sw[2] == 1)
begin

if (light == 1)
begin
led[14] <= 1;
end

else if (light == 0)
begin
led[14] <= 0;
end


if (((y == 2 && x>1 && x<94) || (y == 61 && x>1 && x<94) || (x==2 && y >1 && y <62) || (x==93 && y > 1 && y <62)))
begin
oled_data <= 16'b1111100000000000; 
end

else if (((y >4 && y<8 &&  x>4 && x<91) || (y > 55 && y<59 && x>4 && x<91) || (x>4 && x<8 && y >4 && y <59) || (x>87 && x<91 && y > 4 && y <59)))
begin
oled_data <= 16'b1111111111100000; 
end

else if (counter == 3'b001 && ((y == 10 && x>9 && x<86) || (y == 53 && x>9 && x<86) || (x==10 && y >9 && y <54) || (x==85 && y > 9 && y <54)))
begin //first green
oled_data <= 16'b0000011111100000; 
end

else if (counter == 3'b010 &&((y == 13 && x>12 && x<83) || (y == 50 && x>12 && x<83) || (x==13 && y >12 && y <51) || (x==82 && y > 12 && y <51) || (y == 10 && x>9 && x<86) || (y == 53 && x>9 && x<86) || (x==10 && y >9 && y <54) || (x==85 && y > 9 && y <54)))
begin //2nd green
oled_data <= 16'b0000011111100000; 
end

else if (counter == 3'b011 &&((y == 16 && x>15 && x<80) || (y == 47 && x>15 && x<80) || (x==16 && y >15 && y <48) || (x==79 && y > 15 && y <48) || (y == 13 && x>12 && x<83) || (y == 50 && x>12 && x<83) || (x==13 && y >12 && y <51) || (x==82 && y > 12 && y <51) || (y == 10 && x>9 && x<86) || (y == 53 && x>9 && x<86) || (x==10 && y >9 && y <54) || (x==85 && y > 9 && y <54)))
begin //3rd green
oled_data <= 16'b0000011111100000; 
end

else if (counter == 3'b100 &&((y == 19 && x>18 && x<77) || (y == 44 && x>18 && x<77) || (x==19 && y >18 && y <45) || (x==76 && y > 18 && y <45)|| (y == 16 && x>15 && x<80) || (y == 47 && x>15 && x<80) || (x==16 && y >15 && y <48) || (x==79 && y > 15 && y <48) || (y == 13 && x>12 && x<83) || (y == 50 && x>12 && x<83) || (x==13 && y >12 && y <51) || (x==82 && y > 12 && y <51) || (y == 10 && x>9 && x<86) || (y == 53 && x>9 && x<86) || (x==10 && y >9 && y <54) || (x==85 && y > 9 && y <54)))
begin //4th green
oled_data <= 16'b0000011111100000; 
end

else 
begin
oled_data <= 16'b0000000000000000;
end
end  


///////////////////////
// OLED Task B       // 
///////////////////////
if(sw[1] == 1)
begin

    if  (trigger == 1)
    begin
    led[12] <= 1;
    end
    else if (trigger == 0)
    begin
    led[12] <= 0;
    end
      
    
if (PBcounter == 0)
    begin   
            
      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
          begin
          oled_data <= {5'b11111, 6'd0, 5'd0};
          end
       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
          begin
          oled_data <= {5'b11111, 6'b010000, 5'b00000};
          end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


    if (PBcounter == 1)
            begin 
            
                
      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
          begin
          oled_data <= {5'b11111, 6'd0, 5'd0};
          end
       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
          begin
          oled_data <= {5'b11111, 6'b010000, 5'b00000};
          end
      else if ((x >= 42 && x < 52) && (y >= 43 && y < 48))
          begin
          oled_data <= {5'd0, 6'b111111, 5'd0};
          end
     
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
        
        
if (PBcounter == 2)        
    begin
        
      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
          begin
          oled_data <= {5'b11111, 6'd0, 5'd0};
          end
       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
          begin
          oled_data <= {5'b11111, 6'b010000, 5'b00000};
          end
      else if ((x >= 42 && x < 52) && (y >= 43 && y < 48))
          begin
          oled_data <= {5'd0, 6'b111111, 5'd0};
          end
       else if ((x >= 42 && x < 52) && (y >= 35 && y < 40))
          begin
          oled_data <= {5'b00110, 6'b111111, 5'b00110};
          end     
      else
          begin
          oled_data <= {5'd0, 6'd0, 5'd0};
          end
      end
      

 if (PBcounter == 3)
    begin    
      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
          begin
          oled_data <= {5'b11111, 6'd0, 5'd0};
          end
       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
          begin
          oled_data <= {5'b11111, 6'b010000, 5'b00000};
          end
      else if ((x >= 42 && x < 52) && (y >= 43 && y < 48))
          begin
          oled_data <= {5'd0, 6'b111111, 5'd0};
          end
       else if ((x >= 42 && x < 52) && (y >= 35 && y < 40))
          begin
          oled_data <= {5'b00110, 6'b111111, 5'b00110};
          end         
     else if ((x >= 42 && x < 52) && (y >= 27 && y < 32))
          begin
          oled_data <= {5'b01110, 6'b111111, 5'b01110};
          end     
      else
          begin
          oled_data <= {5'd0, 6'd0, 5'd0};
          end
      end
 end
 
 
 
/////////////////////////////////
//  Morse Code Implementation  //
/////////////////////////////////
if(sw[14] == 1)
begin
Unlock <= 0;
morsecode <= 15'b0000000000000000;
fcount <= 0;
xstore <= x;
if (xstore == x)
begin
oled_data <= oled_data + 500;
end

end

else
begin



if(Unlock == 1)
begin
led[10] <= 1;
end

else if (Unlock == 0)
begin
led[10] <= 0;
end

if (pbR==1)
begin
pbR_press <=1;
end



if(fast == 1)
begin
led[11] <= 1;
end
else if (fast == 0)
begin
led[11] <= 0;
end


if(pbL==1)                     // reset button
begin
morsecode<=15'b000000000000000;
shift <=0;
pbR_press <=0;
end

if (pbC == 0)
begin
count3s <=0;
count1s <=0;

end

if ((pbC ==1) && (my_pbC_pressed ==0))                 
begin
my_pbC_pressed <=1;                
end                     

if((my_pbC_pressed ==1) && (pbC==1))               // press and hold
begin
count3s <= (count3s == 18750000) ? 0 : count3s + 1;
count1s <= (count1s == 6250000) ? 0 : count1s + 1;
end


if((my_pbC_pressed ==1) && (pbC==0) && (count3s < 49999999))   // press and release before 1s
begin   
my_pbC_pressed <= 0; 
end


if ((count3s == 18750000))            // after 3s
begin
dash <=1;
end

if (count1s == 6250000)               // after 1s
begin
dot <=1;
end


if ((dot ==1) && (dash ==0) && (pbC==0) && (shift<5) && (pbR==0))                 // once release after 1s of holding
begin 
led[7] <=1;
my_pbC_pressed <=0;   
dot <= 0;                    // reset memory of dot to allow next input
morsecode <= ((morsecode <<3) | 3'b000000000000001);
shift <= shift +1;
ledcheck1s <=1;
end

if(ledcheck1s ==1)
begin
LEDcounter1s <= (LEDcounter1s ==  6250000) ? 0 : LEDcounter1s + 1;
end
                    
if(LEDcounter1s ==  6250000)
begin
led[7]<=0;
ledcheck1s <=0;
end


if ((dash ==1) && (pbC==0) && (shift<5) && (pbR==0))                // once release after 3s of holding
begin
my_pbC_pressed <=0;
led[9] <=1;
dash <= 0;                    // reset memory of dash to allow next input
dot <=0;                     // in case there is a dot memory
morsecode <= ((morsecode <<3) | 15'b000000000000011);
shift <= shift +1;
ledcheck3s <=1;
end 

if(ledcheck3s ==1)
begin
LEDcounter3s <= (LEDcounter3s ==  6250000) ? 0 : LEDcounter3s + 1;
end

if(LEDcounter3s ==  6250000)
begin
led[9]<=0;
ledcheck3s <=0;
end



if((shift==5) || (pbR_press ==1))              // max shift or when user press enter (pbR)
begin
//if(morsecode==15'b011011011011011)            // represent 0 in morse code
//begin
//an[3:0]<=4'b1110;
//seg[7:0]<= 8'b11000000;
//end


if(morsecode==15'b001011011011011)          // 1
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001011011011)          //2
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001001011011)          // 3
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001001001011)              // 4
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001001001001)      // 5
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011001001001001)      // 6
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011011001001001)      // 7
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011011011001001)      // 8
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011011011011001)      // 9
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000000001011)      // A
begin
shift <=0;

end


if(morsecode==15'b000011001001001)      // B
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000011001011001)      // C
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000011001001)      // d
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000000000001)      // E
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000001001011001)     // F
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000011011001)      // G
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000001001001001)      // H
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000000001001)      // I
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000001011011011)      // J
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000001011001001)      // L
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000000011001)      // N
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000011011011)      // O
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000001011011001)      // P
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000011011001011)      // Q
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000001011001)      // r
begin
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000001001001)      // S
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000000000011)      // t
begin
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000001001011)      // U
begin
if(Unlock == 0)
begin
morsecode <= 15'b000000000000000;
end
shift <=0;
pbR_press <=0;
Unlock <= 1;
end

if(morsecode==15'b000011001011011)      // y
begin
shift <=0;
pbR_press <=0;
end

end




    Lcount <= Lcount + 1;
    current_mic[11:0] <= mic_in[11:0];
    
    if (current_mic > current_peak)
    begin
    current_peak[11:0] <= current_mic[11:0];
    end
    
    if (Lcount == 625000)  //0.1s or 0.05s depend on Lcycle max amplitude output
    begin
    peak_value[11:0] <= current_peak[11:0];
    Lcount <= 0;
    current_peak <= 0;
    
    if((sw == 16'b0000100000000000) && Unlock == 1)
    begin
    xcount <= (xcount >= 95) ?  0 : xcount +1;
    end //from 0.1s counter statement
    end
    
    else if (fast == 1 && Lcount == 312500)
    begin
    peak_value[11:0] <= current_peak[11:0];
    current_peak <= 0;
    
    if((sw == 16'b0000100000000000) && Unlock == 1)
    begin
    xcount <= (xcount >= 95) ?  0 : xcount +1;
    end //from 0.1s counter statement
    end


    
    
//    else if (fast == 1)
//    begin
//    if (Lcount == 312500)  //0.1s or 0.05s depend on Lcycle max amplitude output
//    begin
//    peak_value[11:0] <= current_peak[11:0];
//    Lcount <= 0;
//    current_peak <= 0;
    
//    if((sw == 16'b0000100000000000) && Unlock == 1)
//    begin
//    xcount <= (xcount >= 95) ?  0 : xcount +1;
//    end //from 0.1s counter statement
    
//    end
//    end
    

//////////////////////////////////////////////////////////
// Base Project Implementation (AVI)                    //
//////////////////////////////////////////////////////////   



if (sw == 16'b0000000000000001)
begin

    if (peak_value >= 2048 && peak_value < 2300)
        begin
        led <= 12'b0000000000000000;
        T1_count <= 0;
        oled_data <= {5'd0, 6'd0, 5'd0};
        end
        
        if (peak_value >= 2300 && peak_value < 2600)
        begin
        led <= 12'b0000000000000000001;
        T1_count <= 1;
        
       if ((x >= 42 && x < 52) && (y >= 41 && y < 46))
           begin
           oled_data <= {5'b11111, 6'd0, 5'd0};
           end
        else if (((y == 2 && x>1 && x<94) || (y == 61 && x>1 && x<94) || (x==2 && y >1 && y <62) || (x==93 && y > 1 && y <62)))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
        
        if (peak_value >= 2600 && peak_value <= 2900)
        begin
        led <= 12'b0000000000000011;
        T1_count <= 2;
        
         if ((x >= 42 && x < 52) && (y >= 41 && y < 46))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
         else if ((x >= 42 && x < 52) && (y >= 35 && y < 40)) 
            begin
            oled_data <= {5'b11111, 6'b111111, 5'b00000};
            end
            
        else if (((y == 2 && x>1 && x<94) || (y == 61 && x>1 && x<94) || (x==2 && y >1 && y <62) || (x==93 && y > 1 && y <62)))
                begin
                oled_data <= {5'b11111, 6'd0, 5'd0};
                end
        else if (((y >4 && y<8 &&  x>4 && x<91) || (y > 55 && y<59 && x>4 && x<91) || (x>4 && x<8 && y >4 && y <59) || (x>87 && x<91 && y > 4 && y <59)))
                begin
                oled_data <= 16'b1111111111100000; 
                end
         else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
        
        
        if (peak_value >= 2900 && peak_value <= 3300)
            begin
            led <= 12'b0000000000000111;
            T1_count <= 3;
            
         if ((x >= 42 && x < 52) && (y >= 41 && y < 46))
             begin
             oled_data <= {5'b11111, 6'd0, 5'd0};
             end
          else if ((x >= 42 && x < 52) && (y >= 35 && y < 40)) 
             begin
             oled_data <= {5'b11111, 6'b111111, 5'b00000};
             end
          else if ((x >= 42 && x < 52) && (y >= 29 && y < 34))
               begin
               oled_data <= {5'd0, 6'b111111, 5'd0};
               end

               
           else if (((y == 2 && x>1 && x<94) || (y == 61 && x>1 && x<94) || (x==2 && y >1 && y <62) || (x==93 && y > 1 && y <62)))
                   begin
                   oled_data <= {5'b11111, 6'd0, 5'd0};
                   end
           else if (((y >4 && y<8 &&  x>4 && x<91) || (y > 55 && y<59 && x>4 && x<91) || (x>4 && x<8 && y >4 && y <59) || (x>87 && x<91 && y > 4 && y <59)))
                   begin
                   oled_data <= 16'b1111111111100000; 
                   end
                   
            else if ((y == 10 && x>9 && x<86) || (y == 53 && x>9 && x<86) || (x==10 && y >9 && y <54) || (x==85 && y > 9 && y <54))
                   begin //first green
                   oled_data <= 16'b0000011111100000; 
                   end
            else
                begin
                oled_data <= {5'd0, 6'd0, 5'd0};
                end
             end
        
        if (peak_value >= 3300 && peak_value <= 3700)
            begin
            led <= 12'b0000000000001111;
            T1_count <= 4;
            
       if ((x >= 42 && x < 52) && (y >= 41 && y < 46))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
         else if ((x >= 42 && x < 52) && (y >= 35 && y < 40)) 
            begin
            oled_data <= {5'b11111, 6'b111111, 5'b00000};
            end
        else if ((x >= 42 && x < 52) && (y >= 29 && y < 34))
              begin
              oled_data <= {5'd0, 6'b111111, 5'd0};
              end
        else if ((x >= 42 && x < 52) && (y >= 23 && y < 28))
                 begin
                 oled_data <= {5'b00110, 6'b111111, 5'b00110};
                 end         

                else if (((y == 2 && x>1 && x<94) || (y == 61 && x>1 && x<94) || (x==2 && y >1 && y <62) || (x==93 && y > 1 && y <62)))
                         begin
                         oled_data <= {5'b11111, 6'd0, 5'd0};
                         end
                 else if (((y >4 && y<8 &&  x>4 && x<91) || (y > 55 && y<59 && x>4 && x<91) || (x>4 && x<8 && y >4 && y <59) || (x>87 && x<91 && y > 4 && y <59)))
                         begin
                         oled_data <= 16'b1111111111100000; 
                         end
                         
                  else if ((y == 10 && x>9 && x<86) || (y == 53 && x>9 && x<86) || (x==10 && y >9 && y <54) || (x==85 && y > 9 && y <54))
                         begin //first green
                         oled_data <= 16'b0000011111100000; 
                         end
           else if ((y == 13 && x>12 && x<83) || (y == 50 && x>12 && x<83) || (x==13 && y >12 && y <51) || (x==82 && y > 12 && y <51))
                         begin //2nd green
                         oled_data <= 16'b0000011111100000; 
                         end
              else
                 begin
                 oled_data <= {5'd0, 6'd0, 5'd0};
                 end
            end
        
        if (peak_value >= 3700 && peak_value <= 4096)
            begin
            led <= 12'b0000000000011111;
            T1_count <= 5;
            
               if ((x >= 42 && x < 52) && (y >= 41 && y < 46))
               begin
               oled_data <= {5'b11111, 6'd0, 5'd0};
               end
            else if ((x >= 42 && x < 52) && (y >= 35 && y < 40)) 
               begin
               oled_data <= {5'b11111, 6'b111111, 5'b00000};
               end
           else if ((x >= 42 && x < 52) && (y >= 29 && y < 34))
                 begin
                 oled_data <= {5'd0, 6'b111111, 5'd0};
                 end
           else if ((x >= 42 && x < 52) && (y >= 23 && y < 28))
                    begin
                    oled_data <= {5'b00110, 6'b111111, 5'b00110};
                    end         
                    
              else if ((x >= 42 && x < 52) && (y >= 17 && y < 22))
                 begin
                 oled_data <= {5'b00110, 6'b111111, 5'b00110};
                 end       
                 
                else if (((y == 2 && x>1 && x<94) || (y == 61 && x>1 && x<94) || (x==2 && y >1 && y <62) || (x==93 && y > 1 && y <62)))
                          begin
                          oled_data <= {5'b11111, 6'd0, 5'd0};
                          end
                  else if (((y >4 && y<8 &&  x>4 && x<91) || (y > 55 && y<59 && x>4 && x<91) || (x>4 && x<8 && y >4 && y <59) || (x>87 && x<91 && y > 4 && y <59)))
                          begin
                          oled_data <= 16'b1111111111100000; 
                          end
                          
                   else if ((y == 10 && x>9 && x<86) || (y == 53 && x>9 && x<86) || (x==10 && y >9 && y <54) || (x==85 && y > 9 && y <54))
                          begin //first green
                          oled_data <= 16'b0000011111100000; 
                          end
            else if ((y == 13 && x>12 && x<83) || (y == 50 && x>12 && x<83) || (x==13 && y >12 && y <51) || (x==82 && y > 12 && y <51))
                          begin //2nd green
                          oled_data <= 16'b0000011111100000; 
                          end
            else if ((y == 16 && x>15 && x<80) || (y == 47 && x>15 && x<80) || (x==16 && y >15 && y <48) || (x==79 && y > 15 && y <48))
                          begin //3rd green
                          oled_data <= 16'b0000011111100000; 
                          end               
                 
                 
              else
                 begin
                 oled_data <= {5'd0, 6'd0, 5'd0};
                 end
            end    
    
 end   
    
    
    
    
    if(freeze == 1)
    begin
    xcount <= 97;
    end

////////////////////////////////////////////////////////
// Waveform Plotter to Visualise Collected Audio Data //
////////////////////////////////////////////////////////
if((sw[14:0] == 16'b000100000000000) && Unlock == 1) //Toggling Mechanism
begin

case (xcount)
    12'd0: y1 <= 64;
    12'd1: y2 <= y_coord;
    12'd2: y3 <= y_coord;
    12'd3: y4 <= y_coord;
    12'd4: y5 <= y_coord;
    12'd5: y6 <= y_coord;
    12'd6: y7 <= y_coord;
    12'd7: y8 <= y_coord;
    12'd8: y9 <= y_coord;
    12'd9: y10 <= y_coord;
    12'd10: y11 <= y_coord;
    12'd11: y12 <= y_coord;
    12'd12: y13 <= y_coord;
    12'd13: y14 <= y_coord;
    12'd14: y15 <= y_coord;
    12'd15: y16 <= y_coord;
    12'd16: y17 <= y_coord;
    12'd17: y18 <= y_coord;
    12'd18: y19 <= y_coord;
    12'd19: y20 <= y_coord;
    12'd20: y21 <= y_coord;
    12'd21: y22 <= y_coord;
    12'd22: y23 <= y_coord;
    12'd23: y24 <= y_coord;
    12'd24: y25 <= y_coord;
    12'd25: y26 <= y_coord;
    12'd26: y27 <= y_coord;
    12'd27: y28 <= y_coord;
    12'd28: y29 <= y_coord;
    12'd29: y30 <= y_coord;
    12'd30: y31 <= y_coord;
    12'd31: y32 <= y_coord;
    12'd32: y33 <= y_coord;
    12'd33: y34 <= y_coord;
    12'd34: y35 <= y_coord;
    12'd35: y36 <= y_coord;
    12'd36: y37 <= y_coord;
    12'd37: y38 <= y_coord;
    12'd38: y39 <= y_coord;
    12'd39: y40 <= y_coord;
    12'd40: y41 <= y_coord;
    12'd41: y42 <= y_coord;
    12'd42: y43 <= y_coord;
    12'd43: y44 <= y_coord;
    12'd44: y45 <= y_coord;
    12'd45: y46 <= y_coord;
    12'd46: y47 <= y_coord;
    12'd47: y48 <= y_coord;
    12'd48: y49 <= y_coord;
    12'd49: y50 <= y_coord;
    12'd50: y51 <= y_coord;
    12'd51: y52 <= y_coord;
    12'd52: y53 <= y_coord;
    12'd53: y54 <= y_coord;
    12'd54: y55 <= y_coord;
    12'd55: y56 <= y_coord;
    12'd56: y57 <= y_coord;
    12'd57: y58 <= y_coord;
    12'd58: y59 <= y_coord;
    12'd59: y60 <= y_coord;
    12'd60: y61 <= y_coord;
    12'd61: y62 <= y_coord;
    12'd62: y63 <= y_coord;
    12'd63: y64 <= y_coord;
    12'd64: y65 <= y_coord;
    12'd65: y66 <= y_coord;
    12'd66: y67 <= y_coord;
    12'd67: y68 <= y_coord;
    12'd68: y69 <= y_coord;
    12'd69: y70 <= y_coord;
    12'd70: y71 <= y_coord;
    12'd71: y72 <= y_coord;
    12'd72: y73 <= y_coord;
    12'd73: y74 <= y_coord;
    12'd74: y75 <= y_coord;
    12'd75: y76 <= y_coord;
    12'd76: y77 <= y_coord;
    12'd77: y78 <= y_coord;
    12'd78: y79 <= y_coord;
    12'd79: y80 <= y_coord;
    12'd80: y81 <= y_coord;
    12'd81: y82 <= y_coord;
    12'd82: y83 <= y_coord;
    12'd83: y84 <= y_coord;
    12'd84: y85 <= y_coord;
    12'd85: y86 <= y_coord;
    12'd86: y87 <= y_coord;
    12'd87: y88 <= y_coord;
    12'd88: y89 <= y_coord;
    12'd89: y90 <= y_coord;
    12'd90: y91 <= y_coord;
    12'd91: y92 <= y_coord;
    12'd92: y93 <= y_coord;
    12'd93: y94 <= y_coord;
    12'd94: y95 <= y_coord;
    12'd95: y96 <= y_coord;
endcase

    //1
    if (peak_value >= 2048 && peak_value < 2080) 
        begin
        y_coord <= 64;
        end    
    //2
    if (peak_value >= 2080 && peak_value < 2112) 
        begin
        y_coord <= 63;
        end      
    //3
    if (peak_value >= 2112 && peak_value < 2144) 
        begin
        y_coord <= 62;
        end     
    //4
    if (peak_value >= 2144 && peak_value < 2176) 
        begin
        y_coord <= 61;
        end   
    //5
    if (peak_value >= 2176 && peak_value < 2208) 
        begin
        y_coord <= 60;
        end
    //6
    if (peak_value >= 2208 && peak_value < 2240) 
        begin
        y_coord <= 59;
        end       
    //7
    if (peak_value >= 2240 && peak_value < 2272) 
        begin
        y_coord <= 58;
        end
        //8
    if (peak_value >= 2272 && peak_value < 2304) 
        begin
        y_coord <= 57;
        end
        //9
    if (peak_value >= 2304 && peak_value < 2336) 
        begin
        y_coord <= 56;
        end
    //10
   if (peak_value >= 2336 && peak_value < 2368) 
        begin
        y_coord <= 55;
        end
    //11
   if (peak_value >= 2368 && peak_value < 2400) 
        begin
        y_coord <= 54;
        end
    //12
   if (peak_value >= 2400 && peak_value < 2432) 
        begin
        y_coord <= 53;
        end
    //13
   if (peak_value >= 2432 && peak_value < 2464) 
        begin
        y_coord <= 52;
        end
   //14
   if (peak_value >= 2464 && peak_value < 2496) 
        begin
        y_coord <= 51;
        end
    //15
   if (peak_value >= 2496 && peak_value < 2528) 
        begin
        y_coord <= 50;
        end
   //16
   if (peak_value >= 2496 && peak_value < 2528) 
             begin
             y_coord <= 49;
             end
   //17
   if (peak_value >= 2528 && peak_value < 2560) 
            begin
            y_coord <= 48;
            end
    //18
   if (peak_value >= 2560 && peak_value < 2592) 
             begin
             y_coord <= 47;
             end
     //19
     if (peak_value >= 2592 && peak_value < 2624) 
         begin
         y_coord <= 46;
         end
    //20
    if (peak_value >= 2624 && peak_value < 2656) 
        begin
        y_coord <= 45;
        end
    //21
    if (peak_value >= 2656 && peak_value < 2688) 
        begin
        y_coord <= 44;
        end
    //22
    if (peak_value >= 2688 && peak_value < 2720) 
            begin
            y_coord <= 43;
            end
    //23
    if (peak_value >= 2720 && peak_value < 2752) 
            begin
            y_coord <= 42;
            end
    //24
    if (peak_value >= 2752 && peak_value < 2784) 
            begin
            y_coord <= 41;
            end
    //25
    if (peak_value >= 2784 && peak_value < 2816) 
            begin
            y_coord <= 40;
            end
    //26
    if (peak_value >= 2816 && peak_value < 2848) 
            begin
            y_coord <= 39;
            end
    //27
    if (peak_value >= 2848 && peak_value < 2880) 
            begin
            y_coord <= 38;
            end
    //28
    if (peak_value >= 2880 && peak_value < 2912) 
            begin
            y_coord <= 37;
            end
    //29
    if (peak_value >= 2912 && peak_value < 2944) 
            begin
            y_coord <= 36;
            end
    //30
    if (peak_value >= 2944 && peak_value < 2976) 
            begin
            y_coord <= 35;
            end
    //31
    if (peak_value >= 2976 && peak_value < 3008) 
            begin
            y_coord <= 34;
            end
    //32
    if (peak_value >= 3008 && peak_value < 3040) 
            begin
            y_coord <= 33;
            end
    //33
    if (peak_value >= 3040 && peak_value < 3072) 
            begin
            y_coord <= 32;
            end
    //34
    if (peak_value >= 3072 && peak_value < 3104) 
            begin
            y_coord <= 31;
            end
    //35
    if (peak_value >= 3104 && peak_value < 3136) 
            begin
            y_coord <= 30;
            end
    //36
    if (peak_value >= 3136 && peak_value < 3172) 
            begin
            y_coord <= 29;
            end
    //37
    if (peak_value >= 3172 && peak_value < 3208) 
            begin
            y_coord <= 28;
            end
    //38
    if (peak_value >= 3208 && peak_value < 3240) 
            begin
            y_coord <= 27;
            end
    //39
    if (peak_value >= 3240 && peak_value < 3272) 
            begin
            y_coord <= 26;
            end
    //40
    if (peak_value >= 3272 && peak_value < 3304) 
            begin
            y_coord <= 25;
            end
    //41
    if (peak_value >= 3304 && peak_value < 3336) 
            begin
            y_coord <= 24;
            end
    //42
    if (peak_value >= 3336 && peak_value < 3368) 
            begin
            y_coord <= 23;
            end
    //43
    if (peak_value >= 3368 && peak_value < 3400) 
            begin
            y_coord <= 22;
            end
    //44
    if (peak_value >= 3400 && peak_value < 3432) 
            begin
            y_coord <= 21;
            end
    //45
    if (peak_value >= 3432 && peak_value < 3464) 
            begin
            y_coord <= 20;
            end
    //46
    if (peak_value >= 3464 && peak_value < 3496) 
            begin
            y_coord <= 19;
            end
    //47
    if (peak_value >= 3496 && peak_value < 3528) 
            begin
            y_coord <= 18;
            end
    //48
    if (peak_value >= 3528 && peak_value < 3560) 
            begin
            y_coord <= 17;
            end
    //49
    if (peak_value >= 3560 && peak_value < 3592) 
            begin
            y_coord <= 16;
            end
    //50
    if (peak_value >= 3560 && peak_value < 3592) 
            begin
            y_coord <= 15;
            end
    //51
    if (peak_value >= 3592 && peak_value < 3624) 
            begin
            y_coord <= 14;
            end
    //52
    if (peak_value >= 3624 && peak_value < 3656) 
            begin
            y_coord <= 13;
            end
    //53
    if (peak_value >= 3656 && peak_value < 3688) 
            begin
            y_coord <= 12;
            end
    //54
    if (peak_value >= 3688 && peak_value < 3720) 
            begin
            y_coord <= 11;
            end
    //55
    if (peak_value >= 3720 && peak_value < 3752) 
            begin
            y_coord <= 10;
            end
    //56
    if (peak_value >= 3752 && peak_value < 3784) 
            begin
            y_coord <= 9;
            end
    //57
    if (peak_value >= 3784 && peak_value < 3816) 
            begin
            y_coord <= 8;
            end
    //58
    if (peak_value >= 3816 && peak_value < 3848) 
            begin
            y_coord <= 7;
            end
    //59
    if (peak_value >= 3848 && peak_value < 3880) 
            begin
            y_coord <= 6;
            end
    //60
    if (peak_value >= 3880 && peak_value < 3912) 
            begin
            y_coord <= 5;
            end
    //61
    if (peak_value >= 3912 && peak_value < 3944) 
            begin
            y_coord <= 4;
            end
    //62
    if (peak_value >= 3912 && peak_value < 3944) 
            begin
            y_coord <= 3;
            end
    //63
    if (peak_value >= 3976 && peak_value < 4008) 
            begin
            y_coord <= 2;
            end
    //64
    if (peak_value >= 4008 && peak_value < 4040) 
            begin
            y_coord <= 1;
            end
    //65
    if (peak_value >= 4040) 
            begin
            y_coord <= 0;
            end                    
        
 //////////DISPLAY CODE BY PIXELS//////////       
        
    if ((x == 0) && (y == y1))
        begin
        oled_data <= {5'b11111, 6'b111111, 5'b11111};
        end 
    else if ((x == 1) && (y == y2))
         begin
         oled_data <= {5'b11111, 6'b111111, 5'b11111};
         end 
     else if ((x == 2) && (y == y3))
               begin
               oled_data <= {5'b11111, 6'b111111, 5'b11111};
               end
     else if ((x == 3) && (y == y4))
               begin
               oled_data <= {5'b11111, 6'b111111, 5'b11111};
               end
                              
      else if ((x == 4) && (y == y5))
                 begin
                 oled_data <= {5'b11111, 6'b111111, 5'b11111};
                 end
      else if ((x == 5) && (y == y6))
                 begin
                 oled_data <= {5'b11111, 6'b111111, 5'b11111};
                 end             
      else if ((x == 6) && (y == y7))
                begin
                oled_data <= {5'b11111, 6'b111111, 5'b11111};
                 end
       else if ((x == 7) && (y == y8))
                begin
                oled_data <= {5'b11111, 6'b111111, 5'b11111};
                end
        else if ((x == 8) && (y == y9))
                 begin
                 oled_data <= {5'b11111, 6'b111111, 5'b11111};
                 end
         else if ((x == 9) && (y == y10))
                  begin
                  oled_data <= {5'b11111, 6'b111111, 5'b11111};
                  end
         else if ((x == 10) && (y == y11))
                  begin
                  oled_data <= {5'b11111, 6'b111111, 5'b11111};
                  end
         else if ((x == 11) && (y == y12))
                   begin
                   oled_data <= {5'b11111, 6'b111111, 5'b11111};
                   end
         else if ((x == 12) && (y == y13))
                    begin
                    oled_data <= {5'b11111, 6'b111111, 5'b11111};
                    end
         else if ((x == 13) && (y == y14))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 14) && (y == y15))
                      begin
                      oled_data <= {5'b11111, 6'b111111, 5'b11111};
                      end
         else if ((x == 15) && (y == y16))
                       begin
                       oled_data <= {5'b11111, 6'b111111, 5'b11111};
                       end
         else if ((x == 16) && (y == y17))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 17) && (y == y18))
                   begin
                   oled_data <= {5'b11111, 6'b111111, 5'b11111};
                   end
         else if ((x == 18) && (y == y19))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 19) && (y == y20))
                   begin
                   oled_data <= {5'b11111, 6'b111111, 5'b11111};
                   end
         else if ((x == 20) && (y == y21))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 21) && (y == y22))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 22) && (y == y23))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 23) && (y == y24))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 24) && (y == y25))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 25) && (y == y26))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 26) && (y == y27))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 27) && (y == y28))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 28) && (y == y29))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 29) && (y == y30))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 30) && (y == y31))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 31) && (y == y32))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 32) && (y == y33))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 33) && (y == y34))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 34) && (y == y35))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 35) && (y == y36))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 36) && (y == y37))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 37) && (y == y38))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 38) && (y == y39))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 39) && (y == y40))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 40) && (y == y41))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 41) && (y == y42))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 42) && (y == y43))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 43) && (y == y44))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 44) && (y == y45))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 45) && (y == y46))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 46) && (y == y47))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 47) && (y == y48))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 48) && (y == y49))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 49) && (y == y50))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 50) && (y == y51))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 51) && (y == y52))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 52) && (y == y53))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 53) && (y == y54))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 54) && (y == y55))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 55) && (y == y56))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 56) && (y == y57))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 57) && (y == y58))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 58) && (y == y59))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 59) && (y == y60))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 60) && (y == y61))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 61) && (y == y62))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 62) && (y == y63))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 63) && (y == y64))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 64) && (y == y65))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 65) && (y == y66))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 66) && (y == y67))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 67) && (y == y68))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 68) && (y == y69))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 69) && (y == y70))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 70) && (y == y71))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 71) && (y == y72))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 72) && (y == y73))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 73) && (y == y74))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 74) && (y == y75))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 75) && (y == y76))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 76) && (y == y77))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 77) && (y == y78))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 78) && (y == y79))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 79) && (y == y80))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 80) && (y == y81))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 81) && (y == y82))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 82) && (y == y83))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 83) && (y == y84))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 84) && (y == y85))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 85) && (y == y86))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 86) && (y == y87))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 87) && (y == y88))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 88) && (y == y89))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 89) && (y == y90))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 90) && (y == y91))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 91) && (y == y92))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 92) && (y == y93))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 93) && (y == y94))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
          else if ((x == 94) && (y == y95))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
         else if ((x == 95) && (y == y96))
                     begin
                     oled_data <= {5'b11111, 6'b111111, 5'b11111};
                     end
      else   
          begin
          oled_data <= {5'd0, 6'd0, 5'd0};
          end
end


///////////////////////////////////////////////////////////////////////////////
//  Implementation of Improvements (Smooth Color Gradient)                   //
//  To Implement 64 discrete levels to measure sound amplitude/intensity.    //
///////////////////////////////////////////////////////////////////////////////


if((sw == 16'b0000010000000000) && Unlock == 1)
begin
    //1
    if (peak_value >= 2048 && peak_value < 2080) 
        begin
        y_coord <= 64;
        if ((x >= 42 && x < 62) && (y == 64))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end    
            
        end
        
        //2
        if (peak_value >= 2080 && peak_value < 2112) 
        begin
        y_coord <= 63;
        
        if ((x >= 42 && x < 62) && (y == 64 || y == 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
        
        //3
        if (peak_value >= 2112 && peak_value < 2144) 
        begin
        y_coord <= 62;
        
        if ((x >= 42 && x < 62) && (y == 64 || y == 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
        
        //4
        if (peak_value >= 2144 && peak_value < 2176) 
        begin
        y_coord <= 61;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

        //5
        if (peak_value >= 2176 && peak_value < 2208) 
        begin
        y_coord <= 60;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
    
        //6
        if (peak_value >= 2208 && peak_value < 2240) 
        begin
        y_coord <= 59;
        
        if ((x >= 42 && x < 62) && (y == 64 || y == 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
        
        //7
        if (peak_value >= 2240 && peak_value < 2272) 
        begin
        y_coord <= 58;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

        //8
        if (peak_value >= 2272 && peak_value < 2304) 
        begin
        y_coord <= 57;
        
                if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

        //9
        if (peak_value >= 2304 && peak_value < 2336) 
        begin
        y_coord <= 56;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b01000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end

        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
            
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
    
    //10
   if (peak_value >= 2336 && peak_value < 2368) 
        begin
        y_coord <= 55;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
    
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //11
   if (peak_value >= 2368 && peak_value < 2400) 
        begin
        y_coord <= 54;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //12
   if (peak_value >= 2400 && peak_value < 2432) 
        begin
        y_coord <= 53;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //13
   if (peak_value >= 2432 && peak_value < 2464) 
        begin
        y_coord <= 52;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 57))
                begin
                oled_data <= {5'b11111, 6'b001100, 5'd0};
                end
            
        else if ((x >= 42 && x < 62) && (y == 56))
                begin
                oled_data <= {5'b11111, 6'b001110, 5'd0};
                end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

   //14
   if (peak_value >= 2464 && peak_value < 2496) 
        begin
        y_coord <= 51;
        
        if ((x >= 42 && x < 62) && (y== 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y== 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end  

        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //15
   if (peak_value >= 2496 && peak_value < 2528) 
        begin
        y_coord <= 50;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
     
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //16
   if (peak_value >= 2496 && peak_value < 2528) 
        begin
        y_coord <= 49;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

   //17
   if (peak_value >= 2528 && peak_value < 2560) 
        begin
        y_coord <= 48;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

   //18
   if (peak_value >= 2560 && peak_value < 2592) 
        begin
        y_coord <= 47;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
           
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //19
    if (peak_value >= 2592 && peak_value < 2624) 
        begin
        y_coord <= 46;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
           
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //20
    if (peak_value >= 2624 && peak_value < 2656) 
        begin
        y_coord <= 45;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

    //21
    if (peak_value >= 2656 && peak_value < 2688) 
        begin
        y_coord <= 44;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
       
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//22
if (peak_value >= 2688 && peak_value < 2720) 
        begin
        y_coord <= 43;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


//23
if (peak_value >= 2720 && peak_value < 2752) 
        begin
        y_coord <= 42;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


//24
if (peak_value >= 2752 && peak_value < 2784) 
        begin
        y_coord <= 41;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//25
if (peak_value >= 2784 && peak_value < 2816) 
        begin
        y_coord <= 40;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end        
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//26
if (peak_value >= 2816 && peak_value < 2848) 
        begin
        y_coord <= 39;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end                          
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//27
if (peak_value >= 2848 && peak_value < 2880) 
        begin
        y_coord <= 38;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//28
if (peak_value >= 2880 && peak_value < 2912) 
        begin
        y_coord <= 37;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


//29
if (peak_value >= 2912 && peak_value < 2944) 
        begin
        y_coord <= 36;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


//30
if (peak_value >= 2944 && peak_value < 2976) 
        begin
        y_coord <= 35;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


//31
if (peak_value >= 2976 && peak_value < 3008) 
        begin
        y_coord <= 34;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end       
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//32
if (peak_value >= 3008 && peak_value < 3040) 
        begin
        y_coord <= 33;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end        
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//33
if (peak_value >= 3040 && peak_value < 3072) 
        begin
        y_coord <= 32;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


//34
if (peak_value >= 3072 && peak_value < 3104) 
        begin
        y_coord <= 31;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//35
if (peak_value >= 3104 && peak_value < 3136) 
        begin
        y_coord <= 30;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//36
if (peak_value >= 3136 && peak_value < 3172) 
        begin
        y_coord <= 29;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//37
if (peak_value >= 3172 && peak_value < 3208) 
        begin
        y_coord <= 28;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end

        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//38
if (peak_value >= 3208 && peak_value < 3240) 
        begin
        y_coord <= 27;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//39
if (peak_value >= 3240 && peak_value < 3272) 
        begin
        y_coord <= 26;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//40
if (peak_value >= 3272 && peak_value < 3304) 
        begin
        y_coord <= 25;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//41
if (peak_value >= 3304 && peak_value < 3336) 
        begin
        y_coord <= 24;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//42
if (peak_value >= 3336 && peak_value < 3368) 
        begin
        y_coord <= 23;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end


//43
if (peak_value >= 3368 && peak_value < 3400) 
        begin
        y_coord <= 22;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end
        

//44
if (peak_value >= 3400 && peak_value < 3432) 
        begin
        y_coord <= 21;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//45
if (peak_value >= 3432 && peak_value < 3464) 
        begin
        y_coord <= 20;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
                           begin
                           oled_data <= {5'b000000, 6'b011110, 5'b11010};
                           end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//46
if (peak_value >= 3464 && peak_value < 3496) 
        begin
        y_coord <= 19;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//47
if (peak_value >= 3496 && peak_value < 3528) 
        begin
        y_coord <= 18;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end            
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//48
if (peak_value >= 3528 && peak_value < 3560) 
        begin
        y_coord <= 17;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//49
if (peak_value >= 3560 && peak_value < 3592) 
        begin
        y_coord <= 16;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//50
if (peak_value >= 3560 && peak_value < 3592) 
        begin
        y_coord <= 15;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//51
if (peak_value >= 3592 && peak_value < 3624) 
        begin
        y_coord <= 14;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//52
if (peak_value >= 3624 && peak_value < 3656) 
        begin
        y_coord <= 13;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                    begin
                    oled_data <= {5'b000000, 6'b010100, 5'b11110};
                    end  
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//53
if (peak_value >= 3656 && peak_value < 3688) 
        begin
        y_coord <= 12;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//54
if (peak_value >= 3688 && peak_value < 3720) 
        begin
        y_coord <= 11;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//55
if (peak_value >= 3720 && peak_value < 3752) 
        begin
        y_coord <= 10;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//56
if (peak_value >= 3752 && peak_value < 3784) 
        begin
        y_coord <= 9;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//57
if (peak_value >= 3784 && peak_value < 3816) 
        begin
        y_coord <= 8;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//58
if (peak_value >= 3816 && peak_value < 3848) 
        begin
        y_coord <= 7;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//59
if (peak_value >= 3848 && peak_value < 3880) 
        begin
        y_coord <= 6;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 6))
                begin
                oled_data <= {5'b000000, 6'b000110, 5'b11110};
                end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//60
if (peak_value >= 3880 && peak_value < 3912) 
        begin
        y_coord <= 5;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 6))
                begin
                oled_data <= {5'b000000, 6'b000110, 5'b11110};
                end   
      else if ((x >= 42 && x < 62) && (y == 5))
              begin
              oled_data <= {5'b000000, 6'b000100, 5'b11110};
              end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//61
if (peak_value >= 3912 && peak_value < 3944) 
        begin
        y_coord <= 4;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 6))
                begin
                oled_data <= {5'b000000, 6'b000110, 5'b11110};
                end   
      else if ((x >= 42 && x < 62) && (y == 5))
              begin
              oled_data <= {5'b000000, 6'b000100, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 4))
              begin
              oled_data <= {5'b000000, 6'b000010, 5'b11110};
              end   
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//62
if (peak_value >= 3944 && peak_value < 3976) 
        begin
        y_coord <= 3;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 6))
                begin
                oled_data <= {5'b000000, 6'b000110, 5'b11110};
                end   
      else if ((x >= 42 && x < 62) && (y == 5))
              begin
              oled_data <= {5'b000000, 6'b000100, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 4))
              begin
              oled_data <= {5'b000000, 6'b000010, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 3))
              begin
              oled_data <= {5'b000000, 6'b000000, 5'b11110};
              end  
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//63
if (peak_value >= 3976 && peak_value < 4008) 
        begin
        y_coord <= 2;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 6))
                begin
                oled_data <= {5'b000000, 6'b000110, 5'b11110};
                end   
      else if ((x >= 42 && x < 62) && (y == 5))
              begin
              oled_data <= {5'b000000, 6'b000100, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 4))
              begin
              oled_data <= {5'b000000, 6'b000010, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 3))
              begin
              oled_data <= {5'b000000, 6'b000000, 5'b11110};
              end  
      else if ((x >= 42 && x < 62) && (y == 2))
              begin
              oled_data <= {5'b000000, 6'b000000, 5'b11111};
              end  
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//64
if (peak_value >= 4008 && peak_value < 4040) 
        begin
        y_coord <= 1;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 6))
                begin
                oled_data <= {5'b000000, 6'b000110, 5'b11110};
                end   
      else if ((x >= 42 && x < 62) && (y == 5))
              begin
              oled_data <= {5'b000000, 6'b000100, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 4))
              begin
              oled_data <= {5'b000000, 6'b000010, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 3))
              begin
              oled_data <= {5'b000000, 6'b000000, 5'b11110};
              end  
      else if ((x >= 42 && x < 62) && (y == 2 || y == 1))
              begin
              oled_data <= {5'b000000, 6'b000000, 5'b11111};
              end  
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

//65
if (peak_value >= 4040) 
        begin
        y_coord <= 0;
        
        if ((x >= 42 && x < 62) && (y == 64 || y== 63))
            begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 62))
            begin
            oled_data <= {5'b11111, 6'b000010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 61))
            begin
            oled_data <= {5'b11111, 6'b000100, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 60))
            begin
            oled_data <= {5'b11111, 6'b000110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 59))
            begin
            oled_data <= {5'b11111, 6'b001000, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 58))
            begin
            oled_data <= {5'b11111, 6'b001010, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 57))
            begin
            oled_data <= {5'b11111, 6'b001100, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 56))
            begin
            oled_data <= {5'b11111, 6'b001110, 5'd0};
            end
        
        else if ((x >= 42 && x < 62) && (y == 55))
            begin
            oled_data <= {5'b11111, 6'b010000, 5'd0};
            end
            
        else if ((x >= 42 && x < 62) && (y == 54))
            begin
            oled_data <= {5'b11111, 6'b010010, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 53))
            begin
            oled_data <= {5'b11111, 6'b010100, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 52))
            begin
            oled_data <= {5'b11111, 6'b010110, 5'd0};
            end    
        else if ((x >= 42 && x < 62) && (y == 51))
            begin
            oled_data <= {5'b11111, 6'b011000, 5'd0};
            end    
       else if ((x >= 42 && x < 62) && (y == 50))
           begin
           oled_data <= {5'b11111, 6'b011010, 5'd0};
           end    
       else if ((x >= 42 && x < 62) && (y == 49))
          begin
          oled_data <= {5'b11111, 6'b011100, 5'd0};
          end    

       else if ((x >= 42 && x < 62) && (y == 48))
          begin
          oled_data <= {5'b11101, 6'b011110, 5'd0};
          end   

       else if ((x >= 42 && x < 62) && (y == 47))
          begin
          oled_data <= {5'b11011, 6'b011110, 5'd0};
          end  
 
       else if ((x >= 42 && x < 62) && (y == 46))
             begin
             oled_data <= {5'b11001, 6'b011110, 5'd0};
             end  
             
       else if ((x >= 42 && x < 62) && (y == 45))
            begin
            oled_data <= {5'b10111, 6'b011110, 5'd0};
            end    
          
       else if ((x >= 42 && x < 62) && (y == 44))
                 begin
                 oled_data <= {5'b10101, 6'b011110, 5'd0};
                 end 
                 
      else if ((x >= 42 && x < 62) && (y == 43))
                   begin
                   oled_data <= {5'b10011, 6'b011110, 5'd0};
                   end      
      else if ((x >= 42 && x < 62) && (y == 42))
                    begin
                    oled_data <= {5'b10001, 6'b011110, 5'd0};
                    end
      else if ((x >= 42 && x < 62) && (y == 41))
                      begin
                      oled_data <= {5'b01111, 6'b011110, 5'd0};
                      end
      else if ((x >= 42 && x < 62) && (y == 40))
                      begin
                      oled_data <= {5'b01101, 6'b011110, 5'd0};
                      end    
      else if ((x >= 42 && x < 62) && (y == 39))
                      begin
                      oled_data <= {5'b01011, 6'b011110, 5'd0};
                      end      
     else if ((x >= 42 && x < 62) && (y == 38))
                      begin
                      oled_data <= {5'b01001, 6'b011110, 5'd0};
                      end
     else if ((x >= 42 && x < 62) && (y == 37))
                       begin
                       oled_data <= {5'b00111, 6'b011110, 5'd0};
                       end     
     else if ((x >= 42 && x < 62) && (y == 36))
                     begin
                     oled_data <= {5'b00101, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 35))
                     begin
                     oled_data <= {5'b000011, 6'b011110, 5'd0};
                     end 
      else if ((x >= 42 && x < 62) && (y == 34))
                    begin
                    oled_data <= {5'b000001, 6'b011110, 5'd0};
                    end 
      else if ((x >= 42 && x < 62) && (y == 33))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'd0};
                  end      
       else if ((x >= 42 && x < 62) && (y == 32))
                  begin
                  oled_data <= {5'b000000, 6'b011110, 5'b00010};
                  end   
       else if ((x >= 42 && x < 62) && (y == 31))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b00100};
                 end   
       else if ((x >= 42 && x < 62) && (y == 30))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b00110};
                end
       else if ((x >= 42 && x < 62) && (y == 29))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b01000};
                 end
        else if ((x >= 42 && x < 62) && (y == 28))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b01010};
               end
       else if ((x >= 42 && x < 62) && (y == 27))
                     begin
                     oled_data <= {5'b000000, 6'b011110, 5'b01100};
                     end
       else if ((x >= 42 && x < 62) && (y == 26))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b01110};
                   end
       else if ((x >= 42 && x < 62) && (y == 25))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10000};
                   end
       else if ((x >= 42 && x < 62) && (y == 24))
                   begin
                   oled_data <= {5'b000000, 6'b011110, 5'b10010};
                   end 
       else if ((x >= 42 && x < 62) && (y == 23))
                       begin
                       oled_data <= {5'b000000, 6'b011110, 5'b10100};
                       end 
      else if ((x >= 42 && x < 62) && (y == 22))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b10110};
               end 
     else if ((x >= 42 && x < 62) && (y == 21))
                begin
                oled_data <= {5'b000000, 6'b011110, 5'b11000};
                end 
     else if ((x >= 42 && x < 62) && (y == 20))
               begin
               oled_data <= {5'b000000, 6'b011110, 5'b11010};
               end 
     else if ((x >= 42 && x < 62) && (y == 19))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11100};
                 end         
     else if ((x >= 42 && x < 62) && (y == 18))
                 begin
                 oled_data <= {5'b000000, 6'b011110, 5'b11110};
                 end 
     else if ((x >= 42 && x < 62) && (y == 17))
                 begin
                 oled_data <= {5'b000000, 6'b011100, 5'b11110};
                 end  
     else if ((x >= 42 && x < 62) && (y == 16))
                 begin
                 oled_data <= {5'b000000, 6'b011010, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 15))
                 begin
                 oled_data <= {5'b000000, 6'b011000, 5'b11110};
                 end 
    else if ((x >= 42 && x < 62) && (y == 14))
                  begin
                  oled_data <= {5'b000000, 6'b010110, 5'b11110};
                  end         
    else if ((x >= 42 && x < 62) && (y == 13))
                begin
                oled_data <= {5'b000000, 6'b010100, 5'b11110};
                end  
     else if ((x >= 42 && x < 62) && (y == 12))
                begin
                oled_data <= {5'b000000, 6'b010010, 5'b11110};
                end         
     else if ((x >= 42 && x < 62) && (y == 11))
               begin
               oled_data <= {5'b000000, 6'b010000, 5'b11110};
               end   
     else if ((x >= 42 && x < 62) && (y == 10))
             begin
             oled_data <= {5'b000000, 6'b001110, 5'b11110};
             end   
      else if ((x >= 42 && x < 62) && (y == 9))
                 begin
                 oled_data <= {5'b000000, 6'b001100, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 8))
                 begin
                 oled_data <= {5'b000000, 6'b001010, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 7))
                 begin
                 oled_data <= {5'b000000, 6'b001000, 5'b11110};
                 end   
      else if ((x >= 42 && x < 62) && (y == 6))
                begin
                oled_data <= {5'b000000, 6'b000110, 5'b11110};
                end   
      else if ((x >= 42 && x < 62) && (y == 5))
              begin
              oled_data <= {5'b000000, 6'b000100, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 4))
              begin
              oled_data <= {5'b000000, 6'b000010, 5'b11110};
              end   
      else if ((x >= 42 && x < 62) && (y == 3))
              begin
              oled_data <= {5'b000000, 6'b000000, 5'b11110};
              end  
      else if ((x >= 42 && x < 62) && (y <= 2))
              begin
              oled_data <= {5'b000000, 6'b000000, 5'b11111};
              end  
        else
            begin
            oled_data <= {5'd0, 6'd0, 5'd0};
            end
        end

end


end


end


wire my_frame_begin, my_sendpix, sample_pix; //dont need these. Just wire




//output the rgb_ stuff on the OLED
Oled_Display my_oled_unit(.clk(My_Clock6p25mHz), .reset(0), .frame_begin(my_frame_begin), .sending_pixels(my_sendpix),
  .sample_pixel(sample_pix), .pixel_index(pixel_index), .pixel_data(oled_data), 
  .cs(rgb_cs), .sdin(rgb_sdin), .sclk(rgb_sclk), .d_cn(rgb_d_cn), .resn(rgb_resn), .vccen(rgb_vccen),
  .pmoden(rgb_pmoden), 
  .teststate(0));


endmodule
