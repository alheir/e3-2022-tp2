`timescale 1 ns / 1 ps

//Inicio de modulo
module BCDAdder (
	input wire [3:0] A,
	input wire [3:0] B,
	input wire Cin,
	output wire [3:0] S,
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
