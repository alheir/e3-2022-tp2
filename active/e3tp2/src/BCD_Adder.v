module \\BCD_Adder ( A ,B ,Cin ,S, Cout);

input [3:0] A ;
wire [3:0] A ;
input [3:0] B ;
wire [3:0] B ;
input Cin ;
wire Cin ;
output [3:0] S ;
wire [3:0] S ;
output Cout ;
wire Cout ;
//}}

wire [3:0] S_aux;
wire [3:0] B_aux;
wire C_aux;
wire C_ignore;


\\4-Bit_Adder A0 (.A (A),
				 .B (B),
				 .S (S_aux),
				 .Cin (Cin),
				 .Cout (C_aux));

assign B_aux[0] = 0;
assign B_aux[1] = (C_aux | (S_aux[3] & S_aux[2]) | (S_aux[3] & S_aux[1]));
assign B_aux[2] = (C_aux | (S_aux[3] & S_aux[2]) | (S_aux[3] & S_aux[1]));
assign B_aux[3] = 0;
				 
\\4-Bit_Adder A1 (.A (S_aux),
				 .B (B_aux),
				 .S (S),
				 .Cin (0));
				 //Cout Ignore

assign Cout = (C_aux | (S_aux[3] & S_aux[2]) | (S_aux[3] & S_aux[1]));
				 
endmodule