module bcd2bin (
    input  wire [31:0] num,
    output reg  [23:0] bin
);

    // assign bin = (num[31:28] * 24'd10000000) + (num[27:24] * 24'd1000000) + (num[23:20] * 24'd100000) + (num[19:16] * 24'd10000) + (num[15:12] * 24'd1000) + (num[11:8] * 24'd100) + (num[7:4] * 24'd10) + num[3:0];
    assign bin = (num[31:28] * 24'd10000000) + (num[27:24] * 20'd1000000) + (num[23:20] * 20) + (num[19:16] * 16'd10000) + (num[15:12] * 10'd1000) + (num[11:8] * 8'd100) + (num[7:4] * 4'd10) + num[3:0];

endmodule

module bin2bcd (
    input [23:0] bin,
    output reg [31:0] bcd
);

    integer i;

    always @(bin) begin
        bcd = 0;
        for (i = 0; i < 24; i = i + 1) begin  //Iterate once for each bit in input number
            if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;  //If any BCD digit is >= 5, add three
            if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
            if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
            if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
            if (bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 3;
            if (bcd[23:20] >= 5) bcd[23:20] = bcd[23:20] + 3;
            if (bcd[27:24] >= 5) bcd[27:24] = bcd[27:24] + 3;
            if (bcd[31:28] >= 5) bcd[31:28] = bcd[31:28] + 3;
            bcd = {bcd[30:0], bin[23-i]};  //Shift one bit, and shift in proper bit from input 
        end
    end
endmodule

module alu #(
    parameter DIGIT_NUM = 8
) (
    input wire operand0_sign,
    input wire [DIGIT_NUM*4-1:0] operand0,
    input wire [2:0] operand0_dp,
    input wire operand1_sign,
    input wire [DIGIT_NUM*4-1:0] operand1,
    input wire [2:0] operand1_dp,
    input wire [2:0] operation,
    output wire [DIGIT_NUM*4-1:0] result,
    output wire result_sign,
    output wire [2:0] result_dp
);

    wire [23:0] bin0;
    wire [23:0] bin1;
    reg [24:0] res;
    wire [24:0] prod_res;
    // wire [24:0] bin0_signed = (operand0_sign ? -bin0 : bin0) / (10 ** operand0_dp);
    // wire [24:0] bin1_signed = (operand1_sign ? -bin1 : bin1) / (10 ** operand1_dp);
    wire [15:0] bin0_signed = (operand0_sign ? -bin0 : bin0);
    wire [15:0] bin1_signed = (operand1_sign ? -bin1 : bin1);

    bcd2bin operand1_i (
        .num(operand0),
        .bin(bin0)
    );
    bcd2bin operand2_i (
        .num(operand1),
        .bin(bin1)
    );

    always @(operand0, operand0_sign, operand1, operand1_sign, operation) begin
        case (operation)
            0: begin
                res = ((4'd10 ** operand1_dp) * bin0_signed + (4'd10 ** operand0_dp) * bin1_signed);
                result_dp = operand0_dp + operand1_dp;
            end
            1: begin
                res = ((4'd10 ** operand1_dp) * bin0_signed - (4'd10 ** operand0_dp) * bin1_signed);
                result_dp = operand0_dp + operand1_dp;
            end
            2: begin
                res = bin0_signed * bin1_signed;
                result_dp = operand0_dp + operand1_dp;
            end
            3: begin
                if (bin1_signed != 0) res = bin0_signed / bin1_signed;
                else res = 32'd99999999;
            end
            4: res = bin0_signed ** bin1_signed;
            default: res = 0;
        endcase
    end

    bin2bcd result_mod (
        .bin((result_sign) ? (-res) : res),
        .bcd(result)
    );

    assign result_sign = res[24];
endmodule
