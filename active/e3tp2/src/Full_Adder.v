module Full_Adder ( A ,B ,Cin ,S ,Cout );

input A ;
wire A ;
input B ;
wire B ;
input Cin ;
wire Cin ;
output S ;
wire S ;
output Cout ;
wire Cout ; 

assign S = (A ^ B) ^ Cin;
assign Cout = ((A ^ B) & Cin) | (A & B);

endmodule