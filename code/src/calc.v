module calc (
    input        rst,
    input  [1:0] kbrow,    // row pressed
    output [1:0] kbcol,    // col watched
    output [4:0] leds,     // flag LEDs
    output [3:0] bcd_out,  // BCD to show
    output       buzzer    // buzzer signal
);

    wire clk;

    // Asignación del HFOSC (48MHz)
    SB_HFOSC OSCInst0 (
        .CLKHFEN(1'b1),
        .CLKHFPU(1'b1),
        .CLKHF  (clk)
    )  /* synthesis ROUTE_THROUGH_FABRIC= [1] */;  // Use fabric routes
    defparam OSCInst0.CLKHF_DIV = "0b00";  // No se dividen los 48MHz



endmodule  //calc
