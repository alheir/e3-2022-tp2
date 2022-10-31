module blinky (
    output wire led_blue,
    output wire led_green,
    output wire led_red,
    input  wire sw0,
    input  wire sw1,
    input  wire sw2,
    input  wire sw3
);

    // wire clk;
    // SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

    SB_LFOSC intlosc (
        .CLKLFEN(1'b1),
        .CLKLFPU(1'b1),
        .CLKLF  (clk)
    )  /* synthesis ROUTE_THROUGH_FABRIC = [1] */;

    localparam N = 8;
    reg [N:0] counter;

    // always @(posedge clk) counter <= counter + 1;


    always @(posedge clk) begin
        counter <= counter + 1;
    end

    SB_RGBA_DRV rgb (
        .RGBLEDEN(1'b1),
        .RGB0PWM (counter[N]),
        .RGB1PWM (counter[N-1]),
        .RGB2PWM (counter[N-2]),
        // .RGB2PWM (sw3),
        .CURREN  (1'b1),
        .RGB0    (led_blue),
        .RGB1    (led_green),
        .RGB2    (led_red)
    );
    defparam rgb.CURRENT_MODE = "0b1";
    defparam rgb.RGB0_CURRENT = "0b000001";
    defparam rgb.RGB1_CURRENT = "0b000001";
    defparam rgb.RGB2_CURRENT = "0b000001";

    // assign led_blue  = counter[N];
    // assign led_green = counter[N-1];
    // assign led_red   = counter[N-2];

    // assign led_red   = sw2;
    // assign led_green = sw1;
    // assign led_blue  = sw0;


endmodule
