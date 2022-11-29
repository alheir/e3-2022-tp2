module zero_detect #(parameter DIGIT_NUM = 8) (
    input wire [DIGIT_NUM*4-1:0] num_in,
    output reg [DIGIT_NUM*4-1:0] num_out
    );

reg num_begin = 0;

integer i;

for(i = 0; i < DIGIT_NUM; i = i + 1) begin
    if((num_in[(DIGIT_NUM*4-1 - 4 * i) : ((DIGIT_NUM-1)*4 - 4 * i)] == 0) && (num_begin == 0)) begin
        num_out[(DIGIT_NUM*4-1 - 4 * i ):((DIGIT_NUM-1)*4 - 4 * i)] = 4'hf;
    end
    else begin
        num_out[(DIGIT_NUM*4-1 - 4 * i ): ((DIGIT_NUM-1)*4 - 4 * i)] = num_in[(DIGIT_NUM*4-1 - 4 * i ):( (DIGIT_NUM-1)*4 - 4 * i)];
        num_begin = 1;
    end
end
endmodule