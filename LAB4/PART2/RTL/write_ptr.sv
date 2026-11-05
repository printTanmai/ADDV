module write_ptr #(
    parameter int DEPTH = 8,
    parameter int ADDR_WIDTH = $clog2(DEPTH),
    parameter int PTR_WIDTH = ADDR_WIDTH + 1,
    parameter int ALMOST_FULL_LEVEL = DEPTH / 4
    
)(
    input logic w_clk,
    input logic w_rst_b,

    input logic write_en,

    input logic [PTR_WIDTH-1:0] rptr_gray_sync,

    output logic [ADDR_WIDTH-1:0] w_addr,
    output logic [PTR_WIDTH-1:0] wptr_bin,
    output logic [PTR_WIDTH-1:0] wptr_gray,

    output logic full,
    output logic almost_full

);

    logic [PTR_WIDTH-1:0] wptr_bin_next;

    logic [PTR_WIDTH-1:0] wptr_gray_next;

    logic [PTR_WIDTH-1:0] rptr_bin_sync;

    logic [PTR_WIDTH-1:0] used_entries;

    logic full_next;
    logic almost_full_next;

    //localparam int ALMOST_FULL_LEVEL = (DEPTH * 3) / 4;

    always_comb begin
        wptr_bin_next = wptr_bin;

        if(write_en && !full) begin     //fulll_next
            wptr_bin_next = wptr_bin + 1'b1;
        end
    end

    bin2gray #(
        .WIDTH(PTR_WIDTH)
    ) wptr_bin_to_gray (
        .bin(wptr_bin_next),
        .gray(wptr_gray_next)
    );

    gray2bin #(
        .WIDTH(PTR_WIDTH)
    ) rptr_gray_to_bin (
        .gray(rptr_gray_sync),
        .bin(rptr_bin_sync)
    );

    always_comb begin
        w_addr = wptr_bin[ADDR_WIDTH-1:0]; ///bin_next
    end

    //full detection
    always_comb begin
        full_next = (wptr_gray_next == 
                    {~rptr_gray_sync [PTR_WIDTH-1:PTR_WIDTH-2],
                     rptr_gray_sync [PTR_WIDTH-3:0]
                    });
    end

    //almost full detection
    always_comb begin
        used_entries = wptr_bin_next - rptr_bin_sync;

        almost_full_next = (used_entries >= ALMOST_FULL_LEVEL);
    end

    //write reg

    always_ff @(posedge w_clk or negedge w_rst_b) begin
        if(!w_rst_b) begin
            wptr_bin <= '0;
            wptr_gray <= '0;
            full <= '0;
            almost_full <= '0;
        end

        else begin
            wptr_bin <= wptr_bin_next;
            wptr_gray <= wptr_gray_next;
            full <= full_next;
            almost_full <= almost_full_next;
        end
    end
endmodule    