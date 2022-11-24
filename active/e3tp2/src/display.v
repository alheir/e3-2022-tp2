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
	input clock,
    input reset,
	input latch, //to read or not to read, that is the question?
    input mode,  // 0: numbers, 1: codes
    input [2:0] dp,  // 111 -> DP en el MSD | 000 -> DP en el LSD
    input [3:0] codes, // C�digos hardcodados a definir. Para printear o hacer cosas ya definidas dentro�del�m�dulo	
	input [31:0] num
	);	 

reg ENM = 0;
reg ENL = 1;
	
always @ (posedge clock)
	if (latch)
		if (!mode)	ENM = 1;
	else
		ENL = 0;

num_mod num (ENM && ENL, num, dp, clock, reset);
codes_mod codes (~ENM && ENL, codes, clock, reset);

endmodule
