module aaa(
// Clock Input (50 MHz)
  input  CLOCK_50,
  //  Push Buttons
  input  [3:0]  KEY,
  //  DPDT Switches 
  input  [17:0]  SW,
  
   //  7-SEG Displays  
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output [7:0] sum,
  output cout,
  // This is added to the convert the 8-bits to different HEX_
  output [3:0] ONES, TENS,
  output [1:0] HUNDREDS,
  output  [3:0] finalhundred,
  //  LEDs
  output  [8:0]  LEDG,  //  LED Green[8:0]
  output  [17:0]  LEDR, //  LED Red[17:0]
  //  GPIO Connections
  inout  [35:0]  GPIO_0, GPIO_1
);
//  set all inout ports to tri-state
assign  GPIO_0    =  36'hzzzzzzzzz;
assign  GPIO_1    =  36'hzzzzzzzzz;

// Connect dip switches to red LEDs
assign LEDR[17:0] = SW[17:0];
wire [15:0] A;
//always @(negedge KEY[3])
//    A <= SW[15:0];
// The algorithm to be used comes here.
// This time we use counter code here.
//module countercode(D,clk,load,Q);
countercode(SW[3:0],KEY[0],KEY[1],sum[3:0]);

// Before assigning the 8-bit sum to different HEX,
// we call this module to send the desired decimal.
// multiply_to_BCD(A,ONES, TENS, HUNDREDS);
binary_to_BCD(sum[7:0],ONES, TENS,HUNDREDS);
assign finalhundred = {2'b00,HUNDREDS[1:0]};
hex_7seg dsp0(ONES,HEX0);
hex_7seg dsp1(TENS,HEX1);
hex_7seg dsp2(finalhundred,HEX2);
assign HEX3 = blank;
assign HEX4 = blank;
assign HEX5 = blank;
assign HEX6 = blank;
assign HEX7 = blank;

wire [6:0] blank = ~7'h00;
assign A = SW[15:0];
endmodule

module hex_7seg(hex_digit,seg);
input [3:0] hex_digit;
output [6:0] seg;
reg [6:0] seg;
// seg = {g,f,e,d,c,b,a};
// 0 is on and 1 is off

always @ (hex_digit)
case (hex_digit)
        4'h0: seg = ~7'h3F;
        4'h1: seg = ~7'h06;     // ---a----
        4'h2: seg = ~7'h5B;     // |      |
        4'h3: seg = ~7'h4F;     // f      b
        4'h4: seg = ~7'h66;     // |      |
        4'h5: seg = ~7'h6D;     // ---g----
        4'h6: seg = ~7'h7D;     // |      |
        4'h7: seg = ~7'h07;     // e      c
        4'h8: seg = ~7'h7F;     // |      |
        4'h9: seg = ~7'h67;     // ---d----
        4'ha: seg = ~7'h77;
        4'hb: seg = ~7'h7C;
        4'hc: seg = ~7'h39;
        4'hd: seg = ~7'h5E;
        4'he: seg = ~7'h79;
        4'hf: seg = ~7'h71;
endcase
endmodule

// This module is to make the 8 bits sum to display on 
// three different HEX0, HEX1, HEX2
module binary_to_BCD(A,ONES,TENS,HUNDREDS); 
input [7:0] A; 
output [3:0] ONES, TENS; 
output [1:0] HUNDREDS; 
wire [3:0] c1,c2,c3,c4,c5,c6,c7; 
wire [3:0] d1,d2,d3,d4,d5,d6,d7;  
assign d1 = {1'b0,A[7:5]}; 
assign d2 = {c1[2:0],A[4]}; 
assign d3 = {c2[2:0],A[3]}; 
assign d4 = {c3[2:0],A[2]}; 
assign d5 = {c4[2:0],A[1]}; 
assign d6 = {1'b0,c1[3],c2[3],c3[3]}; 
assign d7 = {c6[2:0],c4[3]}; 

add3 m1(d1,c1); 
add3 m2(d2,c2); 
add3 m3(d3,c3); 
add3 m4(d4,c4); 
add3 m5(d5,c5); 
add3 m6(d6,c6); 
add3 m7(d7,c7); 
assign ONES = {c5[2:0],A[0]}; 
assign TENS = {c7[2:0],c5[3]}; 
assign HUNDREDS = {c6[3],c7[3]};  
endmodule

// This module is called from the previous module to calculate
// the 8-bits to three different HEX.
module add3(in,out); 
input [3:0] in; 
output [3:0] out; 
reg [3:0] out;  
always @ (in)  
case (in)  
  4'b0000: out <= 4'b0000;  
  4'b0001: out <= 4'b0001;  
  4'b0010: out <= 4'b0010;  
  4'b0011: out <= 4'b0011;  
  4'b0100: out <= 4'b0100;  
  4'b0101: out <= 4'b1000;  
  4'b0110: out <= 4'b1001;  
  4'b0111: out <= 4'b1010;  
  4'b1000: out <= 4'b1011;  
  4'b1001: out <= 4'b1100;  
  default: out <= 4'b0000;  
endcase 
endmodule 

module countercode(D,clk,load,Q);
  input[3:0] D;
  input clk;
  input load;
  output [3:0] Q;

  wire  DA1, DA2,DB1,DB2,DB3,DC1,DC2,DC3;
  reg [3:0] cnt;
  // W = cnt[0] Z =cnt[1]  Y=cnt[2]  X=cnt[3]
  always@(negedge clk)
   begin
     if(~load)
      cnt=D;
     else 
       cnt =Q;
    end
  /////////////////////change here////////////////////////  
  
  assign Tx = (~cnt[2]&~cnt[0]&~cnt[1]);    
  //         // Da = B' + AC
  // and(DA1, cnt[2],cnt[0]);   //  AC
  // or(DA2,DA1,~cnt[1]);       //   B' + AC
  T_FF(Tx,clk,Q[3]);


  assign Ty = ((cnt[3]&~cnt[0]) | (cnt[2]&~cnt[0]&~cnt[1]));

  // Db = AC +BC'
  // and(DB1,cnt[2],cnt[0]);   // AC
  // and(DB2,cnt[1],~cnt[0]);   //BC'
  // or(DB3,DB1,DB2);
  T_FF(Ty,clk,Q[2]);


  assign Tz = ((cnt[1]&~cnt[0]) | (cnt[3]&~cnt[0]) | (cnt[2]&~cnt[1]&~cnt[0]));

   // Dc = A'B + AB'
  // and(DC1,cnt[2],~cnt[1]);   //A'B
  // and(DC2,~cnt[2],cnt[1]);   //AB'
  // or(DC3,DC1,DC2);
  T_FF(Tz,clk,Q[1]);

  assign Tw = 1;

  T_FF(Tw,clk,Q[0]);

  endmodule 
  
  ///////////////////change here//////////////////////////

module T_FF(T,Clock,Q);
  
  input T,Clock;
  output Q;
  reg Q;
  always@ (posedge Clock)
    if(T == 1)
      Q <= ~Q;

endmodule