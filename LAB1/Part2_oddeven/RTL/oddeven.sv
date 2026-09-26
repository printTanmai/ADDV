module oddeven (
    input  logic       clk,
    input  logic       reset,

    input  logic [7:0] data_in,
    input  logic       write_en,

    output logic [7:0] data_out,
    input  logic       read_en
);

    // write side
    logic even_wen, odd_wen;

    // even FIFO
    logic even_full, even_empty;
    logic [7:0] even_rdata;

    // odd FIFO
    logic odd_full, odd_empty;
    logic [7:0] odd_rdata;

    // read side
    logic even_ren, odd_ren;

    router #(
        .DATA_WIDTH(8)
    ) router_inst (
        .data_in  (data_in),
        .write_en (write_en),
        .w_even   (even_wen),
        .w_odd    (odd_wen)
    );

    sync_fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(40)
    ) even_fifo_inst (
        .clk      (clk),
        .rst      (reset),
        .data_in  (data_in),
        .write_en (even_wen),
        .data_out (even_rdata),
        .read_en  (even_ren),
        .full     (even_full),
        .empty    (even_empty)
    );

    sync_fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(40)
    ) odd_fifo_inst (
        .clk      (clk),
        .rst      (reset),
        .data_in  (data_in),
        .write_en (odd_wen),
        .data_out (odd_rdata),
        .read_en  (odd_ren),
        .full     (odd_full),
        .empty    (odd_empty)
    );

    read_arbiter #(
        .DATA_WIDTH(8)
    ) arbiter_inst (
        .clk        (clk),
        .rst        (reset),
        .read_en    (read_en),
        .even_empty (even_empty),
        .odd_empty  (odd_empty),
        .even_rdata (even_rdata),
        .odd_rdata  (odd_rdata),
        .even_ren   (even_ren),
        .odd_ren    (odd_ren),
        .data_out   (data_out)
    );

endmodule