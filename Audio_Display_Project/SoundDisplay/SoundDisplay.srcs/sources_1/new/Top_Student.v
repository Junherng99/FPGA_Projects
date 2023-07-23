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


module Top_Student (
    input Main_Clock,
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    input [15:0]sw,
    input pbU,pbD,pbL,pbR,pbC,
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,   // Connect to this signal from Audio_Capture.v
    output reg [15:0]led = 0,
    output reg [3:0]an = 4'b1111,           //an and seg are active low signals!!!!
    output reg [7:0] seg = 8'b11111111,  
    output rgb_cs, rgb_sdin, rgb_sclk, rgb_d_cn, rgb_resn, rgb_vccen, rgb_pmoden
    // Delete this comment and include other inputs and outputs here
    );
    
    wire My_Clock10Hz;
    wire [11:0]mic_in;
    reg [15:0]oled_data = 16'h07E0;     
    wire My_Clock20kHz;
    wire My_Clock6p25mHz;
    wire My_Clock500kHz;
    wire trigger;
    wire [31:0] FiveCounter;
    wire my_frame_begin, my_sendpix, sample_pix; //dont need these. Just wire
    
    Flex_Clk MyClock0(.Clock(Main_Clock), .m(32'd4999999), .My_Clock(My_Clock10Hz)); 
    Flex_Clk MyClock1(.Clock(Main_Clock), .m(32'd2499), .My_Clock(My_Clock20kHz));
    Flex_Clk MyClock3(.Clock(Main_Clock), .m(32'd7), .My_Clock(My_Clock6p25mHz));
    five_sec_counter My_Counter1(.Main_Clock(Main_Clock), .btnD(pbD), .FiveCounter(FiveCounter), .trigger(trigger));
    
    
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

reg [2:0]PBcounter = 0;

assign x = pixel_index%96;
assign y = pixel_index/96;

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


reg [31:0]Lcount = 0;
reg [11:0] peak_value = 0;
reg [11:0] current_mic = 0;
reg [11:0] current_peak = 0;




/////////////////////////////////////////////////////////////////
// 4.1 OLED/MIC integration test (part 1) Audio Signal on OLED //
/////////////////////////////////////////////////////////////////


//always @(posedge My_Clock10Hz)       //initialised state
//    begin
//    led[11:0] <= mic_in[11:0];
//    oled_data = {5'd0 , mic_in[11:6], 5'd0}; 
//    end



//////////////////////
// 4.2b OLED Task B //
//////////////////////




//always @(posedge trigger)
//begin
//if (sw[0] == 1) //switching mechanism
//begin
//    if(PBcounter < 3)
//    begin
//    PBcounter <= PBcounter + 1;
//    end
    
//    else if (PBcounter == 3)
//    begin
//    PBcounter <= 0;
//    end
// end   
    
//    end
    

//always @(posedge My_Clock6p25mHz) 
//if(sw[0] == 1)
//begin

//    begin
//    if  (trigger == 1)
//    begin
//    led[12] <= 1;
//    end
//    else if (trigger == 0)
//    begin
//    led[12] <= 0;
//    end
    
    
    
//if (PBcounter == 0)
//    begin   
            
//      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
//          begin
//          oled_data <= {5'b11111, 6'd0, 5'd0};
//          end
//       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
//          begin
//          oled_data <= {5'b11111, 6'b010000, 5'b00000};
//          end
//        else
//            begin
//            oled_data <= {5'd0, 6'd0, 5'd0};
//            end
//        end


//    if (PBcounter == 1)
//            begin 
            
                
//      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
//          begin
//          oled_data <= {5'b11111, 6'd0, 5'd0};
//          end
//       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
//          begin
//          oled_data <= {5'b11111, 6'b010000, 5'b00000};
//          end
//      else if ((x >= 42 && x < 52) && (y >= 43 && y < 48))
//          begin
//          oled_data <= {5'd0, 6'b111111, 5'd0};
//          end
     
//        else
//            begin
//            oled_data <= {5'd0, 6'd0, 5'd0};
//            end
//        end
        
        
//if (PBcounter == 2)        
//    begin
        
//      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
//          begin
//          oled_data <= {5'b11111, 6'd0, 5'd0};
//          end
//       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
//          begin
//          oled_data <= {5'b11111, 6'b010000, 5'b00000};
//          end
//      else if ((x >= 42 && x < 52) && (y >= 43 && y < 48))
//          begin
//          oled_data <= {5'd0, 6'b111111, 5'd0};
//          end
//       else if ((x >= 42 && x < 52) && (y >= 35 && y < 40))
//          begin
//          oled_data <= {5'b00110, 6'b111111, 5'b00110};
//          end     
//      else
//          begin
//          oled_data <= {5'd0, 6'd0, 5'd0};
//          end
//      end
      

// if (PBcounter == 3)
//    begin    
//      if ((x >= 42 && x < 52) && (y >= 59 && y < 64))
//          begin
//          oled_data <= {5'b11111, 6'd0, 5'd0};
//          end
//       else if ((x >= 42 && x < 52) && (y >= 51 && y < 56)) //I left 3 pixel spacing for every new box
//          begin
//          oled_data <= {5'b11111, 6'b010000, 5'b00000};
//          end
//      else if ((x >= 42 && x < 52) && (y >= 43 && y < 48))
//          begin
//          oled_data <= {5'd0, 6'b111111, 5'd0};
//          end
//       else if ((x >= 42 && x < 52) && (y >= 35 && y < 40))
//          begin
//          oled_data <= {5'b00110, 6'b111111, 5'b00110};
//          end         
//     else if ((x >= 42 && x < 52) && (y >= 27 && y < 32))
//          begin
//          oled_data <= {5'b01110, 6'b111111, 5'b01110};
//          end     
//      else
//          begin
//          oled_data <= {5'd0, 6'd0, 5'd0};
//          end
//      end
// end      
      
// end 
    
///////////////////////////////////////////////////////////////////////////////
// //4.2c AVI Task AVI2A fast clock should be used to avoid nyquist effects. //
///////////////////////////////////////////////////////////////////////////////




always @(posedge My_Clock6p25mHz)    
    begin
    Lcount <= Lcount + 1;
    current_mic[11:0] <= mic_in[11:0];
    an[0] <= 0;
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
    
    if (peak_value >= 2048 && peak_value < 2100)
        begin
        led <= 12'b0000000000000000;
        seg <= zero;
        oled_data <= {5'd0, 6'd0, 5'd0};
        end
        
        if (peak_value >= 2100 && peak_value < 2500)
        begin
        led <= 12'b0000000000000000001;
        seg <= one;
        
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
        
        if (peak_value >= 2500 && peak_value <= 2900)
        begin
        led <= 12'b0000000000000011;
        seg <= two;
        
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
            seg <= three;
            
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
            seg <= four;
            
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
            seg <= five;
            
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



//output the rgb_ stuff
Oled_Display my_oled_unit(.clk(My_Clock6p25mHz), .reset(0), .frame_begin(my_frame_begin), .sending_pixels(my_sendpix),
  .sample_pixel(sample_pix), .pixel_index(pixel_index), .pixel_data(oled_data), 
  .cs(rgb_cs), .sdin(rgb_sdin), .sclk(rgb_sclk), .d_cn(rgb_d_cn), .resn(rgb_resn), .vccen(rgb_vccen),
  .pmoden(rgb_pmoden), 
  .teststate(0));

endmodule


