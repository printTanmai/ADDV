module pipe_mem_wb (
    input  logic        clk, reset,
    
    // Control Inputs (Memory)
    input  logic        regwrite_M, memtoreg_M,
    input  logic        valid_M, perfmon_M, perfmon_flag_M,
    
    // Data Inputs (Memory)
    input  logic [31:0] readdata_M, aluout_M,
    input  logic [4:0]  writereg_M,
    
    // Control Outputs (Writeback)
    output logic        regwrite_W, memtoreg_W,
    output logic        valid_W, perfmon_W, perfmon_flag_W,
    
    // Data Outputs (Writeback)
    output logic [31:0] readdata_W, aluout_W,
    output logic [4:0]  writereg_W
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            regwrite_W <= 1'b0;
            memtoreg_W <= 1'b0;
            valid_W    <= 1'b0;
            perfmon_W  <= 1'b0;
            perfmon_flag_W <= 1'b0;
            readdata_W <= '0;
            aluout_W   <= '0;
            writereg_W <= '0;
        end else begin
            regwrite_W <= regwrite_M;
            memtoreg_W <= memtoreg_M;
            valid_W    <= valid_M;
            perfmon_W  <= perfmon_M;
            perfmon_flag_W <= perfmon_flag_M;
            readdata_W <= readdata_M;
            aluout_W   <= aluout_M;
            writereg_W <= writereg_M;
        end
    end
endmodule
