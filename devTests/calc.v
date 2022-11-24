//-----------------------------------------------------------------------------
//
// Title       : calc
// Design      : calc
// Author      : aheir
// Company     : aheir
//
//-----------------------------------------------------------------------------
//
// File        : F:\documents\alheir\e3-2022-tp2\active\e3tp2\src\calc.v
// Generated   : Sun Oct 30 22:02:15 2022
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
//{module {calc}}
module calc (
    input wire pin_kb_Q0,    //Q0
    input wire pin_kb_Q1,    //Q1
    input wire pin_kb_OUT,   //OUT
    input wire pin_kb_LED2,  //LED2
    input wire pin_kb_LED1,  //LED1

    output reg  pin_kb_EN,  //EN
    output wire pin_kb_D0,  //D0
    output wire pin_kb_D1,  //D1

    output reg pin_max_CLK,   //maxCLK
    output reg pin_max_LOAD,  //maxLOAD
    output reg pin_max_DIN,   //maxDIN

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
    input wire pin_reset, //SW5

    output wire led_green,
    output wire led_blue,
    output wire led_red
    );


    // Clock settings
    wire clock;
    // SB_HFOSC #(
    //     .CLKHF_DIV("0b11")  // 12 MHz = ~48 MHz / 4 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    // ) hf_osc (
    //     .CLKHFPU(1'b1),
    //     .CLKHFEN(1'b1),
    //     .CLKHF  (clock)
    // );
    SB_LFOSC intlosc (
        .CLKLFEN(1'b1),
        .CLKLFPU(1'b1),
        .CLKLF  (clock)
    )  /* synthesis ROUTE_THROUGH_FABRIC = [1] */;
    // Clock settings

    wire enable;
    assign enable = 0;

    fsm calcFsm(
        .clock(clock),
        .reset(pin_reset),

        .row_result({pin_kb_Q1, pin_kb_Q0}),
        .valid_out(pin_kb_OUT),
        .symbol_signal(pin_kb_LED2),
        .number_signal(pin_kb_LED1),
        .col_selector({pin_kb_D1, pin_kb_D0}),

        .max_sck(pin_max_CLK),
        .max_load(pin_max_LOAD),
        .max_din(pin_max_DIN),
    );


    assign led_green = 1;
    assign led_blue = 1;
    assign led_red = 1;

endmodule
