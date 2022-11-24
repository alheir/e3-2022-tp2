//-----------------------------------------------------------------------------
//
// Title       : BCD_8_Bit_Substractor
// Design      : BCD_8_Bit_Substractor
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
module BCD_Word_Subtractor #(DIGIT_NUM = 8) (
	input wire [4*DIGIT_NUM-1:0] A,
	input wire [4*DIGIT_NUM-1:0] B,
	input wire Cin,
	output wire [4*DIGIT_NUM-1:0] S,
	output wire Cout
);

wire [31:0] B_C9;
wire [31:0] A_aux;
wire [31:0] S_aux1;
wire [31:0] S_aux2;

wire Cout_aux;

parameter C9 = 4'b1001;

//COMPLEMENTO A 9 de B
BCDSubtractor [DIGIT_NUM-1:0] bc9calc (.A(C9), .B(B), .S(B_C9), .Cin(0));
				 
//SUMA INTDERMEDIA: A + B complemento a 9				 
BCD_Word_Adder F8	(.A (A),
				 .B (B_C9),
				 .S (A_aux),
				 .Cout (Cout_aux),
				 .Cin (0) );				 

//SUMA DEL CARRY
BCD_Word_Adder F9	(.A (A_aux),
				 .B (Cout_aux),
				 .S (S_aux1),
				 .Cin (0) );

//COMPLEMENTO A 9 de A INTERMEDIA
BCDSubtractor [DIGIT_NUM-1:0] aauxc9calc (.A(C9), .B(A_aux), .S(S_aux2), .Cin(0));

//Asignacion de salidas
assign S = S_aux2;
assign Cout = Cout_aux;


endmodule
