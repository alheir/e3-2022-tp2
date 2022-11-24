`timescale 1 ns / 1 ps

//Inicio de modulo                                                
module BCD_Word_Adder #(parameter DIGIT_NUM = 8) (
	input wire [4*DIGIT_NUM-1:0] A,
	input wire [4*DIGIT_NUM-1:0] B,
	input wire Cin,
	output wire [4*DIGIT_NUM-1:0] S,
	output wire Cout
);

wire [DIGIT_NUM-1:0] cout;
wire [DIGIT_NUM-1:0] cin = {cout[DIGIT_NUM-1:1], Cin};

BCDAdder F0 (.A(A[4*1-1 : 4*(1-1)]), .B(B[4*1-1 : 4*(1-1)]), .S(S[4*1-1 : 4*(1-1)]), .Cout(cout[0]), .Cin(cin[0]) );
BCDAdder F1 (.A(A[4*2-1 : 4*(2-1)]), .B(B[4*2-1 : 4*(2-1)]), .S(S[4*2-1 : 4*(2-1)]), .Cout(cout[1]), .Cin(cin[1]) );
BCDAdder F2 (.A(A[4*3-1 : 4*(3-1)]), .B(B[4*3-1 : 4*(3-1)]), .S(S[4*3-1 : 4*(3-1)]), .Cout(cout[2]), .Cin(cin[2]) );
BCDAdder F3 (.A(A[4*4-1 : 4*(4-1)]), .B(B[4*4-1 : 4*(4-1)]), .S(S[4*4-1 : 4*(4-1)]), .Cout(cout[3]), .Cin(cin[3]) );
BCDAdder F4 (.A(A[4*5-1 : 4*(5-1)]), .B(B[4*5-1 : 4*(5-1)]), .S(S[4*5-1 : 4*(5-1)]), .Cout(cout[4]), .Cin(cin[4]) );
BCDAdder F5 (.A(A[4*6-1 : 4*(6-1)]), .B(B[4*6-1 : 4*(6-1)]), .S(S[4*6-1 : 4*(6-1)]), .Cout(cout[5]), .Cin(cin[5]) );
BCDAdder F6 (.A(A[4*7-1 : 4*(7-1)]), .B(B[4*7-1 : 4*(7-1)]), .S(S[4*7-1 : 4*(7-1)]), .Cout(cout[6]), .Cin(cin[6]) );
BCDAdder F7 (.A(A[4*8-1 : 4*(8-1)]), .B(B[4*8-1 : 4*(8-1)]), .S(S[4*8-1 : 4*(8-1)]), .Cout(cout[7]), .Cin(cin[7]) );


// BCDAdder bcdadders[DIGIT_NUM-1:0]; // (.A(A), .B(B), .S(S), .Cout(cout), .Cin(cin));
// for (i = 0; i < DIGIT_NUM; i = i + 1) begin
// 	BCDAdder bcdadders[i] (.A(A[i*4 - 1: i*4]), .B(B[i*4 - 1: i*4]), .S(S[i*4 - 1: i*4]), .Cout(cout[i]), .Cin(cin[i]));
// end
assign Cout = cout[DIGIT_NUM-1];

endmodule
