module hex_7seg(hex_digit,seg);
	input [3:0] hex_digit;
	output [6:0] seg;
	reg [6:0] seg;
// seg = {g,f,e,d,c,b,a};
// 0 is on and 1 is off
	always @ (hex_digit)
	case (hex_digit)
		  4'h0: seg = ~7'h3F;
		  4'h1: seg = ~7'h06;     //   ---a----
        4'h2: seg = ~7'h5B;     // |           |
        4'h3: seg = ~7'h4F;     // f          b
        4'h4: seg = ~7'h66;     // |           |
        4'h5: seg = ~7'h6D;     //  ---g----
        4'h6: seg = ~7'h7D;     // |           |
        4'h7: seg = ~7'h07;     // e          c
        4'h8: seg = ~7'h7F;     // |           |
        4'h9: seg = ~7'h67;     //   ---d----
		  4'hA: seg = ~7'h77;
		  4'hC: seg = ~7'h39;
		  4'hE: seg = ~7'h79;
		  4'hF: seg = ~7'h71;
        endcase
endmodule