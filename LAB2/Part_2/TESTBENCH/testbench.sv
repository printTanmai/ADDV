module MIPS_Testbench ();
    logic clk;
    logic reset;
    logic [31:0] writedata, dataadr;
    logic memwrite;

    int i;

    // Expected memory writes matching memfile.dat
    parameter int N = 7;
    logic [31:0] expected_data[N:1];
    logic [31:0] expected_addr[N:1];
    logic all_success;
    
    // Instantiate top module
    top dut (
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );
    
    // Initialize expected data and addresses

    initial begin
        // Checkpoint 1 (Case 1: Basic ISA ops)
        expected_data[1] = 32'h0f; // 15 in hex
        expected_addr[1] = 32'h50;

        // Checkpoint 2 (Case 2: ADD Data hazards & Forwarding)
        expected_data[2] = 32'h28; // 40 in hex
        expected_addr[2] = 32'h54;

        // Checkpoint 3 (Case 3: BEQ Control hazards & Flushing)
        expected_data[3] = 32'h12; // 18 in hex
        expected_addr[3] = 32'h58;

        // Checkpoint 4 (MULADD third operand and EX/MEM forwarding)
        expected_data[4] = 32'h1d; // 29 in hex
        expected_addr[4] = 32'h5c;

        // Checkpoint 5 (load-use stall on MULADD's rd addend)
        expected_data[5] = 32'h29; // 41 in hex
        expected_addr[5] = 32'h60;

        // Checkpoint 6 (completed instruction counter, before perfmon retires)
        expected_data[6] = 32'h29; // 41 instructions retired before perfmon
        expected_addr[6] = 32'h64;

        // Checkpoint 7 (cycle counter snapshot)
        expected_data[7] = 32'h34; // 52 elapsed cycles
        expected_addr[7] = 32'h68;
    end

    // Clock generation (10ns period)
    always begin
        clk <= 1'b0; 
        #5;
        clk <= 1'b1; 
        #5;
    end
    
    // Monitor memory write signals on negedge clk
    initial begin
        reset = 1'b1;
        all_success = 1'b1;
        @(posedge clk);
        @(posedge clk);
        reset = 1'b0;

        i = 1;
        while (i <= N) begin
            @(negedge clk);
            if (memwrite) begin
                if (dataadr == expected_addr[i] && writedata == expected_data[i]) begin
                    $display("Memory write %0d successful : wrote %h to address %h", i, writedata, dataadr);
                end else begin
                    $display("ERROR: Memory write %0d : wrote %h to address %h ; Expected %h to address %h", 
                             i, writedata, dataadr, expected_data[i], expected_addr[i]);
                    all_success = 1'b0;
                end
                i = i + 1;
            end
        end
        
        if (all_success) begin
            $display("TEST PASS - ALL %0d MEMORY WRITES MATCHED", N);
            $finish;
        end else begin
            $fatal(1, "TEST FAIL - ONE OR MORE MEMORY WRITES DID NOT MATCH");
        end
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, MIPS_Testbench);
    end
    
endmodule
