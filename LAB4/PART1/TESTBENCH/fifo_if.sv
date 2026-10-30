interface fifo_if #(
    parameter int DATA_WIDTH = 8
);
    logic w_clk;
    logic r_clk;
    
    logic w_rst_b;
    logic r_rst_b;

    logic write_en;
    logic read_en;

    logic [DATA_WIDTH-1: 0] w_data;
    logic [DATA_WIDTH-1: 0] r_data;

    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;

    modport DUT (
    input w_clk,
    input r_clk,
    input w_rst_b,
    input r_rst_b,
    input write_en,
    input read_en,
    input w_data,

    output r_data,
    output full,
    output empty,
    output almost_full,
    output almost_empty
    );

    modport TB (  //tb
    output w_clk,
    output r_clk,
    output w_rst_b,
    output r_rst_b,
    output write_en,
    output read_en,
    output w_data,

    input r_data,
    input full,
    input empty,
    input almost_full,
    input almost_empty
    );
    
    
endinterface

