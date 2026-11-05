module router #(
    parameter DATA_WIDTH = 8
)(
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  write_en,

    output logic                  w_even,
    output logic                  w_odd
);

    //the least-significant bit selects the destination FIFO
    logic is_odd;
    assign is_odd = data_in[0];

    assign w_even = write_en && !is_odd;
    assign w_odd  = write_en && is_odd;

endmodule
