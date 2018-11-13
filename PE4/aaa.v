module aaa(
  // Clock Input (50 MHz)
  input  CLOCK_50,
  //  Push Buttons
  input  [3:0]  KEY,
  //  DPDT Switches 
  input  [17:0]  SW,
  //  7-SEG Displays
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  //  LEDs
  output  [8:0]  LEDG,  //  LED Green[8:0]
  output  [17:0]  LEDR, //  LED Red[17:0]
  output [3:0] result,
  //  GPIO Connections
  inout  [35:0]  GPIO_0, GPIO_1
);
//  set all inout ports to tri-state
	assign  GPIO_0    =  36'hzzzzzzzzz;
	assign  GPIO_1    =  36'hzzzzzzzzz;

// Connect dip switches to red LEDs
	assign LEDR[17:0] = SW[17:0];
	assign LEDR[17]= SW[17];
	assign LEDR[16] = SW[16];
// turn off green LEDs
	assign LEDG[8:0] = 0;

	wire [15:0] A;
// map to 7-segment displays
	plus(A[3], A[2], A[1], A[0], result[3], result[2], result[1], result[0]);
	hex_7seg dsp0(result[3:0],HEX0);      // We are calling a module called hex_7seg
	wire [6:0] blank = ~7'h00; 
	assign HEX1 = blank;
	assign HEX2 = blank;
	assign HEX3 = blank;
// blank remaining digits
	assign HEX4 = blank;
	assign HEX5 = blank;
	assign HEX6 = blank;
	assign HEX7 = blank;


// control (set) value of A, signal with KEY3

//always @(negedge KEY[3])
//    A <= SW[15:0];
	assign A = SW[15:0];
endmodule