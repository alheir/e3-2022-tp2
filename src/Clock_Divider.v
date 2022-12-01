module Clock_divider (
    input wire clock_in,
    output reg clock_out,
    input integer clk_div
);
    reg [27:0] counter = 28'd0;

    always @(posedge clock_in) begin
        counter <= counter + 28'd1;
        if (counter >= (clk_div - 1)) counter <= 28'd0;
        clock_out <= (counter < clk_div / 2) ? 1'b1 : 1'b0;
    end
endmodule
