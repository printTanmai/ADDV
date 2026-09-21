module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 8,

    parameter int ALMOST_FULL_LEVEL = (DEPTH * 3)/4,
    parameter int ALMOST_EMPTY_LEVEL = (DEPTH)/4,

    parameter int ADDR_WIDTH = 3,  // $clog2(DEPTH)
    parameter int PTR_WIDTH = ADDR_WIDTH + 1
)(
    fifo_if.DUT fifo
);  
    //BInary pointer
    logic [PTR_WIDTH-1:0] wbin;
    logic [PTR_WIDTH-1:0] rbin;

    logic [PTR_WIDTH-1:0] wbin_next;
    logic [PTR_WIDTH-1:0] rbin_next;

    //Gray pointer
    logic [PTR_WIDTH-1:0] wgray;
    logic [PTR_WIDTH-1:0] rgray;

    logic [PTR_WIDTH-1:0] wgray_next;
    logic [PTR_WIDTH-1:0] rgray_next;

    //Sync gray pointers

    logic [PTR_WIDTH-1:0] wgray;
    logic [PTR_WIDTH-1:0] rgray;

    logic [PTR_WIDTH-1:0] wgray_next;
    logic [PTR_WIDTH-1:0] rgray_next;

    //fifo count

    logic [PTR_WIDTH-1:0] write_count;
    logic [PTR_WIDTH-1:0] read_count;

    // Internal ctl
    logic write_allow;
    logic read_allow;
    logic full_next;
    logic epty_next;

    logic [ADDR_WIDTH-1:0] w_addr;
    logic [ADDR_WIDTH-1:0] r_addr;

    logic [ADDR_WIDTH-1:0] w_data;
    logic [ADDR_WIDTH-1:0] r_data;

    logic write_en;
    logic read_en;

    // gray to BIN

    function automatic logic [PTR_WIDTH-1:0] gray2bin(
        input log
    )

