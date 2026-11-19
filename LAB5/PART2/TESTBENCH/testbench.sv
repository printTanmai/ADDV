module MIPS_Testbench;
    import mips_instruction_pkg::*;

    localparam logic [31:0] END_ADDRESS = 32'h0000_00fc;
    localparam logic [31:0] END_DATA = 32'h0000_0000;

    logic clk;
    logic reset;
    logic [31:0] writedata, dataadr;
    logic memwrite;
    int unsigned seed;
    int unsigned store_count;
    instruction_sequence generator;

    top dut (
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        store_count = 0;
        seed = 1;
        void'($value$plusargs("SEED=%d", seed));

        generator = new("generated_program");
        generator.srandom(seed);
        if (!generator.generate_program())
            $fatal(1, "Instruction sequence generation failed");

        $display("Generated %0d instruction words (seed=%0d)",
                 generator.instruction_words.size(), seed);
        $writememh("generated_program.hex", generator.instruction_words);

        // Let the DUT's time-zero initialization complete before loading the
        // generated image. Reset stays asserted until after this replacement.
        #1;
        $readmemh("generated_program.hex", dut.imem_inst.RAM);
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;
    end

    always @(negedge clk) begin
        if (!reset && memwrite) begin
            store_count++;
            $display("Store %0d: wrote %h to address %h",
                     store_count, writedata, dataadr);

            if (dataadr == END_ADDRESS) begin
                if (writedata !== END_DATA)
                    $fatal(1, "Malformed stop marker: wrote %h", writedata);
                $display("Stop marker observed; simulation complete.");
                $finish;
            end
        end
    end

    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, MIPS_Testbench);
    end

    initial begin
        repeat (500) @(posedge clk);
        $fatal(1, "Timed out before the generated stop-marker instruction");
    end
endmodule