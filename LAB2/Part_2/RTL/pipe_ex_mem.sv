module pipe_ex_mem (
    input  logic        clk, reset,
    
    // Control Inputs (Execute)
    input  logic        regwrite_E, memtoreg_E, memwrite_E,
    input  logic        valid_E, perfmon_E, perfmon_flag_E,
    
    // Data Inputs (Execute)
    input  logic [31:0] aluout_E, writedata_E,
    input  logic [4:0]  writereg_E,
    
    // Control Outputs (Memory)
    output logic        regwrite_M, memtoreg_M, memwrite_M,
    output logic        valid_M, perfmon_M, perfmon_flag_M,
    
    // Data Outputs (Memory)
    output logic [31:0] aluout_M, writedata_M,
    output logic [4:0]  writereg_M
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            regwrite_M  <= 1'b0;
            memtoreg_M  <= 1'b0;
            memwrite_M  <= 1'b0;
            valid_M     <= 1'b0;
            perfmon_M   <= 1'b0;
            perfmon_flag_M <= 1'b0;
            aluout_M    <= '0;
            writedata_M <= '0;
            writereg_M  <= '0;
        end else begin
            regwrite_M  <= regwrite_E;
            memtoreg_M  <= memtoreg_E;
            memwrite_M  <= memwrite_E;
            valid_M     <= valid_E;
            perfmon_M   <= perfmon_E;
            perfmon_flag_M <= perfmon_flag_E;
            aluout_M    <= aluout_E;
            writedata_M <= writedata_E;
            writereg_M  <= writereg_E;
        end
    end
endmodule
