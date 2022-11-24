`timescale 1 ns / 1 ps

//Inicio de modulo
module FourBitAdder (
	input wire [3:0] A,
	input wire [3:0] B,
	input wire Cin,
	output wire [3:0] S,
	output wire Cout
);

wire [3:0] cout;
wire [3:0] cin = {cout[2:0], Cin};

FullAdder fadders [3:0] (.A(A), .B(B), .S(S), .Cout(cout), .Cin(cin));

assign Cout = cout[3];

endmodule
