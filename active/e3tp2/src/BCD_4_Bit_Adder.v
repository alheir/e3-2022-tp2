module \\4-Bit_Adder ( A ,B ,S ,Cout ,Cin );

input [3:0] A ;
wire [3:0] A ;
input [3:0] B ;
wire [3:0] B ;
output [3:0] S ;
wire [3:0] S ;
output Cout ;
wire Cout ;
input Cin ;
wire Cin ;

wire Cin1,Cin2,Cin3;

Full_Adder F0	(.A (A[0]),
				 .B (B[0]),
				 .S (S[0]),
				 .Cout (Cin1),
				 .Cin (Cin) );

Full_Adder F1	(.A (A[1]),
				 .B (B[1]),
				 .S (S[1]),
				 .Cout (Cin2),
				 .Cin (Cin1) );
			 
Full_Adder F2	(.A (A[2]),
				 .B (B[2]),
				 .S (S[2]),
				 .Cout (Cin3),
				 .Cin (Cin2) );
				 
Full_Adder F3	(.A (A[3]),
				 .B (B[3]),
				 .S (S[3]),
				 .Cout (Cout),
				 .Cin (Cin3) );				 
endmodule