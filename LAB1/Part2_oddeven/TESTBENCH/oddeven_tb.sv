`timescale 1ns/1ps

module oddeven_tb;

    //test parameters
    localparam int DATA_WIDTH = 8;
    localparam int FIFO_DEPTH = 40;
    localparam int CLK_HALF   = 5;

    //required rates
    localparam int WRITE_NUM = 80, WRITE_DEN = 100;
    localparam int READ_NUM  = 8,  READ_DEN  = 10;

    //stimulus: case A (worst-case burst, values 0-79) then case B (steady
    //alternating, values 128-207)
    localparam int STIM_SIZE = 160;

    //scoreboard capacity per parity
    localparam int SB_SIZE = 128;

    logic                  clk;
    logic                  reset;
    logic [DATA_WIDTH-1:0] data_in;
    logic                  write_en;
    logic [DATA_WIDTH-1:0] data_out;
    logic                  read_en;

    oddeven dut (
        .clk      (clk),
        .reset    (reset),
        .data_in  (data_in),
        .write_en (write_en),
        .data_out (data_out),
        .read_en  (read_en)
    );

    //clock
    initial begin
        clk = 1'b0;
        forever #CLK_HALF clk = ~clk;
    end

    //stimulus data
    logic [DATA_WIDTH-1:0] stim_data [0:STIM_SIZE-1];
    integer stim_idx;

    //scoreboard, one per parity
    logic [DATA_WIDTH-1:0] even_expected [0:SB_SIZE-1];
    logic [DATA_WIDTH-1:0] odd_expected  [0:SB_SIZE-1];
    integer even_w_idx, even_r_idx, even_count;
    integer odd_w_idx,  odd_r_idx,  odd_count;

    logic expect_even;
    logic [DATA_WIDTH-1:0] prev_data_out;
    logic seen_first_read;

    integer error_count;
    integer check_count;
    integer write_count;
    integer read_count;
    integer reject_count;

    task automatic test_error(input string message);
        begin
            error_count = error_count + 1;
            $error("[%0t] %s", $time, message);
        end
    endtask

    task automatic check_flag(
        input string flag_name,
        input logic actual,
        input logic expected
    );
        begin
            check_count = check_count + 1;

            if(actual !== expected)
                test_error($sformatf(
                    "%s expected %0b but got %0b",
                    flag_name,
                    expected,
                    actual
                ));
        end
    endtask

    //case A: 40 evens then 40 odds, low value range
    //case B: alternating even/odd, high value range
    task automatic load_stimulus;
        integer i;
        begin
            for(i = 0; i < 40; i = i + 1) stim_data[i]      = 8'(2*i);
            for(i = 0; i < 40; i = i + 1) stim_data[40 + i] = 8'(2*i + 1);
            for(i = 0; i < 40; i = i + 1) begin
                stim_data[80 + 2*i]     = 8'(128 + 2*i);
                stim_data[80 + 2*i + 1] = 8'(129 + 2*i);
            end
            stim_idx = 0;
        end
    endtask

    task automatic add_expected_even(input logic [DATA_WIDTH-1:0] data);
        begin
            if(even_count >= SB_SIZE)
                $fatal(1, "even scoreboard overflow");
            even_expected[even_w_idx] = data;
            even_w_idx = (even_w_idx + 1) % SB_SIZE;
            even_count = even_count + 1;
        end
    endtask

    task automatic add_expected_odd(input logic [DATA_WIDTH-1:0] data);
        begin
            if(odd_count >= SB_SIZE)
                $fatal(1, "odd scoreboard overflow");
            odd_expected[odd_w_idx] = data;
            odd_w_idx = (odd_w_idx + 1) % SB_SIZE;
            odd_count = odd_count + 1;
        end
    endtask

    task automatic reset_dut;
        begin
            reset    = 1'b1;
            stim_idx = 0;

            even_w_idx = 0; even_r_idx = 0; even_count = 0;
            odd_w_idx  = 0; odd_r_idx  = 0; odd_count  = 0;
            expect_even     = 1'b1;
            prev_data_out   = '0;
            seen_first_read = 1'b0;

            write_count  = 0;
            read_count   = 0;
            reject_count = 0;

            repeat(5) @(posedge clk);
            reset = 1'b0;
            @(posedge clk);
        end
    endtask

    //write rate generator - fires exactly WRITE_NUM times per WRITE_DEN cycles
    integer w_acc;
    always_ff @(posedge clk) begin
        if(reset) begin
            w_acc    <= 0;
            write_en <= 1'b0;
            data_in  <= '0;
        end
        else if((w_acc + WRITE_NUM) >= WRITE_DEN) begin
            w_acc <= w_acc + WRITE_NUM - WRITE_DEN;
            if(stim_idx < STIM_SIZE) begin
                data_in  <= stim_data[stim_idx];
                write_en <= 1'b1;
                stim_idx  = stim_idx + 1;
            end
            else
                write_en <= 1'b0;
        end
        else begin
            w_acc    <= w_acc + WRITE_NUM;
            write_en <= 1'b0;
        end
    end

    //read rate generator - fires exactly READ_NUM times per READ_DEN cycles,
    //asserted on schedule regardless of availability, this is what exercises
    //the pause behavior
    integer r_acc;
    always_ff @(posedge clk) begin
        if(reset) begin
            r_acc   <= 0;
            read_en <= 1'b0;
        end
        else if((r_acc + READ_NUM) >= READ_DEN) begin
            r_acc   <= r_acc + READ_NUM - READ_DEN;
            read_en <= 1'b1;
        end
        else begin
            r_acc   <= r_acc + READ_NUM;
            read_en <= 1'b0;
        end
    end

    //scoreboard monitor - mirrors router + per-parity full/empty + alternation
    always @(posedge clk) begin
        if(!reset) begin
            automatic bit is_odd;
            automatic bit can_out;
            automatic bit exp_even;
            automatic logic [DATA_WIDTH-1:0] expected;

            if(write_en) begin
                is_odd = data_in[0];
                if(!is_odd && even_count < FIFO_DEPTH) begin
                    add_expected_even(data_in);
                    write_count = write_count + 1;
                end
                else if(is_odd && odd_count < FIFO_DEPTH) begin
                    add_expected_odd(data_in);
                    write_count = write_count + 1;
                end
                else
                    reject_count = reject_count + 1;
            end

            exp_even = expect_even;
            can_out  = read_en && ((exp_even && even_count > 0) ||
                                    (!exp_even && odd_count > 0));

            if(can_out) begin
                if(exp_even) begin
                    expected   = even_expected[even_r_idx];
                    even_r_idx = (even_r_idx + 1) % SB_SIZE;
                    even_count = even_count - 1;
                end
                else begin
                    expected  = odd_expected[odd_r_idx];
                    odd_r_idx = (odd_r_idx + 1) % SB_SIZE;
                    odd_count = odd_count - 1;
                end
                expect_even     = !exp_even;
                read_count      = read_count + 1;
                seen_first_read = 1'b1;
            end

            #1;

            if(can_out) begin
                check_flag("read data matches scoreboard", (data_out === expected), 1'b1);
                if(exp_even)
                    check_flag("output is even as expected", data_out[0], 1'b0);
                else
                    check_flag("output is odd as expected", data_out[0], 1'b1);
            end
            else if(seen_first_read) begin
                check_flag("data_out holds when no valid read", (data_out === prev_data_out), 1'b1);
            end

            prev_data_out = data_out;
        end
    end

    task automatic wait_until_drained(input integer max_cycles);
        integer i;
        begin
            for(i = 0; i < max_cycles; i = i + 1) begin
                if(even_count == 0 && odd_count == 0) i = max_cycles;
                else @(posedge clk);
            end
            if(even_count != 0 || odd_count != 0)
                test_error("timed out waiting for both scoreboards to drain");
        end
    endtask

    //main test
    initial begin
        error_count = 0;
        check_count = 0;

        reset_dut();
        load_stimulus();

        $display("Starting case A (worst-case burst, 0-79) and case B (alternating, 128-207)");

        wait(stim_idx == STIM_SIZE);
        wait_until_drained(2000);

        if(error_count == 0) begin
            $display("ODDEVEN TESTBENCH PASSED (%0d checks, writes=%0d, reads=%0d, rejected=%0d)",
                      check_count, write_count, read_count, reject_count);
            $finish;
        end
        else begin
            $display("ODDEVEN TESTBENCH FAILED (%0d errors)", error_count);
            $fatal(1, "oddeven verification failed");
        end
    end

    //simulation timeout
    initial begin
        #1000000; //1000000 ns stuck timer
        $fatal(1, "Simulation timeout");
    end

    //waveform dump
    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, oddeven_tb);
    end

endmodule