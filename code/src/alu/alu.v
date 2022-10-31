module alu (
    input         clk,
    input         rst,
    input  [15:0] a,       // 1st number
    input  [15:0] b,       // 2nd number
    input  [ 2:0] op,      // operation
    output [15:0] result,  // result
    output [ 4:0] status   // flag codes
);

endmodule  //alu
