module oddeven_tb;

    localparam integer DATA_WIDTH = 8;
    localparam integer FIFO_DEPTH = 40;
    localparam integer CLK_HALF   = 5;
    localparam integer SB_DEPTH   = 128;

    logic                  clk;
    logic                  reset;
    logic [DATA_WIDTH-1:0] data_in;
    logic                  write_en;
    logic [DATA_WIDTH-1:0] data_out;
    logic                  read_en;

    //expected data kept separately for the even and odd FIFOs
    logic [DATA_WIDTH-1:0] even_expected [0:SB_DEPTH-1];
    logic [DATA_WIDTH-1:0] odd_expected  [0:SB_DEPTH-1];

    integer even_write_index;
    integer even_read_index;
    integer even_count;
    integer odd_write_index;
    integer odd_read_index;
    integer odd_count;

    integer peak_even_count;
    integer peak_odd_count;
    integer case_write_requests;
    integer case_read_requests;
    integer case_writes_accepted;
    integer case_reads_accepted;
    integer saw_even_full;
    integer saw_odd_full;
    integer expect_even;

    integer error_count;
    integer check_count;

    oddeven dut (
        .clk      (clk),
        .reset    (reset),
        .data_in  (data_in),
        .write_en (write_en),
        .data_out (data_out),
        .read_en  (read_en)
    );

    //10 ns clock period; the Makefile supplies the 1ns/1ps timescale
    initial begin
        clk = 1'b0;
        forever #CLK_HALF clk = ~clk;
    end

    //report an error but allow the rest of the test to continue
    task automatic report_error(input string message);
        begin
            error_count = error_count + 1;
            $display("ERROR [%0t] %s", $time, message);
        end
    endtask

    task automatic check_result(
        input logic condition,
        input string message
    );
        begin
            check_count = check_count + 1;
            if(condition !== 1'b1)
                report_error(message);
        end
    endtask

    //clear the software model before each test case
    task automatic clear_scoreboard;
        begin
            even_write_index = 0;
            even_read_index  = 0;
            even_count       = 0;
            odd_write_index  = 0;
            odd_read_index   = 0;
            odd_count        = 0;

            peak_even_count = 0;
            peak_odd_count  = 0;
            case_write_requests = 0;
            case_read_requests  = 0;
            case_writes_accepted = 0;
            case_reads_accepted  = 0;
            saw_even_full = 0;
            saw_odd_full  = 0;
            expect_even   = 1;
        end
    endtask

    //case 1: 40 odd values followed by 40 even values
    //case 2: even and odd values alternate for all 80 inputs
    function automatic logic [DATA_WIDTH-1:0] make_data(
        input integer case_number,
        input integer item_number
    );
        begin
            if(case_number == 1) begin
                if(item_number < 40)
                    make_data = (2 * item_number) + 1;
                else
                    make_data = 128 + (2 * (item_number - 40));
            end
            else begin
                make_data = item_number;
            end
        end
    endfunction

    task automatic reset_dut;
        begin
            @(negedge clk);
            reset    = 1'b1;
            write_en = 1'b0;
            read_en  = 1'b0;
            data_in  = '0;

            repeat(4) @(posedge clk);

            @(negedge clk);
            reset = 1'b0;
            clear_scoreboard();
        end
    endtask

    //sample one transaction at the active clock edge and compare the result
    task automatic sample_cycle;
        logic even_write_now;
        logic odd_write_now;
        logic even_read_now;
        logic odd_read_now;
        logic expected_valid;
        logic [DATA_WIDTH-1:0] expected_value;
        begin
            @(posedge clk);

            //these signals describe the transactions accepted at this edge
            even_write_now = write_en && !data_in[0] && !dut.even_full;
            odd_write_now  = write_en &&  data_in[0] && !dut.odd_full;
            even_read_now  = dut.even_ren;
            odd_read_now   = dut.odd_ren;
            expected_valid = 1'b0;
            expected_value = '0;

            if(even_read_now && odd_read_now)
                report_error("both FIFO read enables asserted together");

            //remove the expected value before adding a simultaneous write
            if(even_read_now) begin
                if(even_count == 0) begin
                    report_error("even FIFO read while scoreboard was empty");
                end
                else begin
                    expected_value = even_expected[even_read_index];
                    expected_valid = 1'b1;
                    even_read_index = even_read_index + 1;
                    even_count = even_count - 1;
                end

                check_result(expect_even == 1,
                             "arbiter read even data when odd data was expected");
                expect_even = 0;
                case_reads_accepted = case_reads_accepted + 1;
            end
            else if(odd_read_now) begin
                if(odd_count == 0) begin
                    report_error("odd FIFO read while scoreboard was empty");
                end
                else begin
                    expected_value = odd_expected[odd_read_index];
                    expected_valid = 1'b1;
                    odd_read_index = odd_read_index + 1;
                    odd_count = odd_count - 1;
                end

                check_result(expect_even == 0,
                             "arbiter read odd data when even data was expected");
                expect_even = 1;
                case_reads_accepted = case_reads_accepted + 1;
            end

            if((even_read_now || odd_read_now) && !read_en)
                report_error("FIFO read occurred without a read request");

            if(even_write_now) begin
                if(even_count >= FIFO_DEPTH) begin
                    report_error("even FIFO accepted data while full");
                end
                else begin
                    even_expected[even_write_index] = data_in;
                    even_write_index = even_write_index + 1;
                    even_count = even_count + 1;
                    case_writes_accepted = case_writes_accepted + 1;
                end
            end

            if(odd_write_now) begin
                if(odd_count >= FIFO_DEPTH) begin
                    report_error("odd FIFO accepted data while full");
                end
                else begin
                    odd_expected[odd_write_index] = data_in;
                    odd_write_index = odd_write_index + 1;
                    odd_count = odd_count + 1;
                    case_writes_accepted = case_writes_accepted + 1;
                end
            end

            if(even_count > peak_even_count)
                peak_even_count = even_count;
            if(odd_count > peak_odd_count)
                peak_odd_count = odd_count;

            //wait until the DUT nonblocking assignments have completed
            #1;

            if(expected_valid) begin
                check_result(data_out === expected_value,
                             $sformatf("data mismatch: expected 0x%02h, received 0x%02h",
                                       expected_value, data_out));
            end

            //the internal flags are useful for checking the FIFO model
            check_result(dut.even_empty === (even_count == 0),
                         "even_empty does not match FIFO occupancy");
            check_result(dut.odd_empty === (odd_count == 0),
                         "odd_empty does not match FIFO occupancy");
            check_result(dut.even_full === (even_count == FIFO_DEPTH),
                         "even_full does not match FIFO occupancy");
            check_result(dut.odd_full === (odd_count == FIFO_DEPTH),
                         "odd_full does not match FIFO occupancy");

            if(dut.even_full)
                saw_even_full = 1;
            if(dut.odd_full)
                saw_odd_full = 1;
        end
    endtask

    task automatic run_case(
        input integer case_number,
        input string case_name
    );
        integer cycle_number;
        integer item_number;
        integer drain_cycles;
        integer errors_before_case;
        begin
            reset_dut();
            errors_before_case = error_count;
            item_number = 0;

            $display("\nStarting %s", case_name);

            //eight active cycles followed by two idle cycles gives 80/100
            for(cycle_number = 0; cycle_number < 100;
                cycle_number = cycle_number + 1) begin

                @(negedge clk);
                write_en = ((cycle_number % 10) < 8);
                read_en  = ((cycle_number % 10) < 8);

                if(write_en) begin
                    data_in = make_data(case_number, item_number);
                    item_number = item_number + 1;
                    case_write_requests = case_write_requests + 1;
                end

                if(read_en)
                    case_read_requests = case_read_requests + 1;

                sample_cycle();
            end

            check_result(case_write_requests == 80,
                         $sformatf("input rate was %0d/100 instead of 80/100",
                                   case_write_requests));
            check_result(case_read_requests == 80,
                         $sformatf("read-request rate was %0d/100 instead of 80/100",
                                   case_read_requests));

            //stop writing and keep the same 8/10 read-request pattern
            drain_cycles = 0;
            while((even_count != 0 || odd_count != 0) &&
                  drain_cycles < 300) begin

                @(negedge clk);
                write_en = 1'b0;
                read_en  = ((drain_cycles % 10) < 8);
                sample_cycle();
                drain_cycles = drain_cycles + 1;
            end

            @(negedge clk);
            write_en = 1'b0;
            read_en  = 1'b0;
            sample_cycle();

            check_result(even_count == 0 && odd_count == 0,
                         "FIFOs did not drain before the timeout");
            check_result(case_writes_accepted == 80,
                         $sformatf("only %0d of 80 writes were accepted",
                                   case_writes_accepted));
            check_result(case_reads_accepted == 80,
                         $sformatf("only %0d of 80 values were read",
                                   case_reads_accepted));

            if(case_number == 1) begin
                check_result(peak_odd_count == FIFO_DEPTH,
                             $sformatf("depth-setting case reached %0d entries instead of %0d",
                                       peak_odd_count, FIFO_DEPTH));
                check_result(saw_odd_full == 1,
                             "odd FIFO never asserted full in the depth-setting case");
            end
            else begin
                check_result(saw_even_full == 0 && saw_odd_full == 0,
                             "a FIFO unexpectedly became full in the alternating case");
            end

            $display("%s summary: accepted writes=%0d, outputs=%0d, peak even=%0d, peak odd=%0d",
                     case_name, case_writes_accepted, case_reads_accepted,
                     peak_even_count, peak_odd_count);

            if(error_count == errors_before_case)
                $display("%s PASSED", case_name);
            else
                $display("%s FAILED with %0d error(s)",
                         case_name, error_count - errors_before_case);
        end
    endtask

    initial begin
        reset       = 1'b1;
        write_en    = 1'b0;
        read_en     = 1'b0;
        data_in     = '0;
        error_count = 0;
        check_count = 0;

        //case 1 is the case used to justify a FIFO depth of 40
        run_case(1, "CASE 1: 40 odd values followed by 40 even values");

        //case 2 checks normal balanced traffic
        run_case(2, "CASE 2: alternating even and odd values");

        if(error_count == 0) begin
            $display("\nODDEVEN TESTBENCH PASSED (%0d checks)", check_count);
            $finish;
        end
        else begin
            $display("\nODDEVEN TESTBENCH FAILED (%0d errors, %0d checks)",
                     error_count, check_count);
            $fatal(1, "oddeven verification failed");
        end
    end

    //backup timeout in case the DUT stops making progress
    initial begin
        #50000;
        $fatal(1, "simulation timeout");
    end

    //FSDB file used by the waves_verdi target in the Makefile
    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, oddeven_tb);
    end

endmodule
