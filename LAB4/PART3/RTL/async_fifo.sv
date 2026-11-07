module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 8,

    parameter int ADDR_WIDTH =   $clog2(DEPTH),
    parameter int PTR_WIDTH  = ADDR_WIDTH + 1,

    parameter int ALMOST_FULL_LEVEL  = (DEPTH * 3) / 4,
    parameter int ALMOST_EMPTY_LEVEL = DEPTH / 4
)(
    fifo_write_if.DUT write_fifo,
    fifo_read_if.DUT read_fifo
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

`ifdef FIFO_SIMULATION
    int drop_every;
    int attempted_write_count;
    logic drop_write;
`endif

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

    assign write_fifo.full = full;
    assign write_fifo.almost_full = almost_full;
    assign read_fifo.empty = empty;
    assign read_fifo.almost_empty = almost_empty;

    // Interface aliases used by fifo_mem with .*
    assign w_clk  = write_fifo.w_clk;
    assign r_clk  = read_fifo.r_clk;

    assign w_rst_b = write_fifo.w_rst_b;
    assign r_rst_b = read_fifo.r_rst_b;

    assign w_data = write_fifo.w_data;

    assign read_fifo.r_data = r_data;

`ifdef FIFO_SIMULATION
    initial begin
        drop_every = 0;
        if (!$value$plusargs("DROP_EVERY=%d", drop_every))
            drop_every = 0;
    end

    always_comb begin
        drop_write = (drop_every > 0) && write_fifo.write_en && !full &&
                     (((attempted_write_count + 1) % drop_every) == 0);
    end

    always_ff @(posedge w_clk or negedge w_rst_b) begin
        if (!w_rst_b)
            attempted_write_count <= 0;
        else if (write_fifo.write_en && !full)
            attempted_write_count <= attempted_write_count + 1;
    end

    assign write_en = write_fifo.write_en && !full && !drop_write;
`else
    assign write_en = write_fifo.write_en && !full;
`endif
    assign read_en  = read_fifo.read_en  && !empty;

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

