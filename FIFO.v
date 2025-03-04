module fifo #(
    parameter DEPTH = 32,         // Depth of the FIFO
    parameter DATA_WIDTH = 8,     // Width of the data bus
    parameter PTR_SIZE = 5
) (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   wr_en,
    input  wire                   re_en,
    input  wire [DATA_WIDTH-1:0]  data_in,
    output wire [DATA_WIDTH-1:0]  data_out,
    output wire                   empty,
    output wire                   full,
    output wire [PTR_SIZE:0]      count  // Current number of items in the FIFO
);

    // FIFO memory array
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    reg [PTR_SIZE-1:0] wr_ptr;
    reg [PTR_SIZE-1:0] rd_ptr;
    reg empty_reg;
    reg full_reg;
    
    // Count register (one extra bit to count up to DEPTH)
    reg [PTR_SIZE:0] count_reg;

    // Write pointer process
    always @ (posedge clk or posedge rst) begin
        if (rst)
            wr_ptr <= 0;
        else if (wr_en && !full_reg)
            wr_ptr <= wr_ptr + 1;
    end

    // Empty flag update
    always @ (posedge clk or posedge rst) begin
        if (rst)
            empty_reg <= 1;
        else if (wr_en && !full_reg && (wr_ptr != rd_ptr))
            empty_reg <= 0;
        else if (re_en && (wr_ptr == rd_ptr + 1))
            empty_reg <= 1;
    end

    // Full flag update
    always @ (posedge clk or posedge rst) begin
        if (rst)
            full_reg <= 0;
        else if (wr_en && (wr_ptr == rd_ptr))
            full_reg <= 1;
        else if (re_en && !empty_reg)
            full_reg <= 0;
    end

    // Read pointer process
    always @ (posedge clk or posedge rst) begin
        if (rst)
            rd_ptr <= 0;
        else if (re_en && !empty_reg)
            rd_ptr <= rd_ptr + 1;
    end

    // Data storage process
    integer i;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1)
                memory[i] <= {DATA_WIDTH{1'bz}};
        end else if (wr_en && !full_reg)
            memory[wr_ptr] <= data_in;
    end

    // Data retrieval
    assign data_out = (empty_reg) ? {DATA_WIDTH{1'bx}} : memory[rd_ptr];

    // Status outputs
    assign empty = empty_reg;
    assign full  = full_reg;

    always @ (posedge clk or posedge rst) begin
        if (rst)
            count_reg <= 0;
        else begin
            if (wr_en && !full_reg && !(re_en && !empty_reg))
                count_reg <= count_reg + 1;
            else if (re_en && !empty_reg && !(wr_en && !full_reg))
                count_reg <= count_reg - 1;
            else
                count_reg <= count_reg;
        end
    end

    assign count = count_reg;

endmodule
