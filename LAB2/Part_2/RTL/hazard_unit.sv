module hazard_unit (
    input  logic [4:0] rs_D, rt_D, rd_D,
    input  logic [4:0] rs_E, rt_E, rd_E,
    input  logic       muladd_D,
    input  logic [4:0] writereg_E, writereg_M, writereg_W,
    input  logic       regwrite_E, regwrite_M, regwrite_W,
    input  logic       memtoreg_E, perfmon_E, pcsrc_E, jump_D,

    output logic       stallF, stallD,
    output logic       flushD, flushE,
    output logic [1:0] forwardaE, forwardbE, forwardcE
);
    logic lwstall, perfmonstall;

    // 1. Forwarding Logic
    always_comb begin
        // Forward A
        if ((rs_E != 5'b0) && (rs_E == writereg_M) && regwrite_M)
            forwardaE = 2'b10; // Forward from MEM stage
        else if ((rs_E != 5'b0) && (rs_E == writereg_W) && regwrite_W)
            forwardaE = 2'b01; // Forward from WB stage
        else
            forwardaE = 2'b00;

        // Forward B
        if ((rt_E != 5'b0) && (rt_E == writereg_M) && regwrite_M)
            forwardbE = 2'b10; // Forward from MEM stage
        else if ((rt_E != 5'b0) && (rt_E == writereg_W) && regwrite_W)
            forwardbE = 2'b01; // Forward from WB stage
        else
            forwardbE = 2'b00;

        // MULADD also reads the old destination value as its addend.
        if ((rd_E != 5'b0) && (rd_E == writereg_M) && regwrite_M)
            forwardcE = 2'b10;
        else if ((rd_E != 5'b0) && (rd_E == writereg_W) && regwrite_W)
            forwardcE = 2'b01;
        else
            forwardcE = 2'b00;
    end

    // 2. Load-Use Stall Logic
    assign lwstall = memtoreg_E & ((rt_E == rs_D) || (rt_E == rt_D) ||
                                   (muladd_D && (rt_E == rd_D)));
    // A perfmon value is selected in WB. Hold an immediately dependent
    // instruction until that value can be forwarded from WB.
    assign perfmonstall = perfmon_E &&
                          ((writereg_E == rs_D) || (writereg_E == rt_D) ||
                           (muladd_D && (writereg_E == rd_D)));
    assign stallF  = lwstall | perfmonstall;
    assign stallD  = lwstall | perfmonstall;

    // 3. Flush Logic
    assign flushE  = lwstall | perfmonstall | pcsrc_E;
    assign flushD  = pcsrc_E | jump_D;
endmodule
