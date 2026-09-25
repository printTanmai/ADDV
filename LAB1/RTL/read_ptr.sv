 
module read_ptr #(
    parameter int DEPTH = 8,
    parameter int ADDR_WIDTH = $clog2(DEPTH),
    parameter int PTR_WIDTH = ADDR_WIDTH + 1,
    parameter int ALMOST_EMPTY_LEVEL = DEPTH / 4
    
)(
    input logic r_clk,
    input logic r_rst_b,

    input logic read_en,

    input logic [PTR_WIDTH-1:0] wptr_gray_sync,

    output logic [ADDR_WIDTH-1:0] r_addr,
    output logic [PTR_WIDTH-1:0] rptr_bin,
    output logic [PTR_WIDTH-1:0] rptr_gray,

    output logic empty,
    output logic almost_empty

);

    logic [PTR_WIDTH-1:0] rptr_bin_next;

    logic [PTR_WIDTH-1:0] rptr_gray_next;

    logic [PTR_WIDTH-1:0] wptr_bin_sync;

    logic [PTR_WIDTH-1:0] used_entries;

    logic empty_next;
    logic almost_empty_next;

    //localparam int ALMOST_EMPTY_LEVEL = (DEPTH) / 4;

    always_comb begin
        rptr_bin_next = rptr_bin;

        if(read_en && !empty) begin     //empty_next
            rptr_bin_next = rptr_bin + 1'b1;
        end
    end

    bin2gray #(
        .WIDTH(PTR_WIDTH)
    ) rptr_bin_to_gray (
        .bin(rptr_bin_next),
        .gray(rptr_gray_next)
    );

    gray2bin #(
        .WIDTH(PTR_WIDTH)
    ) wptr_gray_to_bin (
        .gray(wptr_gray_sync),
        .bin(wptr_bin_sync)
    );

    always_comb begin
        r_addr = rptr_bin[ADDR_WIDTH-1:0]; ///bin_next
    end

    //empty detection
    always_comb begin
        empty_next = (rptr_gray_next == wptr_gray_sync);
    end

    //almost empty detection
    always_comb begin
        used_entries = wptr_bin_sync - rptr_bin_next;

        almost_empty_next = (used_entries <= ALMOST_EMPTY_LEVEL);
    end

    //read reg

    always_ff @(posedge r_clk or negedge r_rst_b) begin
        if(!r_rst_b) begin
            rptr_bin     <= '0;
            rptr_gray    <= '0;
            empty        <= 1'b1;
            almost_empty <= 1'b1;
        end

        else begin
            rptr_bin      <= rptr_bin_next;
            rptr_gray     <= rptr_gray_next;
            empty         <= empty_next;
            almost_empty  <= almost_empty_next;
        end
    end
endmodule    