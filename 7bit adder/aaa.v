//This module is the highest level of the module.
// it includes all the input and output in the DE2-70
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
// I am adding this code to 
seven_bit(cout,sum[6:0],SW[13:7],SW[6:0],1'b0);
//assign sum[3]=cout;
//assign sum[4]=1'b0;
//assign sum[5]=1'b0;
//assign sum[6]=1'b0;
assign sum[7]=cout;
// Now I call the BCD here to convert the result to various HEX display.
BCD(sum[7:0],ONES, TENS,HUNDREDS);
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


// The BCD module begin here.
module BCD (A,ONES, TENS, HUNDREDS);
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
assign ONES = {c5[2:0],A[0]}; 
assign TENS = {c7[2:0],c5[3]}; 
assign HUNDREDS = {c6[3],c7[3]}; 
add3 m1(d1,c1); 
add3 m2(d2,c2); 
add3 m3(d3,c3); 
add3 m4(d4,c4); 
add3 m5(d5,c5); 
add3 m6(d6,c6); 
add3 m7(d7,c7); 
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

//Here I have the four binary Adder module (ADDER Logic)
module f_adder(sum,cout,cin,inp1,inp2);
input cin, inp1, inp2;
output sum,cout;
wire w1,w2,w3;
xor x1(w1,inp1,inp2);
xor x2(sum,w1,cin);
and a1(w2,inp1,inp2);
and a2(w3,w1,cin);
or(cout,w2,w3);
endmodule

module seven_bit(cout,sum,x,y,cin);
input [6/*3*/:0] x,y;
input cin;
output [7:0] sum;
output cout;
wire d1,d2,d3;
f_adder f1(sum[0],d1,x[0],y[0],cin);
f_adder f2(sum[1],d2,x[1],y[1],d1);
f_adder f3(sum[2],d3,x[2],y[2],d2);
f_adder f4(sum[3],d4,x[3],y[3],d3);
f_adder f5(sum[4],d5,x[4],y[4],d4);
f_adder f6(sum[5],d6,x[5],y[5],d5);
f_adder f7(sum[6],cout,x[6],y[6],d6);
//f_adder f4(sum[3],cout,x[3],y[3],d3);
endmodule

