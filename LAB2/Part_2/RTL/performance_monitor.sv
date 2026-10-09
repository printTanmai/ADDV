module performance_monitor (
    input  logic        clk, reset,
    input  logic        retire_valid,
    output logic [31:0] cycle_count,
    output logic [31:0] instruction_count
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cycle_count      <= 32'b0;
            instruction_count <= 32'b0;
        end else begin
            cycle_count <= cycle_count + 32'd1;
            if (retire_valid)
                instruction_count <= instruction_count + 32'd1;
        end
    end
endmodule
