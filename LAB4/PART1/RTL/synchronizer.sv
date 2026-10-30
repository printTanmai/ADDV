module synchronizer #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_b,
    input  logic [WIDTH-1:0] async_ptr,
    output logic [WIDTH-1:0] sync_ptr
);

    logic [WIDTH-1:0] sync_ff1;

    always_ff @( posedge clk or negedge rst_b) begin 
        if(!rst_b) begin
            sync_ff1 <= '0;
            sync_ptr <= '0;
        end

        else begin
            sync_ff1 <= async_ptr;
            sync_ptr <= sync_ff1;
        end
        
    end
endmodule    