module MIPS_Testbench;
    import uvm_pkg::*;
    import mips_part3_pkg::*;
    `include "uvm_macros.svh"

    logic clk=0;
    logic reset=1;
    logic [31:0] writedata,dataadr;
    logic memwrite;
    logic [31:0] program_image[0:63];
    instruction_sequence generator;
    string program_file,fsdb_file;
    int timeout_cycles;

    top dut(.clk(clk),.reset(reset),.writedata(writedata),
            .dataadr(dataadr),.memwrite(memwrite));
    mips_fetch_if fetch_if(clk);

    assign fetch_if.reset=reset;
    assign fetch_if.pc=dut.pc;
    assign fetch_if.instr=dut.instr;
    assign fetch_if.stallD=dut.mips_inst.stallD;
    assign fetch_if.flushD=dut.mips_inst.flushD;
    assign fetch_if.flushE=dut.mips_inst.flushE;
    assign fetch_if.branch_E=dut.mips_inst.dp.branch_E;
    assign fetch_if.pcsrc_E=dut.mips_inst.pcsrc_E;
    assign fetch_if.address_E=dut.mips_inst.dp.aluout_E;
    assign fetch_if.operand_a_E=dut.mips_inst.dp.srca_E;
    assign fetch_if.operand_b_E=dut.mips_inst.dp.writedata_E;

    always #5 clk=~clk;

    initial begin
        fetch_if.done=0;
        if (!$value$plusargs("PROGRAM_FILE=%s",program_file))
            program_file="build/generated.hex";
        if (!$value$plusargs("TIMEOUT=%d",timeout_cycles))
            timeout_cycles=600;

        // Build a dynamic sequence using the Part 2 style class, then pass
        // exactly these assembled words to RTL via writememh/readmemh.
        generator=new("generator");
        if (!generator.generate_program())
            `uvm_fatal("GENERATOR","Instruction generation failed")
        fetch_if.program_words=generator.instruction_words.size();
        for (int i=0;i<64;i++)
            program_image[i]=32'h00000020; // harmless ADD $zero,$zero,$zero
        foreach (generator.instruction_words[i])
            program_image[i]=generator.instruction_words[i];
        $writememh(program_file,program_image);
        $readmemh(program_file,dut.imem_inst.RAM);

        // Sources are initialized by setup instructions; data locations are
        // stored before loading. No second procedural driver touches rf/dmem.
        uvm_config_db#(virtual mips_fetch_if)::set(null,"*","vif",fetch_if);
        // UVM's run phase must start at time zero. Pulse reset in parallel,
        // not before run_test(), so the monitor can wait through reset.
        fork
            begin
                repeat (4) @(negedge clk);
                reset=0;
            end
            begin
                run_test("mips_coverage_test");
            end
        join
    end

    // Observe actual stores at the edge where the data memory writes.
    // The matching store was already seen in EX one cycle earlier.
    initial begin
        wait (reset===0);
        forever begin
            @(posedge clk);
            if (memwrite===1'b1 && dataadr===32'h000000fc &&
                writedata===32'h00000000) begin
                $display("TRICKBOX: SW $zero,252($zero) wrote address 0x000000fc with data 0x00000000 at %0t; ending simulation.",$time);
                #1;
                fetch_if.done=1;
                break;
            end
        end
    end

    initial begin
        wait (reset===0);
        repeat (timeout_cycles) @(posedge clk);
        if (!fetch_if.done)
            `uvm_fatal("TIMEOUT","Trickbox store was not observed")
    end

`ifdef FSDB
    initial begin
        if (!$value$plusargs("FSDB=%s",fsdb_file))
            fsdb_file="build/part4.fsdb";
        $fsdbDumpfile(fsdb_file);
        $fsdbDumpvars(0,MIPS_Testbench);
    end
`endif
endmodule
