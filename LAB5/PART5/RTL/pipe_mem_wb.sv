module pipe_mem_wb (
    input  logic        clk, reset,
    
    // Control Inputs (Memory)
    input  logic        regwrite_M, memtoreg_M, memwrite_M,
    
    // Data Inputs (Memory)
    input  logic [31:0] readdata_M, aluout_M, writedata_M,
    input  logic [4:0]  writereg_M,
    input  logic [31:0] instr_M, pc_M,
    input  logic        valid_M,
    
    // Control Outputs (Writeback)
    output logic        regwrite_W, memtoreg_W, memwrite_W,
    
    // Data Outputs (Writeback)
    output logic [31:0] readdata_W, aluout_W, writedata_W,
    output logic [4:0]  writereg_W,
    output logic [31:0] instr_W, pc_W,
    output logic        valid_W
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            regwrite_W <= 1'b0;
            memtoreg_W <= 1'b0;
            memwrite_W <= 1'b0;
            readdata_W <= '0;
            aluout_W   <= '0;
            writedata_W <= '0;
            writereg_W <= '0;
            instr_W    <= '0;
            pc_W       <= '0;
            valid_W    <= 1'b0;
        end else begin
            regwrite_W <= regwrite_M;
            memtoreg_W <= memtoreg_M;
            memwrite_W <= memwrite_M;
            readdata_W <= readdata_M;
            aluout_W   <= aluout_M;
            writedata_W <= writedata_M;
            writereg_W <= writereg_M;
            instr_W    <= instr_M;
            pc_W       <= pc_M;
            valid_W    <= valid_M;
        end
    end
endmodule
