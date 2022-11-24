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
    output reg load
);

    reg num_reg = 0;
    reg code_reg = 0;
    reg D = 0;
    reg EN = 0;
    reg [31:0] data = 0;

    always @(posedge clk) begin
        if (mode) begin
            data = num;
            D = 1;
            if (num_reg != num) begin
                EN = 1;
                num_reg = num;
            end else EN = 0;
        end else begin
            D = 0;
            if (code_reg != code) begin
                EN = 1;
                code_reg = code;
            end else EN = 0;
        end
    end


    send2display sender (
        .clock(clock),
        .reset(reset),
        .EN(EN),
        .decode(D),
        .brightness(brightness),
        .D7(data[31:28]),
        .D6(data[27:24]),
        .D5(data[23:20]),
        .D4(data[19:16]),
        .D3(data[15:12]),
        .D2(data[11:8]),
        .D1(data[7:4]),
        .D0(data[3:0]),
        .pinSCK(sck),
        .pinDIN(din),
        .pinLOAD(load),
    );

endmodule

module send2display (
    input wire clock,
    input wire reset,
    input wire EN,
    input wire decode,
    input wire [3:0] brightness,
    input wire [3:0] D7,
    input wire [3:0] D6,
    input wire [3:0] D5,
    input wire [3:0] D4,
    input wire [3:0] D3,
    input wire [3:0] D2,
    input wire [3:0] D1,
    input wire [3:0] D0,

    output reg pinSCK,
    output reg pinDIN,
    output reg pinLOAD
);

    reg brightness_reg = 0;

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    reg rst = 1'b1;

    wire M_max_cs;
    wire M_max_dout;
    wire M_max_sck;
    wire M_max_busy;
    reg [7:0] M_max_addr_in;
    reg [7:0] M_max_din;
    reg M_max_start;

    reg starting;

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

    localparam [4:0] NO_OP_state = 5'd19;
    localparam [4:0] IDLE_state = 5'd0;
    localparam [4:0] SEND_RESET_state = 5'd1;
    localparam [4:0] SEND_INTENSITY_state = 5'd2;
    localparam [4:0] SEND_NO_DECODE_state = 5'd3;
    localparam [4:0] SEND_ALL_DIGITS_state = 5'd4;
    localparam [4:0] SEND_WORD_state = 5'd5;
    localparam [4:0] HALT_state = 5'd6;
    localparam [4:0] SEND_DIG0 = 5'd20;
    localparam [4:0] SEND_DIG1 = 5'd21;
    localparam [4:0] SEND_DIG2 = 5'd22;
    localparam [4:0] SEND_DIG3 = 5'd23;
    localparam [4:0] SEND_DIG4 = 5'd24;
    localparam [4:0] SEND_DIG5 = 5'd25;
    localparam [4:0] SEND_DIG6 = 5'd26;
    localparam [4:0] SEND_DIG7 = 5'd27;

    reg [2:0] M_state_d, M_state_q = IDLE_state;
    reg [63:0] M_segments_d, M_segments_q = 1'h0;
    reg [2:0] M_segment_index_d, M_segment_index_q = 1'h0;

    reg [7:0] max_addr;
    reg [7:0] max_data;

    always @* begin
        M_state_d = M_state_q;
        // M_segments_d = M_segments_q;
        M_segment_index_d = M_segment_index_q;

        max_addr = 8'h00;
        max_data = 8'h00;
        M_max_start = 1'h0;

        starting = 1;

        if (starting) begin
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
                SEND_INTENSITY_state: begin
                    M_max_start = 1'h1;
                    max_addr = 8'h0a;
                    max_data = 8'h07;
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
                        M_state_d = SEND_DIG0;
                    end
                end
                SEND_DIG0: begin
                    M_max_start = 1'h1;
                    max_addr = 8'01;
                    max_data = D0;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = SEND_DIG1;
                    end
                end
                SEND_DIG1: begin
                    M_max_start = 1'h1;
                    max_addr = 8'02;
                    max_data = D1;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = SEND_DIG2;
                    end
                end
                SEND_DIG2: begin
                    M_max_start = 1'h1;
                    max_addr = 8'03;
                    max_data = D2;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = SEND_DIG3;
                    end
                end
                SEND_DIG3: begin
                    M_max_start = 1'h1;
                    max_addr = 8'04;
                    max_data = D3;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = SEND_DIG4;
                    end
                end
                SEND_DIG4: begin
                    M_max_start = 1'h1;
                    max_addr = 8'05;
                    max_data = D4;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = SEND_DIG5;
                    end
                end
                SEND_DIG5: begin
                    M_max_start = 1'h1;
                    max_addr = 8'06;
                    max_data = D5;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = SEND_DIG6;
                    end
                end
                SEND_DIG6: begin
                    M_max_start = 1'h1;
                    max_addr = 8'07;
                    max_data = D6;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = SEND_DIG7;
                    end
                end
                SEND_DIG7: begin
                    M_max_start = 1'h1;
                    max_addr = 8'08;
                    max_data = D7;
                    if (M_max_busy != 1'h1) begin
                        M_state_d = NO_OP_state;
                        starting = 0;
                    end
                end
            endcase

        end else begin

        end

        M_max_addr_in = max_addr;
        M_max_din = max_data;

        sck  <= M_max_sck;
        din  <= M_max_dout;
        load <= M_max_cs;  

    end


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    always @(posedge clock) begin
        if (brightness_reg != brightness) begin
            brightness_send = brightness;
            brightness_reg = brightness;
            addr_in = 8'hXA;

        end
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


endmodule
