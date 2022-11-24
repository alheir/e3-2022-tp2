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
    input wire clock,
    input wire reset,
    input wire latch,
    input wire mode,  // 0: numbers, 1: codes
    input wire [2:0] dp,  // 111 -> DP en el MSD | 000 -> DP en el LSD
    input wire [3:0] codes, // C�digos hardcodados a definir. Para printear o hacer cosas ya definidas dentro�del�m�dulo	
    input wire [31:0] num,
    input wire [3:0] brightness,

    output reg sck,
    output reg din,
    output reg load
);

    reg EN_num = 0;
    reg EN_code = 0;
    reg [3:0] code_reg = 0;
    reg [31:0] num_reg = 0;

    always @(posedge clock) begin
        if (mode) begin
            if (num_reg == num) EN_num = 0;
            else begin
                EN_num  = 1;
                num_reg = num;
            end
        end else begin
            if (code_reg == code) EN_code = 0;
            else begin
                EN_code  = 1;
                code_reg = code;
            end
        end
        // ~~~~~~~~~~~~~~~~~~~~

        // if (rst == 1'b1) begin
        //     M_segments_q <= 1'h0;
        //     M_segment_index_q <= 1'h0;
        //     M_state_q <= 1'h0;
        // end else begin
        //     M_segments_q <= M_segments_d;
        //     M_segment_index_q <= M_segment_index_d;
        //     M_state_q <= M_state_d;
        // end
    end

    // num_mod num_mod (
    //     EN_num,
    //     num,
    //     dp,
    //     clock,
    //     reset
    // );
    // code_mod code_mod (
    //     EN_code,
    //     code,
    //     clock,
    //     reset
    // );

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    reg rst = 1'b1;

    wire M_max_cs;
    wire M_max_dout;
    wire M_max_sck;
    wire M_max_busy;
    reg [7:0] M_max_addr_in;
    reg [7:0] M_max_din;
    reg M_max_start;

    // Se instancia el max7129
    max7219 max (
        .clk(clock),
        .rst(rst),
        .addr_in(M_max_addr_in),
        .din(M_max_din),
        .start(M_max_start),
        .cs(M_max_cs),
        .dout(M_max_dout),
        .sck(M_max_sck),
        .busy(M_max_busy)
    );

    // Estados de la miniFSM
    localparam IDLE_state = 3'd0;
    localparam SEND_RESET_state = 3'd1;
    localparam SEND_MAX_INTENSITY_state = 3'd2;
    localparam SEND_NO_DECODE_state = 3'd3;
    localparam SEND_ALL_DIGITS_state = 3'd4;
    localparam SEND_WORD_state = 3'd5;
    localparam HALT_state = 3'd6;

    reg [2:0] M_state_d, M_state_q = IDLE_state;
    reg [63:0] M_segments_d, M_segments_q = 1'h0;
    reg [2:0] M_segment_index_d, M_segment_index_q = 1'h0;
    reg [ 7:0] max_addr;
    reg [ 7:0] max_data;

    // reg [31:0] digits = 32'h12345678;

    localparam C0 = 8'h7e;
    localparam C1 = 8'h30;
    localparam C2 = 8'h6d;
    localparam C3 = 8'h79;
    localparam C4 = 8'h33;
    localparam C5 = 8'h5b;
    localparam C6 = 8'h5f;
    localparam C7 = 8'h70;
    localparam C8 = 8'h7f;
    localparam C9 = 8'h7b;
    localparam A = 8'h77;
    localparam B = 8'h1f;
    localparam C = 8'h4e;
    localparam D = 8'h3d;
    localparam E = 8'h4f;
    localparam F = 8'h47;
    localparam O = 8'h1d;
    localparam R = 8'h05;
    localparam H = 8'h37;
    localparam L = 8'h0E;
    localparam MINUS = 8'h40;
    localparam BLANK = 8'h00;





    always @* begin
        M_state_d = M_state_q;
        M_segments_d = M_segments_q;
        M_segment_index_d = M_segment_index_q;

        M_segments_d[56+7-:8] = H;
        M_segments_d[48+7-:8] = O;
        M_segments_d[40+7-:8] = L;
        M_segments_d[32+7-:8] = A;
        M_segments_d[24+7-:8] = H;
        M_segments_d[16+7-:8] = O;
        M_segments_d[8+7-:8] = L;
        M_segments_d[0+7-:8] = A;

        digits <= num;
        // digits = 31'd1234;

        max_addr = 8'h00;
        max_data = 8'h00;
        M_max_start = 1'h0;

        case (M_state_q)
            IDLE_state: begin
                rst <= 1'b0;
                M_segment_index_d = 1'h0;
                M_state_d = SEND_RESET_state;
            end
            SEND_RESET_state: begin
                M_max_start = 1'h1;
                max_addr = 8'h0c;
                max_data = 8'h01;
                if (M_max_busy != 1'h1) begin
                    M_state_d = SEND_MAX_INTENSITY_state;
                end
            end
            SEND_MAX_INTENSITY_state: begin
                M_max_start = 1'h1;
                max_addr = 8'h0a;
                max_data = 8'h03;
                // max_data = brightness;
                if (M_max_busy != 1'h1) begin
                    M_state_d = SEND_NO_DECODE_state;
                end
            end
            SEND_NO_DECODE_state: begin
                M_max_start = 1'h1;
                max_addr = 8'h09;
                max_data = 8'hff;
                if (M_max_busy != 1'h1) begin
                    M_state_d = SEND_ALL_DIGITS_state;
                end
            end
            SEND_ALL_DIGITS_state: begin
                M_max_start = 1'h1;
                max_addr = 8'h0b;
                max_data = 8'h07;
                if (M_max_busy != 1'h1) begin
                    M_state_d = SEND_WORD_state;
                end
            end
            SEND_WORD_state: begin
                if (M_segment_index_q < 4'h8) begin
                    M_max_start = 1'h1;
                    max_addr = M_segment_index_q + 1'h1;
                    // max_data = M_segments_q[(M_segment_index_q)*8+7-:8];
                    max_data = digits[(M_segment_index_q)*4+3-:4];
                    if (M_max_busy != 1'h1) begin
                        M_segment_index_d = M_segment_index_q + 1'h1;
                    end
                end else begin
                    M_segment_index_d = 1'h0;
                    M_state_d = HALT_state;
                end
            end
            HALT_state: begin
                M_max_start = 1'h1;
                max_addr = 8'h00;
                max_data = 8'h00;
                // if (M_max_busy != 1'h1) begin
                //     M_state_f (M_max_busy != 1'h1) begin
                //     M_state_d = IDLE_state;
                // endd = IDLE_state;
                if (M_max_busy != 1'h1) begin
                    M_state_d = IDLE_state;
                end

            end
        endcase

        M_max_addr_in = max_addr;
        M_max_din = max_data;

        // Se actualizan los pines de salida según lo que "calculó" el módulo max7219
        sck  <= M_max_sck;
        din  <= M_max_dout;
        load <= M_max_cs;
    end

    always @(posedge clock) begin
        if (rst == 1'b1) begin
            M_segments_q <= 1'h0;
            M_segment_index_q <= 1'h0;
            M_state_q <= 1'h0;
        end else begin
            M_segments_q <= M_segments_d;
            M_segment_index_q <= M_segment_index_d;
            M_state_q <= M_state_d;
        end
    end

endmodule  //display

module code_mod (
    input EN,
    input code,
    input clock,
    input reset
);

    parameter BRIGHT_1 = 0, BRIGHT_2 = 1, BRIGHT_3 = 2, BRIGHT_4 = 3, HOLA = 4, CHAU = 5;

endmodule  //code_mod

module num_mod (
    input EN,
    input [31:0] num,
    input [3:0] dp,
    input clock,
    input reset
);

endmodule  // num_mod
