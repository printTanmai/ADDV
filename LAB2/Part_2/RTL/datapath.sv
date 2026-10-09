module datapath (
    input  logic        clk, reset,

    // Controller Inputs (ID)
    input  logic        memtoreg_D, memwrite_D,
    input  logic        alusrc_D, regdst_D,
    input  logic        regwrite_D, jump_D, branch_D,
    input  logic [2:0]  alucontrol_D,

    // Hazard Unit Interface
    input  logic        stallF, stallD,
    input  logic        flushD, flushE,
    input  logic [1:0]  forwardaE, forwardbE, forwardcE,

    // Memory Interfaces
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic [31:0] aluout, writedata,
    input  logic [31:0] readdata,
    output logic        memwrite,

    // Status Outputs
    output logic [5:0]  op_D, funct_D,
    output logic [4:0]  rs_D, rt_D, rd_D,
    output logic [4:0]  rs_E, rt_E, rd_E, writereg_E,
    output logic [4:0]  writereg_M, writereg_W,
    output logic        regwrite_E, regwrite_M, regwrite_W,
    output logic        memtoreg_E, perfmon_E, pcsrc_E
);

    // Fetch (IF)
    logic [31:0] pcnext_F, pcnextbr_F, pcplus4_F, pc_F;
    logic [31:0] instr_F;

    // Decode (ID)
    logic [31:0] instr_D, pcplus4_D;
    logic [31:0] rd1_D, rd2_D;
    logic [31:0] signimm_D;
    logic [31:0] rd3_D;
    logic        valid_D, valid_E, valid_M, valid_W;
    logic        perfmon_D, perfmon_M, perfmon_W;
    logic        perfmon_flag_D, perfmon_flag_E, perfmon_flag_M, perfmon_flag_W;
    logic [31:0] cycle_count, instruction_count;

    // Execute (EX)
    logic        memwrite_E, branch_E;
    logic [2:0]  alucontrol_E;
    logic        alusrc_E, regdst_E;
    logic [31:0] rd1_E, rd2_E, rd3_E, signimm_E, signimmsh_E, pcplus4_E;
    logic [31:0] srca_E, writedata_E, srcb_E, old_rd_E;
    logic [31:0] aluout_E, pcbranch_E;
    logic        zero_E;

    // Memory (MEM)
    logic        memtoreg_M;
    logic [31:0] aluout_M, writedata_M, readdata_M;

    // Writeback (WB)
    logic        memtoreg_W;
    logic [31:0] readdata_W, aluout_W, normal_result_W, result_W;

    // 1. FETCH STAGE
    flopenc #(32) pcreg (
        .clk(clk), .reset(reset),
        .en(~stallF),
        .d(pcnext_F),
        .q(pc_F)
    );

    adder pcadd1 (
        .a(pc_F), .b(32'd4), .y(pcplus4_F)
    );

    mux2 #(32) pcbrmux (
        .d0(pcplus4_F), .d1(pcbranch_E), .s(pcsrc_E), .y(pcnextbr_F)
    );

    mux2 #(32) pcmux (
        .d0(pcnextbr_F),
        .d1({pcplus4_D[31:28], instr_D[25:0], 2'b00}),
        .s(jump_D),
        .y(pcnext_F)
    );

    assign pc      = pc_F;
    assign instr_F = instr;

    pipe_if_id reg_if_id (
        .clk(clk), .reset(reset),
        .en(~stallD), .clr(flushD),
        .instr_F(instr_F), .pcplus4_F(pcplus4_F),
        .valid_F(1'b1),
        .instr_D(instr_D), .pcplus4_D(pcplus4_D), .valid_D(valid_D)
    );

    // 2. DECODE STAGE
    assign op_D    = instr_D[31:26];
    assign funct_D = instr_D[5:0];
    assign rs_D    = instr_D[25:21];
    assign rt_D    = instr_D[20:16];
    assign rd_D    = instr_D[15:11];
    assign perfmon_D = (op_D == 6'b011101);
    assign perfmon_flag_D = instr_D[0];

    regfile rf (
        .clk(clk), .we3(regwrite_W),
        .ra1(rs_D), .ra2(rt_D), .ra3(rd_D),
        .wa3(writereg_W), .wd3(result_W),
        .rd1(rd1_D), .rd2(rd2_D), .rd3(rd3_D)
    );

    signext se (
        .a(instr_D[15:0]),
        .y(signimm_D)
    );

    pipe_id_ex reg_id_ex (
        .clk(clk), .reset(reset), .clr(flushE),
        .regwrite_D(regwrite_D), .memtoreg_D(memtoreg_D), .memwrite_D(memwrite_D),
        .alucontrol_D(alucontrol_D), .alusrc_D(alusrc_D), .regdst_D(regdst_D),
        .branch_D(branch_D), .valid_D(valid_D),
        .perfmon_D(perfmon_D), .perfmon_flag_D(perfmon_flag_D),
        .pcplus4_D(pcplus4_D),
        .rd1_D(rd1_D), .rd2_D(rd2_D), .rd3_D(rd3_D),
        .rs_D(rs_D), .rt_D(rt_D), .rd_D(rd_D),
        .signimm_D(signimm_D),

        .regwrite_E(regwrite_E), .memtoreg_E(memtoreg_E), .memwrite_E(memwrite_E),
        .alucontrol_E(alucontrol_E), .alusrc_E(alusrc_E), .regdst_E(regdst_E),
        .branch_E(branch_E), .valid_E(valid_E),
        .perfmon_E(perfmon_E), .perfmon_flag_E(perfmon_flag_E),
        .pcplus4_E(pcplus4_E),
        .rd1_E(rd1_E), .rd2_E(rd2_E), .rd3_E(rd3_E),
        .rs_E(rs_E), .rt_E(rt_E), .rd_E(rd_E),
        .signimm_E(signimm_E)
    );

    // 3. EXECUTE STAGE
    mux3 #(32) forwarda_mux (
        .d0(rd1_E), .d1(result_W), .d2(aluout_M),
        .s(forwardaE), .y(srca_E)
    );

    mux3 #(32) forwardb_mux (
        .d0(rd2_E), .d1(result_W), .d2(aluout_M),
        .s(forwardbE), .y(writedata_E)
    );

    mux3 #(32) forwardc_mux (
        .d0(rd3_E), .d1(result_W), .d2(aluout_M),
        .s(forwardcE), .y(old_rd_E)
    );

    mux2 #(32) srcbmux (
        .d0(writedata_E), .d1(signimm_E), .s(alusrc_E), .y(srcb_E)
    );

    mux2 #(5) wrmux (
        .d0(rt_E), .d1(rd_E), .s(regdst_E), .y(writereg_E)
    );

    alu alu_inst (
        .a(srca_E), .b(srcb_E), .c(old_rd_E),
        .control(alucontrol_E),
        .result(aluout_E), .zero(zero_E)
    );

    sl2 immsh (
        .a(signimm_E), .y(signimmsh_E)
    );

    adder pcadd2 (
        .a(pcplus4_E), .b(signimmsh_E), .y(pcbranch_E)
    );

    assign pcsrc_E = branch_E & zero_E;

    pipe_ex_mem reg_ex_mem (
        .clk(clk), .reset(reset),
        .regwrite_E(regwrite_E), .memtoreg_E(memtoreg_E), .memwrite_E(memwrite_E),
        .valid_E(valid_E), .perfmon_E(perfmon_E), .perfmon_flag_E(perfmon_flag_E),
        .aluout_E(aluout_E), .writedata_E(writedata_E),
        .writereg_E(writereg_E),

        .regwrite_M(regwrite_M), .memtoreg_M(memtoreg_M), .memwrite_M(memwrite_M),
        .valid_M(valid_M), .perfmon_M(perfmon_M), .perfmon_flag_M(perfmon_flag_M),
        .aluout_M(aluout_M), .writedata_M(writedata_M),
        .writereg_M(writereg_M)
    );

    // 4. MEMORY STAGE
    assign aluout     = aluout_M;
    assign writedata  = writedata_M;
    assign memwrite   = memwrite_M;
    assign readdata_M = readdata;

    pipe_mem_wb reg_mem_wb (
        .clk(clk), .reset(reset),
        .regwrite_M(regwrite_M), .memtoreg_M(memtoreg_M),
        .valid_M(valid_M), .perfmon_M(perfmon_M), .perfmon_flag_M(perfmon_flag_M),
        .readdata_M(readdata_M), .aluout_M(aluout_M),
        .writereg_M(writereg_M),

        .regwrite_W(regwrite_W), .memtoreg_W(memtoreg_W),
        .valid_W(valid_W), .perfmon_W(perfmon_W), .perfmon_flag_W(perfmon_flag_W),
        .readdata_W(readdata_W), .aluout_W(aluout_W),
        .writereg_W(writereg_W)
    );

    performance_monitor perfmon (
        .clk(clk), .reset(reset), .retire_valid(valid_W),
        .cycle_count(cycle_count), .instruction_count(instruction_count)
    );

    // 5. WRITEBACK STAGE
    mux2 #(32) resmux (
        .d0(aluout_W), .d1(readdata_W), .s(memtoreg_W), .y(normal_result_W)
    );

    // The monitor reads are selected in WB. 
    assign result_W = perfmon_W ?
                      (perfmon_flag_W ? instruction_count : cycle_count) :
                      normal_result_W;
endmodule

// Helper Primitive Modules
module regfile (
    input  logic        clk, we3,
    input  logic [4:0]  ra1, ra2, ra3, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2, rd3
);
    logic [31:0] rf[31:0];

    always_ff @(negedge clk)
        if (we3) rf[wa3] <= wd3;

    assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
    assign rd3 = (ra3 != 0) ? rf[ra3] : 0;
endmodule

module alu (
    input  logic [31:0] a, b, c,
    input  logic [2:0]  control,
    output logic [31:0] result,
    output logic        zero
);
    logic [31:0] product;

    always_comb begin
        product = a * b;
        case (control)
            3'b000:  result = a & b;
            3'b001:  result = a | b;
            3'b010:  result = a + b;
            3'b011:  result = product + c;
            3'b110:  result = a - b;
            3'b111:  result = (a < b) ? 32'b1 : 32'b0;
            default: result = 'x;
        endcase
    end
    assign zero = (result == 32'b0);
endmodule

module adder (
    input  logic [31:0] a, b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module mux2 #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] d0, d1,
    input  logic             s,
    output logic [WIDTH-1:0] y
);
    assign y = s ? d1 : d0;
endmodule

module signext (
    input  logic [15:0] a,
    output logic [31:0] y
);
    assign y = {{16{a[15]}}, a};
endmodule

module sl2 (
    input  logic [31:0] a,
    output logic [31:0] y
);
    assign y = {a[29:0], 2'b00};
endmodule
