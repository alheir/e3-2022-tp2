module top (
    //ports
    // input wire CLK,  // 
    output reg gpio_47,  // Max7219 CLK
    output reg gpio_2,  // Max7219 DIN
    output reg gpio_46,   // Max7219 CS
    output reg gpio_31,
    output reg gpio_43,
    output reg gpio_36,
    output reg gpio_42,
    output reg gpio_34,
    output reg gpio_37,
    input wire gpio_26
);

    reg [31:0] digits = 32'h12345678;   

    wire clk;

    SB_HFOSC #(
        .CLKHF_DIV("0b11")  // 12 MHz = ~48 MHz / 4 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    ) hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF  (clk)
    );

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
        .clk(clk),
        .rst(rst),
        .addr_in(M_max_addr_in),
        .din(M_max_din),
        .start(M_max_start),
        .cs(M_max_cs),
        .dout(M_max_dout),
        .sck(M_max_sck),
        .busy(M_max_busy)
    );

    // Estados de la FSM
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

    reg [7:0] max_addr;

    reg [7:0] max_data;

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
    localparam H = 8'h37;
    localparam L = 8'h0E;
    localparam MINUS = 8'h40;
    localparam BLANK = 8'h00;

    // Lógica combinacional (acciones) y secuencial (de próximo estado)
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
                max_data = 8'h00;
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
                
                max_addr = 8'h00;
                max_data = 8'h00;
                // if (M_max_busy != 1'h1) begin
                //     M_state_f (M_max_busy != 1'h1) begin
                //     M_state_d = IDLE_state;
                // endd = IDLE_state;
                if (M_max_busy  != 1'h1) begin
                    M_state_d = HALT_state;
                end

            end
        endcase

        M_max_addr_in = max_addr;
        M_max_din = max_data;

        // Se actualizan los pines de salida según lo que "calculó" el módulo max7219

        gpio_47 <= M_max_sck;
        gpio_2 <= M_max_dout;
        gpio_46 <= M_max_cs;
        gpio_31 = 1;
        // gpio_43 = 1;
        // gpio_36 = 1;
        // gpio_42 = 1;
        // gpio_34 = 1;
        // gpio_37 = 1;

    end

    // Actualización de estado "y cosas" en los pulsos de clock
    always @(posedge clk) begin
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
