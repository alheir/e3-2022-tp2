//-----------------------------------------------------------------------------
//
// Title       : BCD_8_Bit_Adder
// Design      : BCD_8_Bit_Adder
// Author      : fagrippino
// Company     : ITBA
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
	//   and may be overwritten                                                 
module BCD_Word_Adder #(DIGIT_NUM = 8) (
	input wire [4*DIGIT_NUM-1:0] A,
	input wire [4*DIGIT_NUM-1:0] B,
	input wire Cin,
	output wire [4*DIGIT_NUM-1:0] S,
	output wire Cout
);

wire [DIGIT_NUM-1:0] cout;
wire [DIGIT_NUM-1:0] cin = {cout[DIGIT_NUM-2:0], Cin};


BCDAdder [DIGIT_NUM-1:0] bcdadders (.A(A), .B(B), .S(S), .Cout(cout), .Cin(cin));

assign Cout = cout[DIGIT_NUM-1];

endmodule
