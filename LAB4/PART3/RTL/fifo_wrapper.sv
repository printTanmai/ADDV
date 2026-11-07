module fifo_wrapper #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 8,

    parameter int ADDR_WIDTH = $clog2(DEPTH),
    parameter int PTR_WIDTH = ADDR_WIDTH + 1,

    parameter int ALMOST_FULL_LEVEL = (DEPTH * 3) / 4,
    parameter int ALMOST_EMPTY_LEVEL = DEPTH / 4
)(
    input logic w_clk,
    input logic r_clk,

    input logic w_rst_b,
    input logic r_rst_b,

    input logic write_en,
    input logic read_en,

    input logic [DATA_WIDTH-1: 0] w_data,
    output logic [DATA_WIDTH-1: 0] r_data,

    output logic full,
    output logic empty,
    output logic almost_full,
    output logic almost_empty
);

    fifo_write_if #(.DATA_WIDTH(DATA_WIDTH)) write_fifo(.w_clk(w_clk));
    fifo_read_if #(.DATA_WIDTH(DATA_WIDTH)) read_fifo(.r_clk(r_clk));

    assign write_fifo.w_rst_b = w_rst_b;
    assign write_fifo.write_en = write_en;
    assign write_fifo.w_data = w_data;
    assign full = write_fifo.full;
    assign almost_full = write_fifo.almost_full;

    assign read_fifo.r_rst_b = r_rst_b;
    assign read_fifo.read_en = read_en;
    assign r_data = read_fifo.r_data;
    assign empty = read_fifo.empty;
    assign almost_empty = read_fifo.almost_empty;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH(PTR_WIDTH),
        .ALMOST_FULL_LEVEL(ALMOST_FULL_LEVEL),
        .ALMOST_EMPTY_LEVEL(ALMOST_EMPTY_LEVEL)
    ) async_fifo_inst (
        .write_fifo(write_fifo),
        .read_fifo(read_fifo)
    );

endmodule
