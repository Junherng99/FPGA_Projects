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


module morse_code (
    input [15:0]sw,
    input pbU,pbD,pbL,pbR,pbC,
    input Main_Clock,
//    input my_pixelindex,
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    output reg [15:0]led=0,
    output rbg_cs, rbg_sdin, rbg_sclk, rbg_cn, rbg_resgn, rbg_vccen, rbg_pmodern,
    output reg [3:0] an=4'b1111,
    output reg [7:0] seg=8'b11111111
    );


    wire My_Clock6p25mHz;
    wire My_Clock20kHz;
    wire clock_selector;
    wire [11:0]Mic_in; 
    reg [15:0]oled_data = 16'h07E0;
   
    Flex_Clk MyClock3(.Clock(Main_Clock), .m(32'd7), .My_Clock(My_Clock6p25mHz));
    Flex_Clk MyClock1(.Clock(Main_Clock), .m(32'd2499), .My_Clock(My_Clock20kHz));
   
   Audio_Capture soundsystem(
       .CLK(Main_Clock),
       .cs(My_Clock20kHz),                   
       .MISO(J_MIC3_Pin3),                 
       .clk_samp(J_MIC3_Pin1),            
       .sclk(J_MIC3_Pin4),           
       .sample(Mic_in)     
       );
       
     
       wire my_framebegin;
       wire my_sendingpixel;
       wire my_samplepixel; 
       wire [12:0] my_pixel_index;
       
       Oled_Display My_display(
       .clk(My_Clock6p25mHz), .reset(0), 
       .frame_begin(my_framebegin), .sending_pixels(my_sendingpixel),
       .sample_pixel(my_samplepixel), 
       .pixel_index(my_pixel_index), .pixel_data(oled_data), 
       .cs(rbg_cs), .sdin(rbg_sdin), .sclk(rbg_sclk), .d_cn(rbg_cn), 
       .resn(rbg_resgn), .vccen(rbg_vccen),
       .pmoden(rbg_pmodern),.teststate(0));
       
      
reg [31:0]LEDcounter3s=0;
reg ledcheck3s=0;
reg [31:0]LEDcounter1s=0;
reg ledcheck1s=0;
reg [31:0]count1s =0;
reg [31:0]count3s =0;
reg dash=0;
reg dot=0;
reg my_pbD_pressed =0;
reg pbR_press=0;

reg [14:0]morsecode=0;
reg [4:0]seq=0;
reg [3:0]shift=0;
reg Unlock = 0;

always @(posedge My_Clock6p25mHz)
begin

if(pbL==1)                     // reset button
begin
morsecode<=15'b000000000000000;
led[2] <=0;
led[3]<=0;
led[5]<=0;
led[6]<=0;
shift <=0;
pbR_press <=0;
an[3:0]<=4'b1111;
seg[7:0]<= 8'b11111111;
end

if (pbD == 0)
begin
count3s <=0;
count1s <=0;

end

if ((pbD ==1) && (my_pbD_pressed ==0))                 
begin
my_pbD_pressed <=1;                
end                     

if((my_pbD_pressed ==1) && (pbD==1))               // press and hold
begin
count3s <= (count3s == 18750000) ? 0 : count3s + 1;
count1s <= (count1s == 6250000) ? 0 : count1s +1;
end


if((my_pbD_pressed ==1) && (pbD==0) && (count3s < 49999999))   // press and release before 1s
begin   
my_pbD_pressed <= 0; 
end


if ((count3s == 18750000))            // after 3s
begin
dash <=1;
end

if (count1s == 6250000)               // after 1s
begin
dot <=1;
end


if ((dot ==1) && ( dash ==0) && (pbD==0) && (shift<5) && (pbR==0))                 // once release after 1s of holding
begin 
led[7] <=1;
my_pbD_pressed <=0;   
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


if ((dash ==1) && (pbD==0) && (shift<5) && (pbR==0))                // once release after 3s of holding
begin
my_pbD_pressed <=0;
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


if (pbR==1)
begin
pbR_press <=1;
end

if((shift==5) || (pbR_press ==1))              // max shift or when user press enter (pbR)
begin
if(morsecode==15'b011011011011011)            // represent 0 in morse code
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11000000;
end


if(morsecode==15'b001011011011011)          // 1
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11111001;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001011011011)          //2
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10100100;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001001011011)          // 3
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10110000;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001001001011)              // 4
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10011001;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b001001001001001)      // 5
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10010010;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011001001001001)      // 6
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10000010;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011011001001001)      // 7
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11111000;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011011011001001)      // 8
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10000000;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b011011011011001)      // 9
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10010000;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000000001011)      // A
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10001000;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000011001001001)      // B
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10000011;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000011001011001)      // C
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10100111;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000011001001)      // d
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10100001;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000000000001)      // E
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10000110;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000001001011001)      // F
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10001110;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000011011001)      // G
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11000010;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000001001001001)      // H
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10001001;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000000001001)      // I
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11001111;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000001011011011)      // J
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11100001;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000001011001001)      // L
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11000111;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000000011001)      // N
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10101011;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000011011011)      // O
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11000000;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000001011011001)      // P
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10001100;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000011011001011)      // Q
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10011000;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000001011001)      // r
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10101111;
shift <=0;
pbR_press <=0;
end

if(morsecode==15'b000000001001001)      // S
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10010010;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000000000011)      // t
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10000111;
shift <=0;
pbR_press <=0;
end


if(morsecode==15'b000000001001011)      // U
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b11000001;
shift <=0;
pbR_press <=0;
Unlock <= 1;
end

if(morsecode==15'b000011001011011)      // y
begin
an[3:0]<=4'b1110;
seg[7:0]<= 8'b10010001;
shift <=0;
pbR_press <=0;
end

end
end






   
endmodule