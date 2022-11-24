module bcd2bin
   (
    input [31:0] num; 
    output reg [23:0] bin
   );

   assign bin = (num[31:28] * 10'd10000000) + (num[27:24] * 10'd1000000) + (num[23:20] * 10'd100000) + (num[19:16] * 10'd10000) + (num[15:12] * 10'd1000) + (num[11:8] * 7'd100) + (num[7:4] * 4'd10) + num[6:3];

endmodule

module bin2bcd(
   input [23:0] bin,
   output reg [31:0] bcd
   );
   
integer i;
	
always @(bin) begin
    bcd=0;		 	
    for (i=0;i<24;i=i+1)
    begin					                                //Iterate once for each bit in input number
        if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;		    //If any BCD digit is >= 5, add three
	    if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
	    if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
	    if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
        if (bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 3;
        if (bcd[23:20] >= 5) bcd[23:20] = bcd[23:20] + 3;
        if (bcd[27:24] >= 5) bcd[27:24] = bcd[27:24] + 3;
        if (bcd[31:28] >= 5) bcd[30:28] = bcd[30:28] + 3;
	    bcd = {bcd[30:0],bin[23-i]};				        //Shift one bit, and shift in proper bit from input 
    end
end
endmodule

module(
    input clock,
    input sgn0,
    input num0 [31:0],
    input dp0 [3:0],
    input sgn1,
    input num1 [31:0],
    input dp1 [2:0],
    input operation [2:0],
    output result [31:0]
);

reg [23:0] bin0;
reg [23:0] bin1;
reg [23:0] res;

bcd2bin operand1 (.num(num0), .bin(bin0));
bcd2bin operand2 (.num(num1), .bin(bin1));

always @ (posedge clock)
begin
    case(operation)
        0: res = (bin0/(10**dp0) + bin1/(10**dp0));
        1: res = (bin0/(10**dp0) - bin1/(10**dp0));
        2: res = (bin0/(10**dp0) * bin1/(10**dp0));
        3: res = (bin0/(10**dp0) / bin1/(10**dp0));
        4: res = (bin0/(10**dp0) ** bin1/(10**dp0));
    endcase
end

bin2bcd result_mod (.bin(res), .bcd(result));

endmodule