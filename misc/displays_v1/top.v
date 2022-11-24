module top (
    // input wie clk,
    // input wire rst,
    // input wire mode,  // 0: numbers, 1: codes
    // input [31:0] digits, // En BCD: (MSDigit) [3:0] [3:0] [3:0] [3:0] [3:0] [3:0] [3:0] [3:0] (LSDigit). 0xF == minus
    // input [2:0] dp,  // 111 -> DP en el MSD | 000 -> DP en el LSD
    // input [3:0] codes, // Códigos hardcodados a definir. Para printear o hacer cosas ya definidas dentro del módulo

    output reg gpio_47,  // Max7219 CLK
    output reg gpio_2,  // Max7219 DIN
    output reg gpio_46,   // Max7219 CS
);

    reg mode = MODE_NUMBER;
    reg [31:0] digits = 32'h77777777;
    reg [2:0] dp = 0;
    reg [3:0] codes = 0;

    wire clk;
    SB_HFOSC #(
        .CLKHF_DIV("0b10")  // 12 MHz = ~48 MHz / 4 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    ) hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF  (clk)
    );

    wire max_rst = 1'b1;
    // assign max_rst = !rst; // Habilitar luego, cuando se use el rst global.

    wire max_cs_pin;
    wire max_sck_pin;
    wire max_dout_pin;
    assign max_cs_pin   = gpio_46;
    assign max_sck_pin  = gpio_47;
    assign max_dout_pin = gpio_2;

    wire max_cs_buff;
    wire max_dout_buff;
    wire max_sck_buff;
    wire max_busy;

    reg [7:0] max_address;
    reg [7:0] max_data;
    reg [7:0] max_address_buff;
    reg [7:0] max_data_buff;
    reg max_start;

    // Instancia del módulo
    max7219 max (
        .clk(clk),
        .rst(max_rst),
        .addr_in(max_address),
        .din(max_data),
        .start(max_start),
        .cs(max_cs_buff),
        .dout(max_dout_buff),
        .sck(max_sck_buff),
        .busy(max_busy)
    );


    reg [3:0] curr_state = STATE_INIT, next_state;

    localparam [5:0] STATE_INIT = 0;
    localparam [5:0] STATE_ON = 1;
    localparam [5:0] STATE_SEND_INIT_INT = 2;
    localparam [5:0] STATE_SEND_INIT_DEC_MODE = 3;
    localparam [5:0] STATE_SEND_SCAN_ALL = 4;
    localparam [5:0] STATE_SEND_NO_OP = 5;
    localparam [5:0] STATE_SEND_DEC_MODE = 6;
    localparam [5:0] STATE_SEND_DIGS = 7;

    reg [2:0] segment_index = 0;

    reg [2:0] M_state_d, M_state_q = IDLE_state;
    reg [63:0] M_segments_d, M_segments_q = 1'h0;
    reg [2:0] M_segment_index_d, M_segment_index_q = 1'h0;

    localparam [7:0] ADDR_NO_OP = 8'h00;
    localparam [7:0] ADDR_DIG_0 = 8'h01;
    localparam [7:0] ADDR_DIG_7 = 8'h08;
    localparam [7:0] ADDR_DEC_MODE = 8'h09;
    localparam [7:0] ADDR_INT = 8'h0A;
    localparam [7:0] ADDR_SCAN = 8'h0B;
    localparam [7:0] ADDR_SHTDWN = 8'h0C;
    localparam [7:0] ADDR_DSPLYTST = 8'h0F;

    localparam [7:0] DATA_SHTDWN_SHTDWN = 8'h00;
    localparam [7:0] DATA_SHTDWN_NRML = 8'h01;

    localparam MODE_NUMBER = 0;
    localparam MODE_CODES = 1;



    // Define the Characters used for display
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
    localparam MINUS = 8'h40;
    localparam BLANK = 8'h00;

    // Transición al próximo estado
    // always @(posedge clk or negedge rst) begin
    //     if (!rst) begin
    //         curr_state <= STATE_INIT;
    //     end else begin
    //         curr_state <= next_state;
    //     end
    // end
    always @(posedge clk or negedge rst) begin
        if (clk) curr_state <= next_state;
    end

    // Salidas
    always @(curr_state) begin
        case (curr_state)
            STATE_INIT: begin
                max_rst <= 0;
            end
            STATE_ON: begin
                max_start = 1;
                max_address_buff = ADDR_SHTDWN;
                max_data_buff = DATA_SHTDWN_NRML;
            end
            STATE_SEND_INIT_INT: begin
                max_start = 1;
                max_address_buff = ADDR_INT;
                max_data_buff = 8'h07;  // 15/32, aprox 50%
            end
            STATE_SEND_INIT_DEC_MODE: begin
                max_start = 1;
                max_address_buff = ADDR_DEC_MODE;
                max_data_buff = 8'hFF;  // Decode mode ON all
            end
            STATE_SEND_SCAN_ALL: begin
                max_start = 1;
                max_address_buff = ADDR_SCAN;
                max_data_buff = 8'h07;  // Scan all
            end
            STATE_SEND_NO_OP: begin
                max_start = 1;
                max_address_buff = ADDR_NO_OP;
                max_data_buff = 8'h00;
            end
            STATE_SEND_DEC_MODE: begin
                max_start = 1;
                max_address_buff = ADDR_DEC_MODE;
                max_data_buff = 8'hFF;  // Decode mode ON all
            end
            STATE_SEND_DIGS: begin
                if (segment_index < 8) begin
                    max_start = 1;
                    max_address_buff = ADDR_DIG_0 + segment_index;
                    max_data_buff = digits[(segment_index)*4+3:(segment_index)*4];
                    if (!max_busy) begin
                        segment_index = segment_index + 1;
                    end
                end else begin
                    segment_index = 0;
                    next_state = STATE_SEND_NO_OP;
                end
                // if (M_segment_index_q < 4'h8) begin
                //     M_max_start = 1'h1;
                //     max_addr = M_segment_index_q + 1'h1;
                //     max_data = M_segments_q[(M_segment_index_q)*8+7-:8];
                //     if (M_max_busy != 1'h1) begin
                //         M_segment_index_d = M_segment_index_q + 1'h1;
                //     end
                // end else begin
                //     M_segment_index_d = 1'h0;
                //     M_state_d = HALT_state;
                // end
            end
        endcase

        max_address = max_address_buff;
        max_data = max_data_buff;

        max_cs_pin   <= max_cs_buff;
        max_dout_pin <= max_dout_buff;
        max_sck_pin  <= max_sck_buff;
    end

    // Lógica del próximo estado
    always @* begin
        case (curr_state)
            STATE_INIT: begin
                next_state = STATE_ON;
            end
            STATE_ON: begin
                if (!max_busy) next_state = STATE_SEND_INIT_INT;
            end
            STATE_SEND_INIT_INT: begin
                if (!max_busy) next_state = STATE_SEND_INIT_DEC_MODE;
            end
            STATE_SEND_INIT_DEC_MODE: begin
                if (!max_busy) next_state = STATE_SEND_SCAN_ALL;
            end
            STATE_SEND_SCAN_ALL: begin
                if (!max_busy) next_state = STATE_SEND_NO_OP;
            end
            STATE_SEND_NO_OP: begin
                if (!max_busy) begin
                    if (mode == MODE_NUMBER) next_state = STATE_SEND_DEC_MODE;
                    // else if (mode == MODE_CODES) begin
                    //     //yes 
                    // end
                end
            end
            STATE_SEND_DEC_MODE: begin
                if (!max_busy) next_state = STATE_SEND_DIGS;
            end
            STATE_SEND_DIGS: begin
                // if (!max_busy) next_state = ADDR_NO_OP;
            end
        endcase
    end

    // always @* begin
    //     // M_state_d = M_state_q;
    //     // M_segments_d = M_segments_q;
    //     // M_segment_index_d = M_segment_index_q;

    //     // // M_segments_d[56+7-:8] = B;
    //     // // M_segments_d[48+7-:8] = O;
    //     // // M_segments_d[40+7-:8] = C;
    //     // // M_segments_d[32+7-:8] = E;
    //     // // M_segments_d[24+7-:8] = E;
    //     // // M_segments_d[16+7-:8] = E;
    //     // // M_segments_d[8+7-:8] = E;
    //     // // M_segments_d[0+7-:8] = E;
    //     // // max_addr = 8'h00;
    //     // // max_data = 8'h00;
    //     // // M_max_start = 1'h0;

    //     case (M_state_q)
    //         IDLE_state: begin
    //             rst <= 1'b0;
    //             M_segment_index_d = 1'h0;
    //             M_state_d = SEND_RESET_state;
    //         end
    //         SEND_RESET_state: begin
    //             M_max_start = 1'h1;
    //             max_addr = 8'h0c;
    //             max_data = 8'h01;
    //             if (M_max_busy != 1'h1) begin
    //                 M_state_d = SEND_MAX_INTENSITY_state;
    //             end
    //         end
    //         SEND_MAX_INTENSITY_state: begin
    //             M_max_start = 1'h1;
    //             max_addr = 8'h0a;
    //             max_data <= 8'h07;
    //             if (M_max_busy != 1'h1) begin
    //                 M_state_d = SEND_NO_DECODE_state;
    //             end
    //         end
    //         SEND_NO_DECODE_state: begin
    //             M_max_start = 1'h1;
    //             max_addr = 8'h09;
    //             max_data = 1'h0;
    //             if (M_max_busy != 1'h1) begin
    //                 M_state_d = SEND_ALL_DIGITS_state;
    //             end
    //         end
    //         SEND_ALL_DIGITS_state: begin
    //             M_max_start = 1'h1;
    //             max_addr = 8'h0b;
    //             max_data = 8'h07;
    //             if (M_max_busy != 1'h1) begin
    //                 M_state_d = SEND_WORD_state;
    //             end
    //         end
    //         SEND_WORD_state: begin
    //             if (M_segment_index_q < 4'h8) begin
    //                 M_max_start = 1'h1;
    //                 max_addr = M_segment_index_q + 1'h1;
    //                 max_data = M_segments_q[(M_segment_index_q)*8+7-:8];
    //                 if (M_max_busy != 1'h1) begin
    //                     M_segment_index_d = M_segment_index_q + 1'h1;
    //                 end
    //             end else begin
    //                 M_segment_index_d = 1'h0;
    //                 M_state_d = HALT_state;
    //             end
    //         end
    //         HALT_state: begin
    //             max_addr = 8'h00;
    //             max_data = 8'h00;
    //         end
    //     endcase

    // max_address = max_address_buff;
    // max_data = max_data_buff;

    // max_cs_pin   <= max_cs_buff;
    // max_dout_pin <= max_dout_buff;
    // max_sck_pin  <= max_sck_buff;

    // end

    // always @(posedge clk or negedge rst) begin
    //     if (rst == 1'b1) begin
    //         M_segments_q <= 1'h0;
    //         M_segment_index_q <= 1'h0;
    //         M_state_q <= 1'h0;
    //     end else begin
    //         M_segments_q <= M_segments_d;
    //         M_segment_index_q <= M_segment_index_d;
    //         M_state_q <= M_state_d;
    //     end
    // end



endmodule
