module bin2gray #(
    parameter int WIDTH = 4
)(
    input logic [WIDTH-1:0] bin,
    output logic [WIDTH-1:0] gray
);

    always_comb begin 
        gray = (bin >> 1 ) ^ bin;
        
    end
endmodule
