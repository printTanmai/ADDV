module top (
    input  logic        clk, reset,
    output logic [31:0] writedata, dataadr,
    output logic        memwrite
);
    logic [31:0] pc, instr, readdata;

    mips mips_inst (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instr(instr),
        .memwrite(memwrite),
        .aluout(dataadr),
        .writedata(writedata),
        .readdata(readdata)
    );

    imem imem_inst (
        .a(pc[7:2]),
        .rd(instr)
    );

    dmem dmem_inst (
        .clk(clk),
        .we(memwrite),
        .a(dataadr),
        .wd(writedata),
        .rd(readdata)
    );
endmodule

module mips (
    input  logic        clk, reset,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic        memwrite,
    output logic [31:0] aluout, writedata,
    input  logic [31:0] readdata
);
    // Control Signals
    logic [5:0] op_D, funct_D;
    logic       memtoreg_D, memwrite_D, alusrc_D, regdst_D, regwrite_D, jump_D, branch_D;
    logic [2:0] alucontrol_D;

    // Hazard Signals
    logic       stallF, stallD, flushD, flushE;
    logic [1:0] forwardaE, forwardbE;
    logic [4:0] rs_D, rt_D, rs_E, rt_E, writereg_E, writereg_M, writereg_W;
    logic       regwrite_E, regwrite_M, regwrite_W, memtoreg_E, pcsrc_E;

    controller c (
        .op(op_D),
        .funct(funct_D),
        .memtoreg(memtoreg_D),
        .memwrite(memwrite_D),
        .alusrc(alusrc_D),
        .regdst(regdst_D),
        .regwrite(regwrite_D),
        .jump(jump_D),
        .branch(branch_D),
        .alucontrol(alucontrol_D)
    );

    datapath dp (
        .clk(clk), .reset(reset),
        .memtoreg_D(memtoreg_D), .memwrite_D(memwrite_D),
        .alusrc_D(alusrc_D), .regdst_D(regdst_D),
        .regwrite_D(regwrite_D), .jump_D(jump_D),
        .branch_D(branch_D), .alucontrol_D(alucontrol_D),

        .stallF(stallF), .stallD(stallD),
        .flushD(flushD), .flushE(flushE),
        .forwardaE(forwardaE), .forwardbE(forwardbE),

        .pc(pc), .instr(instr),
        .aluout(aluout), .writedata(writedata),
        .readdata(readdata), .memwrite(memwrite),

        .op_D(op_D), .funct_D(funct_D),
        .rs_D(rs_D), .rt_D(rt_D),
        .rs_E(rs_E), .rt_E(rt_E), .writereg_E(writereg_E),
        .writereg_M(writereg_M), .writereg_W(writereg_W),
        .regwrite_E(regwrite_E), .regwrite_M(regwrite_M), .regwrite_W(regwrite_W),
        .memtoreg_E(memtoreg_E), .pcsrc_E(pcsrc_E)
    );

    hazard_unit hu (
        .rs_D(rs_D), .rt_D(rt_D),
        .rs_E(rs_E), .rt_E(rt_E),
        .writereg_E(writereg_E), .writereg_M(writereg_M), .writereg_W(writereg_W),
        .regwrite_E(regwrite_E), .regwrite_M(regwrite_M), .regwrite_W(regwrite_W),
        .memtoreg_E(memtoreg_E), .pcsrc_E(pcsrc_E), .jump_D(jump_D),

        .stallF(stallF), .stallD(stallD),
        .flushD(flushD), .flushE(flushE),
        .forwardaE(forwardaE), .forwardbE(forwardbE)
    );
endmodule

module dmem (
    input  logic        clk, we,
    input  logic [31:0] a, wd,
    output logic [31:0] rd
);
    logic [31:0] RAM[0:63];

    assign rd = RAM[a[7:2]];
    
    always_ff @(posedge clk)
        if (we) RAM[a[7:2]] <= wd;
endmodule

module imem (
    input  logic [5:0]  a,
    output logic [31:0] rd
);
    logic [31:0] RAM[0:63];

    initial begin
        $readmemh("../RTL/memfile.dat", RAM);
    end
    assign rd = RAM[a];
endmodule