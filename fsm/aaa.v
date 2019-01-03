module aaa(
   input CLOCK_50,
   input [3:0] KEY,
   input [17:0] SW,
   output [8:0] LEDG,
   output [17:0] LEDR,
   output reg [6:0] HEX0, HEX1, HEX2, HEX3, 
   output [6:0] HEX4, HEX5, HEX6, HEX7,
   inout [35:0] GPIO_0, GPIO_1
);
   assign GPIO_0 = 36'hzzzzzzzzz;
   assign GPIO_1 = 36'hzzzzzzzzz;
   assign LEDR = SW;
   FSM1101or1100(SW[0], KEY[0], KEY[1], LEDG[0]);
   always@(posedge KEY[0], negedge KEY[1])
   begin
      if(~KEY[1])
      begin
         HEX0 <= ~7'h00;
         HEX1 <= ~7'h00;
         HEX2 <= ~7'h00;
         HEX3 <= ~7'h00;
      end
      else
      begin
         HEX3 = HEX2;
         HEX2 = HEX1;
         HEX1 = HEX0;
         if(SW[0])
            HEX0 = ~7'h06;
         else
            HEX0 = ~7'h3f;
      end
   end
   assign HEX4 = ~7'h00; 
   assign HEX5 = ~7'h00;
   assign HEX6 = ~7'h00;
   assign HEX7 = ~7'h00;
endmodule

module FSM1101or1100(
   input inp, 
   input clock, 
   input reset, 
   output reg outp
);
   reg [2:0]state;

   initial
      state = 3'h0;
   always@(posedge clock, negedge reset)
   begin
      if(~reset)
         state = 0;
      else
      begin
         case(state)
         3'h0:
         begin
            if(inp)
               state = 3'h0;
				else
					state = 3'h1;
         end
         3'h1:
         begin
            if(inp)
               state = 3'h0;
            else
               state = 3'h2;
         end
         3'h2:
         begin
            if(~inp)
               state = 3'h1;
				else
					state = 3'h3;
         end
         3'h3:
         begin
            if(inp)
               state = 3'h3;
            else
               state = 3'h4;
         end
         3'h4:
         begin
            if(inp)
               state = 3'h5;
            else
               state = 3'h6;
         end
         3'h5:
         begin
            if(inp)
               state = 3'h3;
            else
               state = 3'h7;
         end
			3'h6:
			begin
				if(inp)
					state = 3'h3;
				else
					state = 3'h6;
			end
			3'h7:
			begin
				if(inp)
					state = 3'h6;
				else
					state = 3'h3;
			end
			endcase
      end
   end
   always@(*)
   begin
      if(~reset)
         outp = 0;
      else
      begin
         case(state)
         3'h0, 3'h1, 3'h2, 3'h3, 3'h4, 3'h5, 3'h6:
            outp = 0;
         3'h7:
            outp = 1;
			endcase
      end
   end
endmodule
