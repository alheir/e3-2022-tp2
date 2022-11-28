//-----------------------------------------------------------------------------
//
// Title       : keyboard
// Design      : calc
// Author      : aheir
// Company     : aheir
//
//-----------------------------------------------------------------------------
//
// File        : F:\documents\alheir\e3-2022-tp2\active\e3tp2\src\keyboard.v
// Generated   : Sun Oct 30 22:02:09 2022
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
//{module {keyboard}}
module keyboard (	
	input wire clock,		  
	input wire reset,					
	input wire [1:0] row_result,
	input wire valid_out,
	input wire symbol_signal,
	input wire number_signal,
	input wire enable,
	output reg keytype,	 
	output reg [3:0] key,
	output reg [1:0] col_selector,
	output reg valid_iteration
);
												
reg [1:0] acthi_col_selector;
reg row_detected;

parameter [3:0]
	ZERO_VAL = 4'd0,
	ONE_VAL = 4'd1,
	TWO_VAL = 4'd2,
	THREE_VAL = 4'd3,
	FOUR_VAL = 4'd4,
	FIVE_VAL = 4'd5,
	SIX_VAL = 4'd6,
	SEVEN_VAL = 4'd7,
	EIGHT_VAL = 4'd8,
	NINE_VAL = 4'd9,

	A_VAL = 4'hA,
	B_VAL = 4'hB,
	C_VAL = 4'hC,
	D_VAL = 4'hD,
	NUMERAL_VAL = 4'hE,
	ASTERISK_VAL = 4'hF;
	
parameter [1:0]
	ONE_ROW = 2'b11,
	TWO_ROW = 2'b11,
	THREE_ROW = 2'b11,
	A_ROW = 2'b11,

	FOUR_ROW = 2'b10,
	FIVE_ROW = 2'b10,
	SIX_ROW = 2'b10,
	B_ROW = 2'b10,

	SEVEN_ROW = 2'b01,
	EIGHT_ROW = 2'b01,
	NINE_ROW = 2'b01,
	C_ROW = 2'b01,

	ASTERISK_ROW = 2'b00,
	NUMERAL_ROW = 2'b00,
	ZERO_ROW = 2'b00,
	D_ROW = 2'b00;


always @ (posedge clock)
	// if(!reset) begin
	// 	acthi_col_selector <= 2'b00;
	// 	keytype <= 0;
	// 	key <= 0;
	// end
	// else
	acthi_col_selector <= acthi_col_selector + 1; // rota columnas
	if(acthi_col_selector <= 2'b00) valid_iteration <= 0;
	
always @ (negedge clock)
	if(reset) begin
		if(valid_out) begin
			valid_iteration <= 1;
			case(acthi_col_selector)
				2'b00:
					case(row_result)
						A_ROW: key <= A_VAL;
						B_ROW: key <= B_VAL;
						C_ROW: key <= C_VAL;
						D_ROW: key <= D_VAL;
					endcase
						
				2'b01:
					case(row_result)
						THREE_ROW: key <= THREE_VAL;
						SIX_ROW: key <= SIX_VAL;
						NINE_ROW: key <= NINE_VAL;
						NUMERAL_ROW: key <= NUMERAL_VAL;
					endcase

				2'b10:
					case(row_result)
						TWO_ROW: key <= TWO_VAL;
						FIVE_ROW: key <= FIVE_VAL;
						EIGHT_ROW: key <= EIGHT_VAL;
						ZERO_ROW: key <= ZERO_VAL;
					endcase

				2'b11:
					case(row_result)
						ONE_ROW: key <= ONE_VAL;
						FOUR_ROW: key <= FOUR_VAL;
						SEVEN_ROW: key <= SEVEN_VAL;
						ASTERISK_ROW: key <= ASTERISK_VAL;
					endcase
			endcase
		end
	end

assign keytype = key <= NINE_VAL;
assign col_selector = ~acthi_col_selector;
endmodule
