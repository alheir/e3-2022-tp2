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
module calc #(
    parameter CLK_DIV = 8
) (
    input wire pin_kb_Q0,    //Q0
    input wire pin_kb_Q1,    //Q1
    input wire pin_kb_OUT,   //OUT
    input wire pin_kb_LED2,  //LED2
    input wire pin_kb_LED1,  //LED1

    output reg  pin_kb_EN,  //EN
    output wire pin_kb_D0,  //D0
    output wire pin_kb_D1,  //D1

    output wire pin_max_CLK,  //maxCLK
    output wire pin_max_CS,   //maxCS
    output wire pin_max_DIN,  //maxDIN

    output wire pin_LED_D1,  //LEDD1
    output wire pin_LED_D2,  //LEDD2
    output wire pin_LED_D3,  //LEDD3
    output wire pin_LED_D4,  //LEDD4
    output wire pin_LED_D5,  //LEDD5
    output wire pin_LED_D6,  //LEDD6

    input wire pin_SW1,   //SW1
    input wire pin_SW2,   //SW2
    input wire pin_SW3,   //SW3
    input wire pin_SW4,   //SW4
    input wire pin_reset, //SW5

    output wire led_green,
    output wire led_blue,
    output wire led_red
);

    wire sw1;
    wire sw2;
    wire sw3;
    wire sw4;
    wire sw5;

    // Clock settings
    wire __clock, clock;
    SB_HFOSC #(
        .CLKHF_DIV("0b11")  // 6 MHz = ~48 MHz / 8 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    ) hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF  (__clock)
    );
    Clock_divider clocky (
        .clock_in (__clock),
        .clock_out(clock),    // 6MHz / 4 = 1.5MHz
        .clk_div  (CLK_DIV)
    );
    // SB_LFOSC intlosc (
    //     .CLKLFEN(1'b1),
    //     .CLKLFPU(1'b1),
    //     .CLKLF  (clock)
    // )  /* synthesis ROUTE_THROUGH_FABRIC = [0] */;

    wire enable;
    assign enable = 0;

    fsm calcFsm (
        .clock(clock),
        .reset(pin_reset), //pin_reset),

        .row_result({pin_kb_Q1, pin_kb_Q0}),
        .valid_out(pin_kb_OUT),
        .symbol_signal(pin_kb_LED2),
        .number_signal(pin_kb_LED1),
        .col_selector({pin_kb_D1, pin_kb_D0}),

        .max_sck(pin_max_CLK),
        .max_cs(pin_max_CS),
        .max_din(pin_max_DIN),
        .led1(pin_LED_D1),
        .led2(pin_LED_D2),
        .led3(pin_LED_D3),
        .led4(pin_LED_D4),
        .led5(pin_LED_D5),
        .led6(pin_LED_D6),
    );


    assign led_green = 1;
    assign led_blue  = 1;
    assign led_red   = 1;

endmodule
