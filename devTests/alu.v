//-----------------------------------------------------------------------------
//
// Title       : ALU
// Design      : BCD_Adder
// Author      : fagrippino
// Company     : ITBA
//
//-----------------------------------------------------------------------------
//
// File        : C:\My_Designs\TP2_ALU\BCD_Adder\src\ALU.v
// Generated   : Thu Nov 24 02:31:41 2022
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
//{module {ALU}}
module ALU #(DIGIT_NUM = 8) (
    input wire [4*DIGIT_NUM-1:0] operand0,
    input wire operand0_sign,
    input wire [4*DIGIT_NUM-1:0] operand1,
    input wire operand1_sign,
    input wire [2:0] operation,
    output reg [4*DIGIT_NUM-1:0] result,
    output reg result_sign
    output reg flag_ov,
    output reg flag_sign
);

    wire [1:0] signs_aux = {S_a, S_b};

    parameter [2:0]
        SUM = 3'b000,
        SUB = 3'b001,
        MUL = 3'b010,
        DIV = 3'b011,
        EXP = 3'b100;
        
    reg [4*DIGIT_NUM-1:0] result_adder;
    reg [4*DIGIT_NUM-1:0] result_subtraction;
    reg Cout_adder, Sign;
    reg Flag_aux_S, Flag_aux_OV;

    wire [DIGIT_NUM-1:0] adder_cout;
    wire [DIGIT_NUM-1:0] adder_cin = {adder_cout[DIGIT_NUM-2:0], 0};
    BCD_Adder [DIGIT_NUM-1:0] adders(.A(operand0), .B(operand1),)
    BCD_8_Bit_Adder F0 (
        .A(operand0),
        .B(operand1),
        .S(result_adder),
        .Cout(Cout_adder),
        .Cin(0)
    );

    BCD_8_Bit_Subtractor F1 (
        .A(operand0),
        .B(operand1),
        .S(S_substr),
        .Cout(Sign),
        .Cin(0)
    );

    always @(operand0, operand1, operand0_sign, operand1_sign, operation)
        case(operation)
            SUM: case(signs_aux)
                2'b00: begin //+ + +
                    result = S_adder;
                    Flag_aux_S = 0;
                    Flag_aux_OV = Cout_adder;
                end
                2'b01: begin // + + -
                    result = S_substr;
                    Flag_aux_S = Sign;
                    Flag_aux_OV = 0;
                end
                2'b10: begin // - + +
                    result = S_substr; // hago + - - pero con el signo invertido
                    Flag_aux_S = ~Sign;
                    Flag_aux_OV = 0;
                end
                2'b11: begin // - + -
                    result = S_adder; // sumo los modulos y pongo -
                    Flag_aux_S = 1;
                    Flag_aux_OV = Cout_adder;
                end
            endcase
            SUB: case(signs_aux)
                2'b00: begin //+ - +
                    result = S_substr;
                    Flag_aux_S = Sign;
                    Flag_aux_OV = 0;                
                end
                2'b01: begin // + - -
                    result = S_adder; // sumo los modulos y pongo +
                    Flag_aux_S = 0;
                    Flag_aux_OV = Cout_adder;
                end
                2'b10: begin // - - +
                    result = S_adder; // sumo los modulos y pongo -
                    Flag_aux_S = 1;
                    Flag_aux_OV = Cout_adder;
                end
                2'b11: begin // - - -
                    result = S_substr; // hago |A|-|B| y le cambio el signo
                    Flag_aux_S = ~Sign;
                    Flag_aux_OV = 0;
                end
            endcase
        endcase

    assign Flag_S = Flag_aux_S;
    assign Flag_OV = Flag_aux_OV;


endmodule
