module multiplier #(
    parameter DATA_WIDTH    = 8,                   
    parameter PRODUCT_WIDTH = DATA_WIDTH * 2      
    input  wire [DATA_WIDTH-1:0] in1,         
    input  wire [DATA_WIDTH-1:0] in2,          
    output wire [PRODUCT_WIDTH-1:0] product 
);

    // Combinational multiplication
    assign product = in1 * in2;

endmodule
