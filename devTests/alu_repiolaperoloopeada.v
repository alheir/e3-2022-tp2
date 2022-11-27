`timescale 1 ns / 1 ps

//Inicio de modulo
module alu #(parameter DIGIT_NUM = 8) (
    input wire [4*DIGIT_NUM-1:0] operand0,
    input wire operand0_sign,
    input wire [4*DIGIT_NUM-1:0] operand1,
    input wire operand1_sign,
    input wire [2:0] operation,
    output reg [4*DIGIT_NUM-1:0] result,
    output reg flag_ov,
    output reg flag_sign
);

    wire [1:0] signs_aux = {operand0_sign, operand1_sign};

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

    //wire [DIGIT_NUM-1:0] adder_cout;
    //wire [DIGIT_NUM-1:0] adder_cin = {adder_cout[DIGIT_NUM-2:0], 0};
    
    BCD_Word_Adder F0 (
        .A(operand0),
        .B(operand1),
        .S(result_adder),
        .Cout(Cout_adder),
        .Cin(0)
    );

    BCD_Word_Subtractor F1 (
        .A(operand0),
        .B(operand1),
        .S(result_subtraction),
        .Cout(Sign),
        .Cin(0)
    );

    always @(operand0, operand1, operand0_sign, operand1_sign, operation)
        case(operation)
            SUM: case(signs_aux)
                2'b00: begin //+ + +
                    result = result_adder;
                    Flag_aux_S = 0;
                    Flag_aux_OV = Cout_adder;
                end
                2'b01: begin // + + -
                    result = result_subtraction;
                    Flag_aux_S = Sign;
                    Flag_aux_OV = 0;
                end
                2'b10: begin // - + +
                    result = result_subtraction; // hago + - - pero con el signo invertido
                    Flag_aux_S = ~Sign;
                    Flag_aux_OV = 0;
                end
                2'b11: begin // - + -
                    result = result_adder; // sumo los modulos y pongo -
                    Flag_aux_S = 1;
                    Flag_aux_OV = Cout_adder;
                end
            endcase
            SUB: case(signs_aux)
                2'b00: begin //+ - +
                    result = result_subtraction;
                    Flag_aux_S = Sign;
                    Flag_aux_OV = 0;                
                end
                2'b01: begin // + - -
                    result = result_adder; // sumo los modulos y pongo +
                    Flag_aux_S = 0;
                    Flag_aux_OV = Cout_adder;
                end
                2'b10: begin // - - +
                    result = result_adder; // sumo los modulos y pongo -
                    Flag_aux_S = 1;
                    Flag_aux_OV = Cout_adder;
                end
                2'b11: begin // - - -
                    result = result_subtraction; // hago |A|-|B| y le cambio el signo
                    Flag_aux_S = ~Sign;
                    Flag_aux_OV = 0;
                end
            endcase
        endcase

    assign flag_sign = Flag_aux_S;
    assign flag_ov = Flag_aux_OV;


endmodule
