module component (
    input  wire         clk,
    input  wire         rst,
    
    // Input data for each FIFO (32-bit wide)
    input  wire [31:0]  fifo1_data_in,
    input  wire [31:0]  fifo2_data_in,
    input  wire [31:0]  fifo3_data_in,
    
    // FIFO control signals
    input  wire         fifo1_write_en,
    input  wire         fifo2_write_en,
    input  wire         fifo3_write_en,
    input  wire         fifo1_read_en,
    input  wire         fifo2_read_en,
    input  wire         fifo3_read_en,
    
    // Result output (32-bit)
    output wire [31:0]  result_out,
    
    // Status signals
    output wire         fifo1_empty,
    output wire         fifo2_empty,
    output wire         fifo3_empty,
    output wire         fifo1_full,
    output wire         fifo2_full,
    output wire         fifo3_full
);

    // Internal FIFO outputs
    wire [31:0] fifo1_data_out;
    wire [31:0] fifo2_data_out;
    wire [31:0] fifo3_data_out;
    
    // Intermediate product from multiplier (32 bits)
    wire [31:0] mult_result;
    
    // Instantiate FIFO1 (Pink FIFO)
    fifo #(
        .DEPTH(16),
        .DATA_WIDTH(32),
        .PTR_SIZE(5)
    ) fifo1_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(fifo1_write_en),
        .re_en(fifo1_read_en),
        .data_in(fifo1_data_in),
        .data_out(fifo1_data_out),
        .empty(fifo1_empty),
        .full(fifo1_full),
        .count()  // Not used in this top-level module
    );
    
    // Instantiate FIFO2 (Green FIFO)
    fifo #(
        .DEPTH(16),
        .DATA_WIDTH(32),
        .PTR_SIZE(5)
    ) fifo2_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(fifo2_write_en),
        .re_en(fifo2_read_en),
        .data_in(fifo2_data_in),
        .data_out(fifo2_data_out),
        .empty(fifo2_empty),
        .full(fifo2_full),
        .count()
    );
    
    // Instantiate FIFO3 (Purple FIFO)
    fifo #(
        .DEPTH(16),
        .DATA_WIDTH(32),
        .PTR_SIZE(5)
    ) fifo3_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(fifo3_write_en),
        .re_en(fifo3_read_en),
        .data_in(fifo3_data_in),
        .data_out(fifo3_data_out),
        .empty(fifo3_empty),
        .full(fifo3_full),
        .count()
    );
    
    // Multiplier instance: multiplies FIFO1 and FIFO2 outputs.
    // Here, we use a 32-bit multiplier whose product is taken as the lower 32 bits.
    multiplier #(
        .DATA_WIDTH(32),
        .PRODUCT_WIDTH(32)
    ) mult_inst (
        .in1(fifo1_data_out),
        .in2(fifo2_data_out),
        .product(mult_result)
    );
    
    // Adder instance: adds the multiplication result to FIFO3 output.
    // The adder is set to 32-bit width for both inputs and output (modulo arithmetic).
    adder #(
        .DATA_WIDTH(32),
        .SUM_WIDTH(32)
    ) adder_inst (
        .in1(mult_result),
        .in2(fifo3_data_out),
        .sum(result_out)
    );

endmodule
