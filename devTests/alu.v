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
module ALU (
    A,
    B,
    S_a,
    S_b,
    OP,
    S,
    Flag_OV,
    Flag_S
);

    input wire [31:0] A;
    input wire [31:0] B;
    input wire S_a;
    input wire S_b;
    input wire OP;
    output wire [31:0] S;
    output wire Flag_OV;
    output wire Flag_S;

    wire OP_aux = {OP, S_a, S_b};

    parameter [2:0] E0 = 3'b000;
    parameter [2:0] E1 = 3'b001;
    parameter [2:0] E2 = 3'b010;
    parameter [2:0] E3 = 3'b011;
    parameter [2:0] E4 = 3'b100;
    parameter [2:0] E5 = 3'b101;
    parameter [2:0] E6 = 3'b110;
    parameter [2:0] E7 = 3'b111;


    reg [31:0] S_adder;
    reg [31:0] S_substr;
    reg [31:0] S_aux;
    reg Cout_adder, Sign;
    reg Flag_aux_S, Flag_aux_OV;

    BCD_8_Bit_Adder F0 (
        .A(A),
        .B(B),
        .S(S_adder),
        .Cout(Cout_adder),
        .Cin(0)
    );

    BCD_8_Bit_Subtractor F1 (
        .A(A),
        .B(B),
        .S(S_substr),
        .Cout(Sign),
        .Cin(0)
    );



    always @(A, B, S_a, S_b, OP)
        case (OP_aux)
            E0: begin
                S_aux = S_adder;
                Flag_aux_S = 0;
                Flag_aux_OV = Cout_adder;
            end

            E1: begin
                S_aux = S_substr;
                Flag_aux_S = Sign;
                Flag_aux_OV = 0;
            end

            E2: begin
                S_aux = S_substr;
                Flag_aux_S = ~S;
                Flag_aux_OV = 0;
            end

            E3: begin
                S_aux = S_adder;
                Flag_aux_S = 1;
                Flag_aux_OV = Cout_adder;
            end

            E4: begin
                S_aux = S_substr;
                Flag_aux_S = Sign;
                Flag_aux_OV = 0;
            end

            E5: begin
                S_aux = S_adder;
                Flag_aux_S = 0;
                Flag_aux_OV = Cout_adder;
            end

            E6: begin
                S_aux = S_adder;
                Flag_aux_S = 1;
                Flag_aux_OV = Cout_adder;
            end

            E7: begin
                S_aux = S_substr;
                Flag_aux_S = ~S;
                Flag_aux_OV = 0;
            end
        endcase

    assign S = S_aux;
    assign Flag_S = Flag_aux_S;
    assign Flag_OV = Flag_aux_OV;


endmodule
