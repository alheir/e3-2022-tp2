module BCD_8_Bit_Adder ( A ,B ,S ,Cout ,Cin );

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

wire Cin1,Cin2,Cin3,Cin4,Cin5,Cin6,Cin7;

\\BCD_Adder F0	(.A ({A[3],A[0]}),
				 .B ({B[3],B[0]}),
				 .S ({S[3],S[0]}),
				 .Cout (Cin1),
				 .Cin (Cin) );

\\BCD_Adder F1	(.A ({A[7],A[4]}),
				 .B ({B[7],B[4]}),
				 .S ({S[7],S[4]}),
				 .Cout (Cin2),
				 .Cin (Cin1) );
			 
\\BCD_Adder F2	(.A ({A[11],A[8]}),
				 .B ({B[11],B[8]}),
				 .S ({S[11],S[8]}),
				 .Cout (Cin3),
				 .Cin (Cin2) );
				 
\\BCD_Adder F3	(.A ({A[15],A[12]}),
				 .B ({B[15],B[12]}),
				 .S ({S[15],S[12]}),
				 .Cout (Cin4),
				 .Cin (Cin3) );
				 
\\BCD_Adder F4	(.A ({A[19],A[16]}),
				 .B ({B[19],B[16]}),
				 .S ({S[19],S[16]}),
				 .Cout (Cin5),
				 .Cin (Cin4) );
				 
\\BCD_Adder F5	(.A ({A[23],A[20]}),
				 .B ({B[23],B[20]}),
				 .S ({S[23],S[20]}),
				 .Cout (Cin6),
				 .Cin (Cin5) );
				 
\\BCD_Adder F6	(.A ({A[27],A[24]}),
				 .B ({B[27],B[24]}),
				 .S ({S[27],S[24]}),
				 .Cout (Cin7),
				 .Cin (Cin6) );
				 
\\BCD_Adder F7	(.A ({A[31],A[28]}),
				 .B ({B[31],B[28]}),
				 .S ({S[31],S[28]}),
				 .Cout (Cout),
				 .Cin (Cin7) );
endmodule