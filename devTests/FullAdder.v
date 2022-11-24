`timescale 1 ns / 1 ps

//Inicio de modulo

module FullAdder (
	input wire A,
	input wire B,
	input wire Cin,
	output wire S,
	output wire Cout
);

assign S = (A ^ B) ^ Cin;
assign Cout = ((A ^ B) & Cin) | (A & B);

endmodule
