//-----------------------------------------------------------------------------
//
// Title       : \\4-Bit_Adder
// Design      : BCD_Adder
// Author      : fagrippino
// Company     : ITBA
//
//-----------------------------------------------------------------------------
//
// File        : c:\My_Designs\TP2_ALU\BCD_Adder\src\4-Bit Adder.v
// Generated   : Sat Oct 29 14:32:52 2022
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

module FourBitAdder (
	input wire [3:0] A,
	input wire [3:0] B,
	input wire Cin,
	output wire [3:0] S,
	output wire Cout
);

wire [3:0] cout;
wire [3:0] cin = {cout[2:0], Cin};

FullAdder [3:0] fadders ( .A(A), .B(B), .Cout(cout), .Cin(cin));

assign Cout = cout[3];

endmodule
