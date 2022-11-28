module display (
    input wire clock,
    input wire reset,
    input wire latch,
    input wire mode,  // 0: numbers, 1: codes
    input wire [2:0] dp,  // 111 -> DP en el MSD | 000 -> DP en el LSD
    input wire [3:0] code, // C�digos hardcodados a definir. Para printear o hacer cosas ya definidas dentro�del�m�dulo	
    input wire [31:0] num,
    input wire [3:0] brightness,

    output reg sck,
    output reg din,
    output reg cs,

    // output reg led_D5
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
    // localparam STATE_SET_NO_DECODE = 5'd4;
    localparam STATE_SET_INT = 5'd4;
    localparam STATE_SEND_D0 = 5'd5;
    localparam STATE_WRITE_BCD = 5'd6;
    localparam STATE_WRITE_NO_BCD = 5'd7;

    localparam DECODE = 8'hff;
    localparam NO_DECODE = 8'h00;

    localparam CODE_HOLAHOLA = 4'h0;

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

    reg [3:0] curr_intensity, next_intensity;
    reg [7:0] curr_decode, next_decode;
    reg [31:0] curr_bcd_buffer, next_bcd_buffer;
    reg [63:0] curr_no_bcd_buffer, next_no_bcd_buffer;
    reg [3:0] curr_dig_index = 1'h0, next_dig_index = 1'h0;

    always @(posedge clock) begin
        max_start = 1'h0;
        add = 8'h00;
        data = 8'h00;

        case (curr_state)
            STATE_IDLE: begin
                max_rst <= 1'b0;
                add  = 8'h00;
                data = 8'h00;

                if (started != 1'h1) begin
                    next_state = STATE_TURN_ON;
                end else begin
                    if(mode != 1'h1) begin
                        if(curr_decode == NO_DECODE) begin
                            next_decode = DECODE;
                            next_state = STATE_SET_DECODE;
                        end else begin 
                            next_bcd_buffer = num;
                            next_state = STATE_WRITE_BCD;
                        end
                    end else if(mode == 1) begin
                        if(curr_decode == DECODE) begin
                            next_decode = NO_DECODE;
                            next_state = STATE_SET_DECODE;
                        end else begin 
                            case (code)
                                CODE_HOLAHOLA: begin
                                    next_no_bcd_buffer = {H,O,L,A,H,O,L,A};
                                    next_state = STATE_WRITE_NO_BCD;
                                end
                            endcase
                            
                        end
                    end
                    if (next_intensity != curr_intensity) begin
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
                    next_decode = DECODE;
                    next_state = STATE_SET_DECODE;
                end
            end
            STATE_SET_DECODE: begin
                max_start = 1'h1;
                add = 8'h09;
                data = curr_decode;
                if (max_busy != 1'h1) begin
                    if (started != 1'h1) begin
                        next_state = STATE_SET_INT;
                    end else begin
                        next_state = STATE_IDLE;
                    end

                end
            end
            STATE_SET_INT: begin
                max_start = 1'h1;
                add = 8'h0a;
                data = curr_intensity;
                if (max_busy != 1'h1) begin
                    if (started != 1'h1) begin
                        check_started = 1'h1;
                        next_bcd_buffer = 8'h0;
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
            STATE_WRITE_NO_BCD: begin
                if (curr_dig_index < 4'h8) begin
                    max_start = 1'h1;
                    add = curr_dig_index + 1'h1;
                    data = curr_no_bcd_buffer[(curr_dig_index)*8+7:(curr_dig_index)*8];
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

        sck <= max_sck;
        cs  <= max_cs;
        din <= max_dout;

    end

    always @(posedge clock) begin
        if (!reset || max_rst) begin
            curr_state <= STATE_IDLE;
            curr_dig_index <= 1'h0;
            curr_bcd_buffer <= 1'h0;
            curr_no_bcd_buffer <= 1'h0;
            curr_intensity <= 1'h0;
            curr_decode <= 1'h0;
            started <= 1'h0;
        end else begin
            curr_state <= next_state;
            curr_dig_index <= next_dig_index;
            curr_bcd_buffer <= next_bcd_buffer;
            curr_no_bcd_buffer <= next_no_bcd_buffer;
            curr_intensity <= next_intensity;
            curr_decode <= next_decode;
            started <= check_started;

            // counter <= counter + 1;

        end
    end

    assign next_intensity = brightness;

    // assign led_D5 = started;

endmodule  // display
