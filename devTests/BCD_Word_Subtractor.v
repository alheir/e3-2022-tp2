`timescale 1 ns / 1 ps

//Inicio del modulo                                                 
module BCD_Word_Subtractor #(parameter DIGIT_NUM = 8) (
	input wire [4*DIGIT_NUM-1:0] A,
	input wire [4*DIGIT_NUM-1:0] B,
	input wire Cin,
	output wire [4*DIGIT_NUM-1:0] S,
	output wire Cout
);

wire [4*DIGIT_NUM-1:0] B_C9;
wire [4*DIGIT_NUM-1:0] A_aux;
wire [4*DIGIT_NUM-1:0] S_aux1;
wire [4*DIGIT_NUM-1:0] S_aux2;

wire Cout_aux;

parameter [3:0] C9 = 4'b1001;

//Cocmplemento a 9 de B
// BCDSubtractor bc9calc [DIGIT_NUM-1:0]  (.A(C9), .B(B), .S(B_C9));
// BCDSubtractor F0 (.A(C9[4*1-1 : 4*(1-1)]), .B(B[4*1-1 : 4*(1-1)]), .S(B_C9[4*1-1 : 4*(1-1)]));
// BCDSubtractor F1 (.A(C9[4*2-1 : 4*(2-1)]), .B(B[4*2-1 : 4*(2-1)]), .S(B_C9[4*2-1 : 4*(2-1)]));
// BCDSubtractor F2 (.A(C9[4*3-1 : 4*(3-1)]), .B(B[4*3-1 : 4*(3-1)]), .S(B_C9[4*3-1 : 4*(3-1)]));
// BCDSubtractor F3 (.A(C9[4*4-1 : 4*(4-1)]), .B(B[4*4-1 : 4*(4-1)]), .S(B_C9[4*4-1 : 4*(4-1)]));
// BCDSubtractor F4 (.A(C9[4*5-1 : 4*(5-1)]), .B(B[4*5-1 : 4*(5-1)]), .S(B_C9[4*5-1 : 4*(5-1)]));
// BCDSubtractor F5 (.A(C9[4*6-1 : 4*(6-1)]), .B(B[4*6-1 : 4*(6-1)]), .S(B_C9[4*6-1 : 4*(6-1)]));
// BCDSubtractor F6 (.A(C9[4*7-1 : 4*(7-1)]), .B(B[4*7-1 : 4*(7-1)]), .S(B_C9[4*7-1 : 4*(7-1)]));
// BCDSubtractor F7 (.A(C9[4*8-1 : 4*(8-1)]), .B(B[4*8-1 : 4*(8-1)]), .S(B_C9[4*8-1 : 4*(8-1)]));

//suma intermedia: A + B complemento a 9				 
BCD_Word_Adder F8	(.A (A),
				 .B (B_C9),
				 .S (A_aux),
				 .Cout (Cout_aux),
				 .Cin (1'b0) );				 

//Suma del carry , cuando es 1
BCD_Word_Adder F9	(.A (A_aux),
				 .B (Cout_aux),
				 .S (S_aux1),
				 .Cin (1'b0) );

//Complemento a 9 del A intermedio, cuando no hay carry
BCDSubtractor aauxc9calc [DIGIT_NUM-1:0]  (.A(C9), .B(A_aux), .S(S_aux2));

//Asignacion de salidas
assign S = Cout_aux ? S_aux1 : S_aux2;
assign Cout = ~ Cout_aux;


endmodule
