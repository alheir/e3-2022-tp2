`timescale 1 ns / 1 ps

//Inicio de Modulo

module BCDSubtractor (
	input wire [3:0] A,
	input wire [3:0] B,
	output wire [3:0] S,
	output wire Cout
);

/*	Variables	*/
wire [3:0]A0;
wire [3:0]B0;
wire [3:0]S0;
wire [3:0]A1;
wire [3:0]B1;
wire [3:0]S1;
wire [3:0]A2;
wire [3:0]B2;
wire [3:0]S2;
wire [3:0]A3;
wire [3:0]B3;
wire Cin0,Cin1,Cin2,Cin3;
wire C_ignore0,C_aux,C_ignore2,C_ignore3;
wire aux, sign;

/*	#1st Adder	*/
assign A0 = 4'b1010;
assign B0 = B ^ 4'b1111;
assign Cin0 = 1;

FourBitAdder Ad0 (.A (A0),
				 .B (B0),
				 .S (S0),
				 .Cin (Cin0));
				 //Cout Ignore
				 
/*	#2nd Adder	*/
assign A1 = A;
assign B1 = S0;
assign Cin1 = 0;

FourBitAdder Ad1 (.A (A1),
				 .B (B1),
				 .S (S1),
				 .Cin (Cin1),
				 .Cout (C_aux));
			 
				 
/*	#3rd Adder	*/
assign aux = (C_aux | (S1[3] & S1[2]) | (S1[3] & S1[1]));

assign A2[0] = 0;
assign A2[1] = aux;
assign A2[2] = aux;
assign A2[3] = 0;
assign B2 = S1;
assign Cin2 = 0;

FourBitAdder Ad2 (.A (A2),
				 .B (B2),
				 .S (S2),
				 .Cin (Cin2));
				 //Cout Ignore				 

/*	#4th Adder	*/
assign sign = ~aux;
assign A3[0] = 0;
assign A3[1] = sign;
assign A3[2] = 0;
assign A3[3] = sign;
assign B3[0] = S2[0] ^ sign;
assign B3[1] = S2[1] ^ sign;
assign B3[2] = S2[2] ^ sign;
assign B3[3] = S2[3] ^ sign;
assign Cin3 = aux;


FourBitAdder Ad3 (.A (A3),
				 .B (B3),
				 .S (S),
				 .Cin (Cin3));
				 //Cout Ignore
				 
/*	BCD Substract out's	*/
assign Cout = sign;

endmodule
