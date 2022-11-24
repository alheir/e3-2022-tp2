//-----------------------------------------------------------------------------
//
// Title       : display
// Design      : calc
// Author      : aheir
// Company     : aheir
//
//-----------------------------------------------------------------------------
//
// File        : F:\documents\alheir\e3-2022-tp2\active\e3tp2\src\display.v
// Generated   : Sun Oct 30 22:01:08 2022
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
//   and may be overwritten
//{module {display}}

module display (
	input clk,
    input rst,
    input mode,  // 0: numbers, 1: codes
    input [2:0] dp,  // 111 -> DP en el MSD | 000 -> DP en el LSD
    input [3:0] code, // C�digos hardcodados a definir. Para printear o hacer cosas ya definidas dentro�del�m�dulo	
	input [31:0] num
	);	 

reg EN_num = 0;
reg EN_code = 0;
reg [3:0] code_reg = 0;
reg	[31:0] num_reg = 0;
	
always @ (posedge clk)
	begin
		if (mode)
			begin
				if (num_reg == num)	EN_num = 0;
				else
					begin
						EN_num = 1;
						num_reg = num;
					end
			end
		else
			begin
				if (code_reg == code) EN_code = 0;
				else 
					begin
						EN_code = 1;
						code_reg = code;
					end
			end
	end

num_mod num_mod (EN_num, num, dp, clk, rst);
code_mod code_mod (EN = EN_code, code = code, clk = clk, rst = rst);

endmodule

module code_mod (
	input EN,
	input code,
	input clk,
	input rst);

parameter	BRIGHT_1 = 0,
			BRIGHT_2 = 1,
			BRIGHT_3 = 2,
			BRIGHT_4 = 3,
			HOLA = 4,
			CHAU = 5;
			
endmodule