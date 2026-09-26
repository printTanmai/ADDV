module read_arbiter #(
    parameter int DATA_WIDTH = 8
)(
    input  logic                  clk,
    input  logic                  rst,

    input  logic                  read_en,

    input  logic                  even_empty,
    input  logic                  odd_empty,
    input  logic [DATA_WIDTH-1:0] even_rdata,
    input  logic [DATA_WIDTH-1:0] odd_rdata,

    output logic                  even_ren,
    output logic                  odd_ren,
    output logic [DATA_WIDTH-1:0] data_out
);

    logic expect_even;   // 1 = next output should be even, 0 = next should be odd

    logic even_has_data;
    logic odd_has_data;
    logic can_output;

    assign even_has_data = !even_empty;
    assign odd_has_data  = !odd_empty;

    assign can_output = read_en && ((expect_even && even_has_data) ||
                                     (!expect_even && odd_has_data));

    assign even_ren = can_output && expect_even;
    assign odd_ren  = can_output && !expect_even;

    always_ff @(posedge clk) begin
        if (rst) begin
            expect_even <= 1'b1;
            data_out    <= '0;
        end else if (can_output) begin
            data_out    <= expect_even ? even_rdata : odd_rdata;
            expect_even <= !expect_even;
        end
        // else: hold data_out and expect_even, this is the idle case
    end

endmodule