module display (
    output wire pin_LED_D1,
    output wire pin_LED_D2,
    output wire pin_LED_D3,
    output wire pin_LED_D4,
    output wire pin_LED_D5,
    output wire pin_LED_D6,

    input wire pin_SW1,
    input wire pin_SW2,
    input wire pin_SW3,
    input wire pin_SW4,
    input wire pin_reset,

    output reg pin_max_CLK,
    output reg pin_max_CS,
    output reg pin_max_DIN
);

    wire clock;
    wire reset;
    // SB_LFOSC intlosc (
    //     .CLKLFEN(1'b1),
    //     .CLKLFPU(1'b1),
    //     .CLKLF  (clock)
    // )  /* synthesis ROUTE_THROUGH_FABRIC = [1] */;
    SB_HFOSC #(
        .CLKHF_DIV("0b11")  // 12 MHz = ~48 MHz / 4 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    ) hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF  (clock)
    );

    reg max_rst = 1'b1;
    wire max_cs;
    wire max_dout;
    wire max_sck;
    wire max_busy;
    reg [7:0] max_add_in;
    reg [7:0] max_din;
    reg max_start;

    max7219 max (
        .clk(clock),
        .rst(max_rst),
        .addr_in(max_add_in),
        .din(max_din),
        .start(max_start),
        .cs(max_cs),
        .dout(max_dout),
        .sck(max_sck),
        .busy(max_busy)
    );

    reg [4:0] curr_state = STATE_IDLE, next_state = STATE_IDLE;
    reg started = 1'b0, check_started = 1'b0;
    wire step, stepa;
    reg [7:0] add, data;

    localparam STATE_IDLE = 5'd0;
    localparam STATE_TURN_ON = 5'd1;
    localparam STATE_SCAN_ALL = 5'd2;
    localparam STATE_SET_DECODE = 5'd3;
    localparam STATE_SET_NO_DECODE = 5'd4;
    localparam STATE_SET_INT = 5'd5;
    localparam STATE_SEND_D0 = 5'd6;
    localparam STATE_WRITE_BCD = 5'd7;
    localparam STATE_WRITE_NO_BCD = 5'd8;

    reg [3:0] curr_intensity, next_intensity;
    reg [31:0] curr_bcd_buffer, next_bcd_buffer;
    reg [63:0] curr_no_bcd_buffer, next_no_bcd_buffer;
    reg [3:0] curr_dig_index = 1'h0, next_dig_index = 1'h0;

    reg [31:0] counter = 1'h0, next_counter = 1'h0;

    always @(posedge clock) begin
        max_start = 1'h0;
        add = 8'h00;
        data = 8'h00;

        case (curr_state)
            STATE_IDLE: begin
                max_rst <= 1'b0;
                add  = 8'h00;
                data = 8'h00;

                if (step != 1'h1) begin
                    if (started != 1'h1) begin
                        next_state = STATE_TURN_ON;
                    end else begin
                        next_bcd_buffer = 32'h12340987;
                        next_state = STATE_WRITE_BCD;
                    end
                end else if (stepa != 1'h1 && started == 1'h1) begin
                    next_state = STATE_SET_INT;
                end else if (pin_SW1 != 1'h1 && started == 1'h1) begin
                    next_intensity = curr_intensity + 1'h1;
                end else if (pin_SW3 != 1'h1 && started == 1'h1) begin
                    // next_bcd_buffer = {curr_bcd_buffer[3:0], curr_bcd_buffer[31:4]};
                end else if (pin_SW4 != 1'h1 && started == 1'h1) begin
                    // next_state = STATE_WRITE_BCD;
                end

                if (started == 1'h1) begin
                    if (counter[22] == 1'h1) begin
                        next_bcd_buffer = {curr_bcd_buffer[3:0], curr_bcd_buffer[31:4]};
                        next_state = STATE_WRITE_BCD;
                    end
                    if (counter[24] == 1'h1) begin
                        next_intensity = curr_intensity + 1'h1;
                        next_state = STATE_SET_INT;
                    end
                end


            end
            STATE_TURN_ON: begin
                max_start = 1'h1;
                add = 8'h0c;
                data = 8'h01;
                if (max_busy != 1'h1) begin
                    next_state = STATE_SCAN_ALL;
                end
            end
            STATE_SCAN_ALL: begin
                max_start = 1'h1;
                add = 8'h0b;
                data = 8'h07;
                if (max_busy != 1'h1) begin
                    next_state = STATE_SET_DECODE;
                end
            end
            STATE_SET_DECODE: begin
                max_start = 1'h1;
                add = 8'h09;
                data = 8'hff;
                if (max_busy != 1'h1) begin
                    if (started != 1'h1) begin
                        next_intensity = 4'h0;
                        next_state = STATE_SET_INT;
                    end else begin
                        next_state = STATE_IDLE;
                    end

                end
            end
            STATE_SET_NO_DECODE: begin
                max_start = 1'h1;
                add = 8'h09;
                data = 8'h00;
                if (max_busy != 1'h1) begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_SET_INT: begin
                max_start = 1'h1;
                add = 8'h0a;
                data = curr_intensity;
                if (max_busy != 1'h1) begin
                    if (started != 1'h1) begin
                        check_started = 1'h1;
                        next_bcd_buffer = 1'h0;
                        next_state = STATE_WRITE_BCD;
                    end else begin
                        next_state = STATE_IDLE;
                    end
                end
            end
            STATE_SEND_D0: begin
                max_start = 1'h1;
                add = 8'h01;
                data = 8'h08;
                if (max_busy != 1'h1) begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_WRITE_BCD: begin
                if (curr_dig_index < 4'h8) begin
                    max_start = 1'h1;
                    add = curr_dig_index + 1'h1;
                    data = curr_bcd_buffer[(curr_dig_index)*4+3:(curr_dig_index)*4];
                    if (max_busy != 1'h1) begin
                        next_dig_index = curr_dig_index + 1'h1;
                    end
                end else begin
                    next_dig_index = 1'h0;
                    next_state = STATE_IDLE;
                end
            end
        endcase

        max_add_in = add;
        max_din = data;

        pin_max_CLK <= max_sck;
        pin_max_CS  <= max_cs;
        pin_max_DIN <= max_dout;

    end

    always @(posedge clock) begin
        if (max_rst) begin
            curr_state <= STATE_IDLE;
            curr_dig_index <= 1'h0;
            curr_bcd_buffer <= 1'h0;
            curr_no_bcd_buffer <= 1'h0;
            curr_intensity <= 1'h0;
            started <= 1'h0;
        end else begin
            curr_state <= next_state;
            curr_dig_index <= next_dig_index;
            curr_bcd_buffer <= next_bcd_buffer;
            curr_no_bcd_buffer <= next_no_bcd_buffer;
            curr_intensity <= next_intensity;
            started <= check_started;

            counter <= counter + 1;

        end
    end

    assign reset = 1'b1;
    assign step = pin_reset;
    assign stepa = pin_SW2;

    // assign {pin_LED_D3, pin_LED_D4, pin_LED_D6, pin_LED_D1} = curr_state[3:0];
    // assign {pin_LED_D4, pin_LED_D6, pin_LED_D1} = ~curr_state[2:0];
    // assign {pin_LED_D2, pin_LED_D5, pin_LED_D3} = ~next_state[2:0];
    // assign pin_LED_D5 = ~pin_reset;
    // assign pin_LED_D6 = 0;

    assign pin_LED_D2 = ((stepa != 1'h1 || pin_SW1 != 1'h1) && started == 1'h1);
    assign {pin_LED_D5, pin_LED_D3, pin_LED_D4, pin_LED_D6, pin_LED_D1} = curr_dig_index[4:0];

endmodule  //display
