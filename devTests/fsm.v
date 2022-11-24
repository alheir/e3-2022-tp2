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

    output reg max_sck,   //maxCLK
    output reg max_load,  //maxLOAD
    output reg max_din,   //maxDIN

    output reg pin_LED_D1,  //LEDD1
    output reg pin_LED_D2,  //LEDD2
    output reg pin_LED_D3,  //LEDD3
    output reg pin_LED_D4,  //LEDD4
    output reg pin_LED_D5,  //LEDD5
    output reg pin_LED_D6,  //LEDD6

    input wire pin_SW1,   //SW1
    input wire pin_SW2,   //SW2
    input wire pin_SW3,   //SW3
    input wire pin_SW4,   //SW4

    output wire led_green,
    output wire led_blue,
    output wire led_red
);

    reg [1:0] curr_sta;
    reg last_clock_keyrx;

    reg [DIGIT_NUM*4-1:0] operand0;
    reg operand0_sign;
    reg [DIGIT_NUM*4-1:0] operand1;
    reg operand1_sign;
    reg [2:0] operation;
    reg [3:0] brightness;
	reg [3:0] key;
	reg keytype;

    parameter [2:0]			 
	LOADING_OP_0 = 2'b00,
	LOADING_OP_1 = 2'b01,  
	ALT_INPUT_OP0 = 2'b10,  
	ALT_INPUT_OP1 = 2'b11;

    parameter NUMBER = 0, SYMBOL = 1;

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
	
    keyboard keyboardMod (
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

    reg disp_latch;
    reg [2:0] dp_pos;
    reg [3:0] disp_codes;
    reg [DIGIT_NUM*4-1:0] disp_num;

    display displayMod (
        .clock(clock),
        .reset(reset),
        .latch(disp_latch),  //to read or not to read, that is the question?
        .mode(disp_mode),  // 0: numbers, 1: codes
        .dp(dp_pos),  // 111 -> DP en el MSD | 000 -> DP en el LSD
        .codes(disp_codes), // Cï¿½digos hardcodados a definir. Para printear o hacer cosas ya definidas dentroï¿½delï¿½mï¿½dulo	
        .num(disp_num),
        .brightness(brightness),

        .sck (max_sck),
        .din (max_din),
        .load(max_load)
    );


    // alu aluMod (
    //     .A(),
    //     .B(),
    //     .S_a(),
    //     .S_b(),
    //     .OP(),
    //     .S(),
    //     .Flag_OV(),
    //     .Flag_S()
    // );

    always @(posedge clock)
        if (!reset) begin
            // reset async
            curr_sta <= LOADING_OP_0;
            last_clock_keyrx <= 0;
            operand0 <= 0;
            operand1 <= 0;
            operand0_sign <= 0;
            operand1_sign <= 0;
            brightness <= 7;
        end else begin
            if(~last_clock_keyrx && valid_out) begin // se recibio una nueva tecla (por lo menos 1clk sin presion valida)
                last_clock_keyrx <= 1;
                if (keytype == NUMBER) begin  // se recibio un numero
                    case (curr_sta)
                        LOADING_OP_0: begin
                            operand0 = operand0 << 4;
                            operand0[3:0] = key;
                        end
                        LOADING_OP_1: begin
                            operand1 = operand1 << 4;
                            operand1[3:0] = key;
                        end
                        ALT_INPUT_OP0, ALT_INPUT_OP1:  // esta en menu alternativo
                        if (key < 8)
                            brightness <= key << 1; // multiplica por 2 el valor ingresado, entre 0 y 7 
                    endcase

                end else begin
                    if (key == FN_BUT) begin
                        case (curr_sta)
                            LOADING_OP_0:  curr_sta <= ALT_INPUT_OP0;
                            LOADING_OP_1:  curr_sta <= ALT_INPUT_OP1;
                            ALT_INPUT_OP0: curr_sta <= LOADING_OP_0;
                            ALT_INPUT_OP1: curr_sta <= LOADING_OP_1;
                        endcase
                    end else if (key == NUMERAL_BUT) begin
                        // decimal point?
                    end else begin
                        case (key)
                            //TODO: ESTO ES HORRIBLE, SE DEBE PODER MEJORAR Y HACER PARA CUALQUIER OPERANDO
                            A_BUT: begin
                                if (curr_sta == LOADING_OP_0) begin
                                    if (operand0 != 0) begin
                                        operation <= SUM_OP;  // suma
                                        curr_sta  <= LOADING_OP_1;
                                    end else operand0_sign <= ~operand0_sign;
                                    // MARCAR EL SIGNO DEL OPERANDO EN ALGUN LED
                                end else if (curr_sta == LOADING_OP_1) begin
                                    if (operand1 != 0) begin
                                        // OBTENER RESULTADO SUMA, PONER EN OPERANDO 0
                                        operand1 <= 0;
                                        operand1_sign <= 0;
                                    end else operand1_sign <= ~operand1_sign;
                                    // MARCAR EL SIGNO DEL OPERANDO EN ALGUN LED
                                end
                            end
                            B_BUT: begin
                                if (curr_sta == LOADING_OP_0) begin
                                    if (operand0 != 0) begin
                                        operation <= SUB_OP;  // resta
                                        curr_sta  <= LOADING_OP_1;
                                    end else operand0_sign <= ~operand0_sign;
                                end else if (curr_sta == LOADING_OP_1) begin
                                    if (operand1 != 0) begin
                                        // OBTENER RESULTADO RESTA, PONER EN OPERANDO 0
                                        operand1 <= 0;
                                        operand1_sign <= 0;
                                    end else operand1_sign <= ~operand1_sign;
                                    // MARCAR EL SIGNO DEL OPERANDO EN ALGUN LED
                                end
                            end
                            C_BUT: begin  // Clear
                                operand0 <= 0;
                                operand0_sign <= 0;
                                operand1_sign <= 0;
                                operand1 <= 0;
                                curr_sta <= LOADING_OP_0;
                            end
                            D_BUT: begin  // Igual
                                if (curr_sta <= LOADING_OP_1) begin
                                    operand1 <= 0;
                                    operand1_sign <= 0;
                                    // obtener resultado operando, poner en op0
                                    curr_sta <= LOADING_OP_0;
                                end
                            end
                        endcase
                    end
                end
            end else if (~valid_out) last_clock_keyrx <= 0;
        end
    // assign disp_num = (curr_sta == LOADING_OP_1) ? operand1 : ((curr_sta == LOADING_OP_0) ? operand0 : 0);
    assign disp_num = 31'h12341234;
    // assign pin_LED_D1 = !((key == 4'd8) && valid_out);
    

    // assign pin_LED_D6 = (key == 4'd0);


    // always @(posedge valid_out) begin
    //     if(key == 0) begin
    //         led_green <= 0;
    //         leg_blue <= 0;
    //         led_red <= 0;
    //     end
    //     else begin
    //         led_green <= 1;
    //         leg_blue <= 1;
    //         led_red <= 1;
    //     end

    // end

    // assign led_green = ~(key == 4'd1);
    // assign led_blue = ~(key == 4'd2);
    // assign led_red = ~(key == 4'd3);




    // assign {pin_LED_D1, pin_LED_D2, pin_LED_D3, pin_LED_D4} = (key & (valid_out);

    assign pin_LED_D1 = key[0];
    assign pin_LED_D6 = key[1];
    assign pin_LED_D4 = key[2];
    assign pin_LED_D3 = key[3];

endmodule
