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


module Improvements(
    input Main_Clock,
    input J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    input [15:0]sw,
    input btnC, btnU, btnL, btnR, btnD,
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,   // Connect to this signal from Audio_Capture.v
    output reg [15:0]led = 0,
    output wire [3:0]an,           //an and seg are active low signals!!!!
    output wire [7:0]seg,  
    output rgb_cs, rgb_sdin, rgb_sclk, rgb_d_cn, rgb_resn, rgb_vccen, rgb_pmoden
    // Delete this comment and include other inputs and outputs here
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
    wire [11:0]mic_in;
    reg [15:0]oled_data = 16'h07E0;     
    wire My_Clock20kHz;
    wire My_Clock6p25mHz;
    wire My_Clock500kHz;
    wire trigger;
    wire [31:0] FiveCounter;
    reg [7:0]y_coord = 0; 
    
    Flex_Clk MyClock0(.Clock(Main_Clock), .m(32'd4999999), .My_Clock(My_Clock10Hz)); 
    Flex_Clk MyClock1(.Clock(Main_Clock), .m(32'd2499), .My_Clock(My_Clock20kHz));
    Flex_Clk MyClock3(.Clock(Main_Clock), .m(32'd7), .My_Clock(My_Clock6p25mHz));
    five_sec_counter My_Counter1(.Main_Clock(Main_Clock), .btnD(btnD), .FiveCounter(FiveCounter), .trigger(trigger));
    seven_seg_counter seven_disp(.Main_Clock(Main_Clock),.y(y_coord),.an(an),.seg(seg));

    
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
assign freeze = sw[15];


///////////////////////////////////////////////////////////////////////////////
//  Implementation of Improvements (Smooth Color Gradient)                   //
//  To Implement 64 discrete levels to measure sound amplitude/intensity.    //
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// //4.2c AVI Task AVI2A fast clock should be used to avoid nyquist effects. //
///////////////////////////////////////////////////////////////////////////////
reg [11:0]xcount = 0;
reg [31:0]Lcount = 0;
reg [11:0] peak_value = 0;
reg [11:0] current_mic = 0;
reg [11:0] current_peak = 0;



always @(posedge My_Clock6p25mHz)    
    begin
    Lcount <= Lcount + 1;
    current_mic[11:0] <= mic_in[11:0];
    if (current_mic > current_peak)
    begin
    current_peak[11:0] <= current_mic[11:0];
    end
    
    if (Lcount == 625000)  //0.1s max amplitude output
    begin
    peak_value[11:0] <= current_peak[11:0];
    Lcount <= 0;
    current_peak <= 0;
    end
        




////////////////////DISPLAY////////////////////




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




wire my_frame_begin, my_sendpix, sample_pix; //dont need these. Just wire




//output the rgb_ stuff on the OLED
Oled_Display my_oled_unit(.clk(My_Clock6p25mHz), .reset(0), .frame_begin(my_frame_begin), .sending_pixels(my_sendpix),
  .sample_pixel(sample_pix), .pixel_index(pixel_index), .pixel_data(oled_data), 
  .cs(rgb_cs), .sdin(rgb_sdin), .sclk(rgb_sclk), .d_cn(rgb_d_cn), .resn(rgb_resn), .vccen(rgb_vccen),
  .pmoden(rgb_pmoden), 
  .teststate(0));


endmodule
