module adder #(
    parameter DATA_WIDTH = 8,             // Width of the input data (matches FIFO)
    parameter SUM_WIDTH  = DATA_WIDTH + 1  // Output width for the sum
)(
    input  wire [DATA_WIDTH-1:0] in1,       // First adder input
    input  wire [DATA_WIDTH-1:0] in2,       // Second adder input
    output wire [SUM_WIDTH-1:0] sum         // Output sum
);

    // Combinational addition
    assign sum = in1 + in2;

endmodule
