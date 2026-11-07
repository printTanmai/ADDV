interface fifo_write_if #(
    parameter int DATA_WIDTH = 8
)
(   input logic w_clk
);  
    logic w_rst_b;
    logic write_en;

    logic [DATA_WIDTH-1: 0] w_data;

    logic full;
    logic almost_full;

    modport DUT (
    input w_clk,
    input w_rst_b,
    input write_en,
    input w_data,

    output full,
    output almost_full
    );

    modport MONITOR (  //tb
    input w_clk,
    input w_rst_b,
    input write_en,
    input w_data,
    input full,
    input almost_full
    );
endinterface

interface fifo_read_if #(
    parameter int DATA_WIDTH = 8
)
(   input logic r_clk
);
    logic r_rst_b;  
    logic read_en;
    
    logic [DATA_WIDTH-1:0] r_data;

    logic empty;
    logic almost_empty;

    modport DUT (
    input r_clk,
    input r_rst_b,
    input read_en,

    output r_data,
    output empty,
    output almost_empty
    );

    modport MONITOR (  //tb
    input r_clk,
    input r_rst_b,
    input read_en,

    input r_data,
    input empty,
    input almost_empty
    );
endinterface

