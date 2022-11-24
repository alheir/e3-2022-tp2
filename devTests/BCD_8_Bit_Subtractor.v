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
module BCD_8_Bit_Subtractor ( A ,B ,S ,Cout ,Cin );

input [31:0] A ;
wire [31:0] A ;
input [31:0] B ;
wire [31:0] B ;
output [31:0] S ;
wire [31:0] S ;
output Cout ;
wire Cout ;
input Cin ;
wire Cin ;
//}}


wire [31:0] B_C9;
wire [31:0] A_aux;
wire [31:0] S_aux1;
wire [31:0] S_aux2;

wire Cout_aux;

parameter C9 = 4'b1001;

//COMPLEMENTO A 9 de B

BCD_Subtractor F0	(.A (C9),
				 .B ({B[3],B[0]}),
				 .S ({B_C9[3],B_C9[0]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F1	(.A (C9),
				 .B ({B[7],B[4]}),
				 .S ({B_C9[7],B_C9[4]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F2	(.A (C9),
				 .B ({B[11],B[8]}),
				 .S ({B_C9[11],B_C9[8]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F3	(.A (C9),
				 .B ({B[15],B[12]}),
				 .S ({B_C9[15],B_C9[12]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F4	(.A (C9),
				 .B ({B[19],B[16]}),
				 .S ({B_C9[19],B_C9[16]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F5	(.A (C9),
				 .B ({B[23],B[20]}),
				 .S ({B_C9[23],B_C9[20]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F6	(.A (C9),
				 .B ({B[27],B[24]}),
				 .S ({B_C9[27],B_C9[24]}),
				 //.Cout (),
				 .Cin (0) );
				 				 
BCD_Subtractor F7	(.A (C9),
				 .B ({B[31],B[28]}),
				 .S ({B_C9[31],B_C9[28]}),
				 //.Cout (),
				 .Cin (0) );

				 
//SUMA INTDERMEDIA: A + B complemento a 9				 
BCD_8_Bit_Adder F8	(.A (A),
				 .B (B_C9),
				 .S (A_aux),
				 .Cout (Cout_aux),
				 .Cin (0) );				 

//SUMA DEL CARRY
BCD_8_Bit_Adder F9	(.A (A_aux),
				 .B (Cout_aux),
				 .S (S_aux1),
				 //.Cout (),
				 .Cin (0) );

//COMPLEMENTO A 9 de A INTERMEDIA
BCD_Subtractor F10	(.A (C9),
				 .B ({A_aux[3],A_aux[0]}),
				 .S ({S_aux2[3],S_aux2[0]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F11	(.A (C9),
				 .B ({A_aux[7],A_aux[4]}),
				 .S ({S_aux2[7],S_aux2[4]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F12	(.A (C9),
				 .B ({A_aux[11],A_aux[8]}),
				 .S ({S_aux2[11],S_aux2[8]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F13	(.A (C9),
				 .B ({A_aux[15],A_aux[12]}),
				 .S ({S_aux2[15],S_aux2[12]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F14	(.A (C9),
				 .B ({A_aux[19],A_aux[16]}),
				 .S ({S_aux2[19],S_aux2[16]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F15	(.A (C9),
				 .B ({A_aux[23],A_aux[20]}),
				 .S ({S_aux2[23],S_aux2[20]}),
				 //.Cout (),
				 .Cin (0) );
				 
BCD_Subtractor F16	(.A (C9),
				 .B ({A_aux[27],A_aux[24]}),
				 .S ({S_aux2[27],S_aux2[24]}),
				 //.Cout (),
				 .Cin (0) );
				 				 
BCD_Subtractor F17	(.A (C9),
				 .B ({A_aux[31],A_aux[28]}),
				 .S ({S_aux2[31],S_aux2[28]}),
				 //.Cout (),
				 .Cin (0) );

//Asignacion de salidas
assign S = S_aux2;
assign Cout = Cout_aux;
				 
			 
	

				 

endmodule
