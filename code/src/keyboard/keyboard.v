module keyboard (
    input        clk,
    input        rst,
    input  [1:0] row,  // row pressed
    output [1:0] col,  // col watched
    output [3:0] key   // key decoded
);

endmodule  //keyboard
