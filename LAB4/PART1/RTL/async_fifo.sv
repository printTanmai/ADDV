module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 8,

    parameter int ADDR_WIDTH =   $clog2(DEPTH),
    parameter int PTR_WIDTH  = ADDR_WIDTH + 1,

    parameter int ALMOST_FULL_LEVEL  = (DEPTH * 3) / 4,
    parameter int ALMOST_EMPTY_LEVEL = DEPTH / 4
)(
    fifo_if.DUT fifo
);

    // Binary pointers
    logic [PTR_WIDTH-1:0] wptr_bin;
    logic [PTR_WIDTH-1:0] rptr_bin;

    // Gray-code pointers
    logic [PTR_WIDTH-1:0] wptr_gray;
    logic [PTR_WIDTH-1:0] rptr_gray;

    // Synchronized Gray-code pointers
    logic [PTR_WIDTH-1:0] wptr_gray_sync;
    logic [PTR_WIDTH-1:0] rptr_gray_sync;

    // Memory controls
    logic write_en;
    logic read_en;

    // Memory addresses
    logic [ADDR_WIDTH-1:0] w_addr;
    logic [ADDR_WIDTH-1:0] r_addr;

    // Memory data aliases for .*
    logic [DATA_WIDTH-1:0] w_data;
    logic [DATA_WIDTH-1:0] r_data;

    // Clock aliases for .*
    logic w_clk;
    logic r_clk;

    logic w_rst_b;
    logic r_rst_b;

    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;

    assign fifo.full = full;
    assign fifo.empty = empty;
    assign fifo.almost_full = almost_full;
    assign fifo.almost_empty = almost_empty;

    // Interface aliases used by fifo_mem with .*
    assign w_clk  = fifo.w_clk;
    assign r_clk  = fifo.r_clk;

    assign w_rst_b = fifo.w_rst_b;
    assign r_rst_b = fifo.r_rst_b;

    assign w_data = fifo.w_data;

    assign fifo.r_data = r_data;

    //always_comb begin
    assign write_en = fifo.write_en && !full;
    assign read_en  = fifo.read_en  && !empty;
    //end

    // Write pointer logic

    write_ptr #(
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH(PTR_WIDTH),
        .ALMOST_FULL_LEVEL(ALMOST_FULL_LEVEL)
    ) write_ptr_inst (.*);

    // Read pointer logic

    read_ptr #(
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH(PTR_WIDTH),
        .ALMOST_EMPTY_LEVEL(ALMOST_EMPTY_LEVEL)
    ) read_ptr_inst (.*);

    // Synchronize pointer write to read 
    synchronizer #(
        .WIDTH(PTR_WIDTH)
    ) wptr_sync_inst (
        .clk(r_clk),
        .rst_b(r_rst_b),
        .async_ptr(wptr_gray),
        .sync_ptr(wptr_gray_sync)
    );

    // Synchronize pointer read to write 
    synchronizer #(
        .WIDTH(PTR_WIDTH)
    ) rptr_sync_inst (
        .clk(w_clk),
        .rst_b(w_rst_b),
        .async_ptr(rptr_gray),
        .sync_ptr(rptr_gray_sync)
    );

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_mem_inst (.*);

endmodule

