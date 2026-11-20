module MIPS_Testbench;

    logic        clk;
    logic        reset;
    logic [31:0] writedata;
    logic [31:0] dataadr;
    logic        memwrite;

    integer trace_fd;
    integer cycle_count;
    integer timeout_cycles;

    string trace_file;
    string fsdb_file;

    logic        trace_regwrite;
    logic [4:0]  trace_rd;
    logic [31:0] trace_regdata;
    logic        trace_memwrite;
    logic [31:0] trace_memaddr;
    logic [31:0] trace_memdata;

    top dut (
        .clk       (clk),
        .reset     (reset),
        .writedata (writedata),
        .dataadr   (dataadr),
        .memwrite  (memwrite)
    );

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Reset the processor and open the RTL retirement trace.
    initial begin
        reset = 1'b1;

        if (!$value$plusargs("TRACE=%s", trace_file))
            trace_file = "traces/rtl.trace";

        if (!$value$plusargs("TIMEOUT=%d", timeout_cycles))
            timeout_cycles = 300;

        trace_fd = $fopen(trace_file, "w");
        if (trace_fd == 0)
            $fatal(1, "Unable to open RTL trace file: %s", trace_file);

        repeat (2) @(posedge clk);

        // Deassert reset away from the active clock edge to avoid a race.
        @(negedge clk);
        reset = 1'b0;
    end

    // Write one line for every valid instruction reaching writeback.
    // Cycle numbers are intentionally omitted because the ISS is not
    // cycle-accurate. Only architectural behavior is compared.
    initial begin
        cycle_count = 0;

        wait (reset === 1'b0);

        forever begin
            @(negedge clk);
            cycle_count = cycle_count + 1;

            if (dut.mips_inst.dp.valid_W) begin
                // A write to register zero is not an architectural write.
                trace_regwrite = dut.mips_inst.dp.regwrite_W &&
                                 (dut.mips_inst.dp.writereg_W != 5'd0);
                trace_rd       = trace_regwrite
                               ? dut.mips_inst.dp.writereg_W : 5'd0;
                trace_regdata  = trace_regwrite
                               ? dut.mips_inst.dp.result_W : 32'd0;

                trace_memwrite = dut.mips_inst.dp.memwrite_W;
                trace_memaddr  = trace_memwrite
                               ? dut.mips_inst.dp.aluout_W : 32'd0;
                trace_memdata  = trace_memwrite
                               ? dut.mips_inst.dp.writedata_W : 32'd0;

                $fdisplay(
                    trace_fd,
                    "PC=%08x INSTR=%08x REGWRITE=%0d RD=%0d REGDATA=%08x MEMWRITE=%0d MEMADDR=%08x MEMDATA=%08x",
                    dut.mips_inst.dp.pc_W,
                    dut.mips_inst.dp.instr_W,
                    trace_regwrite,
                    trace_rd,
                    trace_regdata,
                    trace_memwrite,
                    trace_memaddr,
                    trace_memdata
                );

                // Every program ends with sw $zero, 252($zero). The store is
                // included in the trace before simulation terminates.
                if (trace_memwrite &&
                    (trace_memaddr == 32'h0000_00fc)) begin
                    $display(
                        "RTL PASS: completion store retired after %0d cycles",
                        cycle_count
                    );
                    $fclose(trace_fd);
                    $finish;
                end
            end

            if (cycle_count >= timeout_cycles) begin
                $fclose(trace_fd);
                $fatal(
                    1,
                    "RTL TIMEOUT: completion store was not observed within %0d cycles",
                    timeout_cycles
                );
            end
        end
    end

`ifdef FSDB
    initial begin
        if (!$value$plusargs("FSDB=%s", fsdb_file))
            fsdb_file = "build/part5.fsdb";

        $fsdbDumpfile(fsdb_file);
        $fsdbDumpvars(0, MIPS_Testbench);
    end
`endif

endmodule
