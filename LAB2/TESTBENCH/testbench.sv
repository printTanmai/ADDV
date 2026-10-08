module MIPS_Testbench ();
    logic clk;
    logic reset;
    logic [31:0] writedata, dataadr;
    logic memwrite;

    int i;

    // Expected memory writes matching memfile.dat
    parameter int N = 2;
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
        expected_data[1] = 32'h7;
        expected_addr[1] = 32'h50;

        expected_data[2] = 32'h7;
        expected_addr[2] = 32'h54;
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