module MIPS_Testbench ();
    logic clk;
    logic reset;
    logic [31:0] writedata, dataadr;
    logic memwrite;

    int i;

    // Expected memory writes matching memfile.dat
    parameter int N = 3;
    logic [31:0] expected_data[N:1];
    logic [31:0] expected_addr[N:1];
    
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
                end
                i = i + 1;
            end
        end
        
        $display("TEST COMPLETE - ALL WRITES SUCCESSFUL");
        $finish;
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, MIPS_Testbench);
    end
    
endmodule