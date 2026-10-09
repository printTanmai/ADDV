module pipe_if_id (
    input  logic        clk, reset,
    input  logic        en, clr,
    
    // Stage Inputs (Fetch)
    input  logic [31:0] instr_F,
    input  logic [31:0] pcplus4_F,
    input  logic        valid_F,
    
    // Stage Outputs (Decode)
    output logic [31:0] instr_D,
    output logic [31:0] pcplus4_D,
    output logic        valid_D
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            instr_D   <= '0;
            pcplus4_D <= '0;
            valid_D   <= 1'b0;
        end else if (clr) begin
            instr_D   <= '0;
            pcplus4_D <= '0;
            valid_D   <= 1'b0;
        end else if (en) begin
            instr_D   <= instr_F;
            pcplus4_D <= pcplus4_F;
            valid_D   <= valid_F;
        end
    end
endmodule
