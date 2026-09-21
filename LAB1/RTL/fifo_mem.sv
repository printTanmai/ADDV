module fifo_mem #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 3, //$clog2(DEPTH)
    parameter int DEPTH      = 8
)(
    input logic             w_clk,
    input logic             r_clk,
    input logic             write_en,
    input logic             read_en,

    input logic [ADDR_WIDTH-1:0] w_addr,
    input logic [ADDR_WIDTH-1:0] r_addr,

    input logic [ADDR_WIDTH-1:0] w_data,
    output logic [ADDR_WIDTH-1:0] r_data
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge w_clk)
    begin
        if(write_en)
            mem[w_addr] <= w_data;
    end

    always_ff @(posedge r_clk)
    begin
        if(read_en)
            r_data <= mem[r_addr];
    end

endmodule