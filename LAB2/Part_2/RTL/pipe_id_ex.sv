module pipe_id_ex (
    input  logic        clk, reset,
    input  logic        clr,
    
    // Control Inputs (Decode)
    input  logic        regwrite_D, memtoreg_D, memwrite_D,
    input  logic [2:0]  alucontrol_D,
    input  logic        alusrc_D, regdst_D,
    input  logic        branch_D,
    input  logic        valid_D, perfmon_D, perfmon_flag_D,
    
    // Data Inputs (Decode)
    input  logic [31:0] rd1_D, rd2_D, rd3_D,
    input  logic [4:0]  rs_D, rt_D, rd_D,
    input  logic [31:0] signimm_D,
    input  logic [31:0] pcplus4_D,

    // Control Outputs (Execute)
    output logic        regwrite_E, memtoreg_E, memwrite_E,
    output logic [2:0]  alucontrol_E,
    output logic        alusrc_E, regdst_E,
    output logic        branch_E,
    output logic        valid_E, perfmon_E, perfmon_flag_E,
    
    // Data Outputs (Execute)
    output logic [31:0] rd1_E, rd2_E, rd3_E,
    output logic [4:0]  rs_E, rt_E, rd_E,
    output logic [31:0] signimm_E,
    output logic [31:0] pcplus4_E
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            regwrite_E   <= 1'b0;
            memtoreg_E   <= 1'b0;
            memwrite_E   <= 1'b0;
            alucontrol_E <= 3'b0;
            alusrc_E     <= 1'b0;
            regdst_E     <= 1'b0;
            branch_E     <= 1'b0;
            valid_E      <= 1'b0;
            perfmon_E    <= 1'b0;
            perfmon_flag_E <= 1'b0;
            rd1_E        <= '0;
            rd2_E        <= '0;
            rd3_E        <= '0;
            rs_E         <= '0;
            rt_E         <= '0;
            rd_E         <= '0;
            signimm_E    <= '0;
            pcplus4_E    <= '0;
        end else if (clr) begin
            regwrite_E   <= 1'b0;
            memtoreg_E   <= 1'b0;
            memwrite_E   <= 1'b0;
            alucontrol_E <= 3'b0;
            alusrc_E     <= 1'b0;
            regdst_E     <= 1'b0;
            branch_E     <= 1'b0;
            valid_E      <= 1'b0;
            perfmon_E    <= 1'b0;
            perfmon_flag_E <= 1'b0;
            rd1_E        <= '0;
            rd2_E        <= '0;
            rd3_E        <= '0;
            rs_E         <= '0;
            rt_E         <= '0;
            rd_E         <= '0;
            signimm_E    <= '0;
            pcplus4_E    <= '0;
        end else begin
            regwrite_E   <= regwrite_D;
            memtoreg_E   <= memtoreg_D;
            memwrite_E   <= memwrite_D;
            alucontrol_E <= alucontrol_D;
            alusrc_E     <= alusrc_D;
            regdst_E     <= regdst_D;
            branch_E     <= branch_D;
            valid_E      <= valid_D;
            perfmon_E    <= perfmon_D;
            perfmon_flag_E <= perfmon_flag_D;
            rd1_E        <= rd1_D;
            rd2_E        <= rd2_D;
            rd3_E        <= rd3_D;
            rs_E         <= rs_D;
            rt_E         <= rt_D;
            rd_E         <= rd_D;
            signimm_E    <= signimm_D;
            pcplus4_E    <= pcplus4_D;
        end
    end
endmodule
