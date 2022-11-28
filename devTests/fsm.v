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

module fsm #(
    parameter DIGIT_NUM = 8
) (
    input wire clock,
    input wire reset,

    input wire [1:0] row_result,  //Q1 Q0
    input wire valid_out,  //OUT
    input wire symbol_signal,  //LED2
    input wire number_signal,  //LED1
    output wire [1:0] col_selector,  //D1 D0

    output reg led1,  //LEDD1
    output reg led2,  //LEDD2
    output reg led3,  //LEDD3
    output reg led4,  //LEDD4
    output reg led5,  //LEDD5
    output reg led6,  //LEDD6

    output wire max_sck,  //maxCLK
    output wire max_cs,   //maxCS
    output wire max_din   //maxDIN
);

    parameter [2:0]			 
	LOADING_OP_0 = 2'b00,
	LOADING_OP_1 = 2'b01,  
	ALT_INPUT_OP0 = 2'b10,  
	ALT_INPUT_OP1 = 2'b11;

    reg [1:0] curr_sta;
    reg [1:0] next_sta;
    reg last_clock_keyrx;

    parameter NUMBER = 1, SYMBOL = 0;

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

    parameter [3:0] BLANK = 4'hF;
    parameter [4*DIGIT_NUM-1:0] BLANK_NUM = DIGIT_NUM{BLANK};

    wire keytype;
    wire [3:0] key;
    reg [3:0] lastkey;
    wire valid_iteration;
    keyboard keyboardMod (
        .clock(clock),
        .reset(reset),
        .row_result(row_result),
        .valid_out(valid_out),
        .symbol_signal(symbol_signal),
        .number_signal(number_signal),
        .enable(0),
        .keytype(keytype),
        .key(key),
        .col_selector(col_selector),
        .valid_iteration(valid_iteration)
    );

    reg disp_latch;
    reg [2:0] dp_pos;
    reg [3:0] disp_codes;
    reg [3:0] brightness;
    reg [DIGIT_NUM*4-1:0] disp_num = curr_operand;

    display displayMod (
        .clock(clock),
        .reset(reset),
        .latch(disp_latch),  //to read or not to read, that is the question?
        .mode(disp_mode),  // 0: numbers, 1: codes
        .dp(dp_pos),  // 111 -> DP en el MSD | 000 -> DP en el LSD
        .code(disp_codes), // Cï¿½digos hardcodados a definir. Para printear o hacer cosas ya definidas dentroï¿½delï¿½mï¿½dulo	
        .num(disp_num),
        .brightness(brightness),
        .sck(max_sck),
        .din(max_din),
        .cs(max_cs),
        // .led_D5(led5)
    );

    reg [DIGIT_NUM*4-1:0] operand0;
    reg operand0_sign;
    reg operand0_dped;
    reg [DIGIT_NUM*4-1:0] operand1;
    reg operand1_sign;
    reg operand1_dped;

    wire [1:0] operands = {operand1, operand0};
    wire [1:0] operand_signs = {operand1_sign, operand0_sign};
    wire [1:0] operand_dps = {operand1_dp, operand0_dp};
    wire [1:0] operand_dpeds = {operand1_dped, operand0_dped};
    wire is_loading_operand = (curr_sta == LOADING_OP_0) || (curr_sta == LOADING_OP_1);
    wire curr_operand = (curr_sta == LOADING_OP_1) || (curr_sta == ALT_INPUT_OP1);

    reg [2:0] operation;
    wire [DIGIT_NUM*4-1:0] result;
    wire result_sign;
    wire [2:0] result_dp;
    wire flag_ov;
    reg [2:0] operand0_dp;
    reg [2:0] operand1_dp;
    alu aluMod (
        .operand0(operand0),
        .operand0_sign(operand0_sign),
        .operand0_dp(0),
        .operand1(operand1),
        .operand1_sign(operand1_sign),
        .operand1_dp(0),
        .operation(operation),
        .result(result),
        .result_sign(result_sign),
        .result_dp(result_dp)
    );

    always @(posedge clock)
        if (!reset) begin
            // active low reset sync
            curr_sta <= LOADING_OP_0;
            next_sta <= LOADING_OP_0;
            last_clock_keyrx <= 0;
            operands <= 2{BLANK_NUM};
            operand_signs <= 2{0};
            brightness <= 0;
            lastkey <= 0;
            operand_dps <= 2{0};
            operand_dpeds <= 2{0};
        end else begin
            curr_sta <= next_sta;
            if(~last_clock_keyrx && valid_iteration) begin // se recibio una nueva tecla (por lo menos 1clk sin presion valida)
                last_clock_keyrx <= 1;
                lastkey <= key;
                if (keytype == NUMBER) begin  // se recibio un numero
                    case (curr_sta)
                        LOADING_OP_0, LOADING_OP_1: begin
                            operands[curr_operand] = operands[curr_operand] << 4;
                            operands[curr_operand][3:0] = key;
                            if(operand_dpeds[curr_operand]) operand_dps[curr_operand] = operand_dps[curr_operand] + 1;
                        end
                        // LOADING_OP_0: begin
                        //     operand0 = operand0 << 4;
                        //     operand0[3:0] = key;
                        //     if(operand0_dped) operand0_dp = operand0_dp + 1;
                        // end
                        // LOADING_OP_1: begin
                        //     operand1 = operand1 << 4;
                        //     operand1[3:0] = key;
                        //     if(operand1_dped) operand1_dp = operand1_dp + 1;
                        // end
                        ALT_INPUT_OP0, ALT_INPUT_OP1: begin  // esta en menu alternativo
                            if (key < 8) begin
                                brightness <= key << 1; // multiplica por 2 el valor ingresado, entre 0 y 7
                            end
                        end
                    endcase
                end else begin
                    if (key == FN_BUT) begin
                        case (curr_sta)
                            LOADING_OP_0:  next_sta <= ALT_INPUT_OP0;
                            LOADING_OP_1:  next_sta <= ALT_INPUT_OP1;
                            ALT_INPUT_OP0: next_sta <= LOADING_OP_0;
                            ALT_INPUT_OP1: next_sta <= LOADING_OP_1;
                        endcase
                    end else if (key == NUMERAL_BUT) begin
                        if(LOADING_OP_0): begin
                            operand0_dped <= 1;
                            operand0_dp <= 0;
                        end else if(LOADING_OP_1): begin
                            operand1_dped <= 1;
                            operand1_dp <= 0;
                        end
                    end else if(key == A_BUT) begin
        //TODO: ESTO ES HORRIBLE, SE DEBE PODER MEJORAR Y HACER PARA CUALQUIER OPERANDO
                        if (curr_sta == LOADING_OP_0) begin
                            if (operand0 != 0) begin
                                operation <= SUM_OP;  // suma
                                next_sta  <= LOADING_OP_1;  //pasar a carga del siguiente
                            end else operand0_sign <= ~operand0_sign;
                            // MARCAR EL SIGNO DEL OPERANDO EN ALGUN LED
                        end else if (curr_sta == LOADING_OP_1) begin
                            if (operand1 != 0) begin
                                operand0 <= result;  // pasa resultado a op0
                                next_sta <= LOADING_OP_0; //muestra y permite modificar el resultado
                                operand1 <= 0;
                                operand1_sign <= 0;
                            end else operand1_sign <= ~operand1_sign;
                            // MARCAR EL SIGNO DEL OPERANDO EN ALGUN LED
                        end
                        // else if (curr_sta == ALT_INPUT_OP0) begin
                        //     if (operand0 != 0) begin
                        //         operation <= MUL_OP;  // producto
                        //         next_sta  <= LOADING_OP_1;
                        //     end else operand0_sign <= ~operand0_sign;
                        // end else if (curr_sta == ALT_INPUT_OP2) begin
                        //     if (operand1 != 0) begin
                        //         operand0 <= result;
                        //         next_sta <= LOADING_OP_0;
                        //         operand1 <= 0;
                        //         operand1_sign <= 0;
                        //     end else operand1_sign <= ~operand1_sign;
                        // end
                    end else if(key == B_BUT) begin
                        if (curr_sta == LOADING_OP_0) begin
                            if (operand0 != 0) begin
                                operation <= SUB_OP;  // resta
                                next_sta  <= LOADING_OP_1;
                            end else operand0_sign <= ~operand0_sign;
                        end else if (curr_sta == LOADING_OP_1) begin
                            if (operand1 != 0) begin
                                operand0 <= result;  // pasa resultado a op0
                                next_sta <= LOADING_OP_0; //muestra y permite modificar el resultado

                                operand1 <= 0;
                                operand1_sign <= 0;
                            end else operand1_sign <= ~operand1_sign;
                            // MARCAR EL SIGNO DEL OPERANDO EN ALGUN LED
                        end else if (curr_sta == ALT_INPUT_OP0) begin
                            if (operand0 != 0) begin
                                operation <= DIV_OP;  // cociente
                                next_sta  <= LOADING_OP_1;
                            end else operand0_sign <= ~operand0_sign;
                        end else if (curr_sta == ALT_INPUT_OP2) begin
                            if (operand1 != 0) begin
                                operand0 <= result;
                                next_sta <= LOADING_OP_0;
                                operand1 <= 0;
                                operand1_sign <= 0;
                            end else operand1_sign <= ~operand1_sign;
                        end
                    end else if(key == C_BUT) begin
                        case (curr_sta)
                            LOADING_OP_0: begin 
                                operand0 = {0, 0, 0, 0, operand0[4*DIGIT_NUM-1:4]};
                                operand0_dp <= operand0_dp - 1;
                            end
                            LOADING_OP_1: begin
                                operand1 = {0, 0, 0, 0, operand1[4*DIGIT_NUM-1:4]};
                                operand1_dp <= operand1_dp - 1;
                            end
                        endcase
                        // else if (curr_sta == ALT_INPUT_OP0) begin
                        //     if (operand0 != 0) begin
                        //         operation <= EXP_OP;  // potencia
                        //         next_sta  <= LOADING_OP_1;
                        //     end else operand0_sign <= ~operand0_sign;
                        // end else if (curr_sta == ALT_INPUT_OP2) begin
                        //     if (operand1 != 0) begin
                        //         operand0 <= result;
                        //         next_sta <= LOADING_OP_0;
                        //         operand1 <= 0;
                        //         operand1_sign <= 0;
                        //     end else operand1_sign <= ~operand1_sign;
                        // end

                    end else if(key == D_BUT) begin  // Igual
                        if (curr_sta <= LOADING_OP_1) begin
                            operand1 <= 0;
                            operand1_sign <= 0;
                            // obtener resultado operando, poner en op0
                            operand0 <= result;
                            operand0_sign <= result_sign;
                            next_sta <= LOADING_OP_0;
                        end
                    end
                end
            end else // if (valid_iteration && (lastkey != key)) begin
                last_clock_keyrx <= 0;
            // end
            // else if(~valid_iteration && !(symbol_signal || number_signal)) begin
            //     last_clock_keyrx <= 0;
            // end
        end
    // assign disp_num = (curr_sta == LOADING_OP_1) ? operand1 : ((curr_sta == LOADING_OP_0) ? operand0 : result);
    // assign disp_num[31:16] = operand1;
    // assign disp_num[15:0] = operand0;
    // assign disp_num = result;

    // assign led1 = operand0[0];
    // assign led6 = operand0[1];
    // assign led4 = operand0[2];
    // assign led3 = operand0[3];

    assign {led3, led4, led6, led1} = result[3:0];
    assign led5 = operand0_sign;
    assign led2 = operand1_sign;

    // assign led1 = curr_sta == LOADING_OP_0;
    // assign led6 = curr_sta == LOADING_OP_1;
    // assign led4 = curr_sta == ALT_INPUT_OP0;
    // assign led3 = curr_sta == ALT_INPUT_OP1;

    // assign led5 = operand1_sign;
endmodule

/* código para borrar */
// case (curr_sta)
//     LOADING_OP_0: operand0 = {0, 0, 0, 0, operand0[4*DIGIT_NUM-1:4]};
//     LOADING_OP_1: operand1 = {0, 0, 0, 0, operand1[4*DIGIT_NUM-1:4]};
// endcase

// if (curr_sta == LOADING_OP_0 || curr_sta == LOADING_OP_1) begin
//     operand0 <= 0;
//     operand0_sign <= 0;
//     operand1 <= 0;
//     operand1_sign <= 0;
//     next_sta <= LOADING_OP_0;
// end