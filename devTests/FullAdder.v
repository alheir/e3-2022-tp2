//-----------------------------------------------------------------------------
//
// Title       : Full_Adder
// Design      : BCD_Adder
// Author      : fagrippino
// Company     : ITBA
//
//-----------------------------------------------------------------------------
//
// File        : c:\My_Designs\TP2_ALU\BCD_Adder\src\Full_Adder.v
// Generated   : Sat Oct 29 14:18:44 2022
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
//   and may be overwritten
//{module {Full_Adder}}
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
