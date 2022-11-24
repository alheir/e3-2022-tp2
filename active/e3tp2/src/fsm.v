//-----------------------------------------------------------------------------
//
// Title       : fsm
// Design      : calc
// Author      : aheir
// Company     : aheir
//
//-----------------------------------------------------------------------------
//
// File        : F:\documents\alheir\e3-2022-tp2\active\e3tp2\src\fsm.v
// Generated   : Sun Oct 30 22:01:17 2022
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
//{module {fsm}}
module fsm #(parameter DIGIT_NUM=8) (
	input wire clock,
	input wire reset
);								 					   

parameter [2:0]			 
	LOADING_OP_0 = 2'b00,
	LOADING_OP_1 = 2'b01,  
	ALT_INPUT_OP0 = 2'b10,  
	ALT_INPUT_OP1 = 2'b11;

reg [1:0] curr_sta;
reg last_clock_keyrx;

wire [1:0] row_result;																  
wire valid_out;
wire row_result;
wire valid_out;
wire symbol_signal;
wire number_signal;
wire keytype;
wire [3:0] key;
wire [1:0] col_selector;		

reg [DIGIT_NUM*4:0] operand0;
reg operand0_sign;
reg [DIGIT_NUM*4:0] operand1;	
reg operand1_sign;
reg [2:0] operation;
reg [3:0] brightness;

parameter NUMBER=0,
		  SYMBOL=1;
		  
parameter [2:0]
	SUM_OP = 3'b000,
	SUB_OP = 3'b001,
	MUL_OP = 3'b010,
	DIV_OP = 3'b011,
	EXP_OP = 3'b100;

parameter [3:0]
	A_BUT = 4'hA,
	B_BUT = 4'hB,
	C_BUT = 4'hC,
	D_BUT = 4'hD,
	NUMERAL_BUT = 4'hE,
	FN_BUT = 4'hF;
	
keyboard keyboardMod(
	.clock(clock), 
	.reset(reset), 
	.row_result(row_result), 
	.valid_out(valid_out), 
	.symbol_signal(symbol_signal), 
	.number_signal(number_signal),
	.enable(enable),
	.keytype(keytype),
	.key(key),
	.col_selector(col_selector)
);

// alu aluMod();

always @ (posedge clock)
	if(reset) begin
		curr_sta <= LOADING_OP_0;	  
		last_clock_keyrx <= 0;
		operand0 <= 0;
		operand1 <= 0;
		operand0_sign <= 0;
		operand1_sign <= 0;
		brightness <= 0;
	end
	else begin
		if(~last_clock_keyrx and valid_out) begin // se recibio una nueva tecla
			last_clock_keyrx <= 1;
			if(keytype == NUMBER) begin // se recibio un numero
				case(curr_sta)
					LOADING_OP_0: begin
						operand0 = operand0 << 4;
						operand0[3:0] = key;
					end
					LOADING_OP_1: begin
						operand1 = operand1 << 4;
						operand1[3:0] = key;
					end
					ALT_INPUT_OP0, ALT_INPUT_OP1:
						if(key < 8)
							brightness <= key << 1;
				endcase

			end
			else begin
				if(key == FN_BUT) begin
					case(curr_sta)
						LOADING_OP_0: curr_sta => ALT_INPUT_OP0;
						LOADING_OP_1: curr_sta => ALT_INPUT_OP1;
						ALT_INPUT_OP0: curr_sta => LOADING_OP_0;
						ALT_INPUT_OP1: curr_sta => LOADING_OP_1;
					endcase
				end
				else if(key == NUMERAL_BUT) begin
					// decimal point?
				end
				else begin
					case(key)
					//TODO: ESTO ES HORRIBLE, SE DEBE PODER MEJORAR Y HACER PARA CUALQUIER OPERANDO
						A_BUT: begin
							if(curr_sta == LOADING_OP_0) begin
								if(operand0 != 0) begin
									operation <= SUM_OP; // suma
									curr_sta => LOADING_OP_1;
								end
								else operand0_sign <= ~operand0_sign;
							end
							else if(curr_sta == LOADING_OP_1) begin
								if(operand1 != 0) begin
									// OBTENER RESULTADO SUMA, PONER EN OPERANDO 0
									operand1 <= 0;
									operand1_sign <= 0;
								end
								else operand1_sign <= ~operand1_sign;
							end
						end
						B_BUT: begin
							if(curr_sta == LOADING_OP_0) begin
								if(operand0 != 0) begin
									operation <= SUB_OP; // suma
									curr_sta => LOADING_OP_1;
								end
								else operand0_sign <= ~operand0_sign;
							end
							else if(curr_sta == LOADING_OP_1) begin
								if(operand1 != 0) begin
									// OBTENER RESULTADO RESTA, PONER EN OPERANDO 0
									operand1 <= 0;
									operand1_sign <= 0;
								end
								else operand1_sign <= ~operand1_sign;
							end
						end
						C_BUT: begin
							operand0 <= 0;
							operand0_sign <= 0;
							operand1_sign <= 0;
							operand1 <= 0;
							curr_sta <= LOADING_OP_0;
						end
						D_BUT: begin
							operand1 <= 0;
							operand1_sign <= 0;
							curr_sta
						end; // igual?
					endcase
				end
			end
		end
		else if(~valid_out)
			last_clock_keyrx <= 0;
	end												



endmodule
