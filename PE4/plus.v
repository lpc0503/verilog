module plus(A, B, C, D, X, Y, Z, W);

	input A, B, C, D;
	output X, Y, Z, W;
	
	assign X = A&B&C&D;
	assign Y = (A&~B&C) | (A&C&~D);
	assign Z = (A&~C&D) | (A&~B&D) | (~A&B&C) | (B&C&~D);
	assign W = (~A&B&D) | (B&C&D);
	
endmodule