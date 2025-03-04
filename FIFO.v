// Nonblocking FIFO memory array 
module fifoArray (
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire re_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire empty,
    output wire full
);

parameter DEPTH = 32; // Depth of the FIFO
parameter DATA_WIDTH = 8; // Width of the data bus
parameter PTR_SIZE = 5;

reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
reg [PTR_SIZE-1:0] wr_ptr;
reg [PTR_SIZE-1:0] rd_ptr;
reg empty_reg;
reg full_reg;

// write process
always @ (posedge clk or posedge rst) begin
    if(rst) wr_ptr <= 0;
    else if (wr_en && !full_reg) wr_ptr <= wr_ptr + 1;
end

always @ (posedge clk or posedge rst) begin
    if (rst) empty_reg <= 1
    else if (wr_en && !full_reg && (wr_ptr != rd_ptr)) empty_reg <= 0;
    else if (re_en && (wr_ptr == rd_ptr + 1)) empty_reg <= 1;
end

always @ (posedge clk or posedge rst) begin
    if (rst) full_reg <= 0;
    else if (wr_en && (wr_ptr == rd_ptr)) full_reg <= 1;
    else if (re_en && !empty_reg) full_reg <= 0
end

// Read process
always @ (posedge clk or posedge rst) begin
    if (rst) rd_ptr <= 0;
    else if (re_en && !empty_reg) rd_ptr <= rd_ptr + 1;
end

// Data storage
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        integer i;
        initial begin
            for (i = 0; i < DATA_WIDTH; i = i + 1)
                memory[i] = {DATA_WIDTH{1'bz}};      
        end
    end
    else if (wr_en && !full_reg) memory[wr_ptr] <= data_in;
end

// Data retrieval
assign data_out = (empty_reg) ? {DATA_WIDTH{1'bx}} : memory[rd_ptr];

// Status
assign empty = empty_reg;
assign full = full_reg;

endmodule
