//-----------------------------------------------------------------------------
//
// Title       : \\BCD_Adder
// Design      : BCD_Adder
// Author      : fagrippino
// Company     : ITBA
//
//-----------------------------------------------------------------------------
//
// File        : c:\My_Designs\TP2_ALU\BCD_Adder\src\BCD_Adder.v
// Generated   : Sat Oct 29 14:05:53 2022
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

module BCDAdder (
	input wire [3:0] A,
	input wire [3:0] B,
	input wire Cin,
	output wire S,
	output wire Cout
);


wire [3:0] S_aux;
wire [3:0] B_aux;
wire C_aux;


FourBitAdder A0 (.A (A),
				 .B (B),
				 .S (S_aux),
				 .Cin (Cin),
				 .Cout (C_aux));

assign B_aux[0] = 0;
assign B_aux[1] = (C_aux | (S_aux[3] & S_aux[2]) | (S_aux[3] & S_aux[1]));
assign B_aux[2] = (C_aux | (S_aux[3] & S_aux[2]) | (S_aux[3] & S_aux[1]));
assign B_aux[3] = 0;
				 
FourBitAdder A1 (.A (S_aux),
				 .B (B_aux),
				 .S (S),
				 .Cin (0));

assign Cout = (C_aux | (S_aux[3] & S_aux[2]) | (S_aux[3] & S_aux[1]));
				 
endmodule
