module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 40,
    parameter int ADDR_WIDTH = $clog2(FIFO_DEPTH),
    parameter int PTR_WIDTH  = ADDR_WIDTH + 1
)(
    input  logic                  clk,
    input  logic                  rst,

    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  write_en,

    output logic [DATA_WIDTH-1:0] data_out,
    input  logic                  read_en,

    output logic                  full,
    output logic                  empty
);

    logic [PTR_WIDTH-1:0]  wptr, rptr;
    logic [PTR_WIDTH-1:0]  wptr_next, rptr_next;
    logic [ADDR_WIDTH-1:0] w_addr, r_addr;
    logic full_next, empty_next;

    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    assign w_addr = wptr[ADDR_WIDTH-1:0];
    assign r_addr = rptr[ADDR_WIDTH-1:0];

    //write pointer with explicit wrap for a non-power-of-two FIFO depth
    always_comb begin
        wptr_next = wptr;

        if(write_en && !full) begin
            if(w_addr == FIFO_DEPTH-1)
                wptr_next = {~wptr[PTR_WIDTH-1], {ADDR_WIDTH{1'b0}}};
            else
                wptr_next = wptr + 1'b1;
        end
    end

    //read pointer with the same explicit wrap
    always_comb begin
        rptr_next = rptr;

        if(read_en && !empty) begin
            if(r_addr == FIFO_DEPTH-1)
                rptr_next = {~rptr[PTR_WIDTH-1], {ADDR_WIDTH{1'b0}}};
            else
                rptr_next = rptr + 1'b1;
        end
    end

    //both next pointers are used because this is a single-clock FIFO
    assign full_next =
        (wptr_next[ADDR_WIDTH-1:0] == rptr_next[ADDR_WIDTH-1:0]) &&
        (wptr_next[PTR_WIDTH-1] != rptr_next[PTR_WIDTH-1]);

    assign empty_next = (rptr_next == wptr_next);

    //show the current FIFO head so the arbiter can sample it on a read edge
    assign data_out = mem[r_addr];

    always @(posedge clk) begin
        if(rst) begin
            wptr  <= '0;
            rptr  <= '0;
            full  <= 1'b0;
            empty <= 1'b1;
        end
        else begin
            wptr  <= wptr_next;
            rptr  <= rptr_next;
            full  <= full_next;
            empty <= empty_next;

            if(write_en && !full)
                mem[w_addr] <= data_in;
        end
    end

endmodule
