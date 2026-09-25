module async_fifo_tb;

    //test parameters
    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 8;
    localparam int ADDR_WIDTH = $clog2(DEPTH);
    localparam int PTR_WIDTH = ADDR_WIDTH + 1;

    localparam int ALMOST_FULL_LEVEL = (DEPTH * 3) / 4;
    localparam int ALMOST_EMPTY_LEVEL = DEPTH / 4;

    localparam int W_CLK_HALF = 5;
    localparam int R_CLK_HALF = 7;
    localparam int SCOREBOARD_SIZE = 64;
    localparam int SIM_WRITES = 16;

    fifo_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo();

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH(PTR_WIDTH),
        .ALMOST_FULL_LEVEL(ALMOST_FULL_LEVEL),
        .ALMOST_EMPTY_LEVEL(ALMOST_EMPTY_LEVEL)
    ) dut (
        .fifo(fifo)
    );

    //scoreboard
    logic [DATA_WIDTH-1:0] expected_data [0:SCOREBOARD_SIZE-1];
    integer sb_write_index;
    integer sb_read_index;
    integer sb_count;

    integer error_count;
    integer check_count;

    logic simultaneous_test;
    logic saw_both_enables;

    //write clock
    initial begin
        fifo.w_clk = 1'b0;
        forever #W_CLK_HALF fifo.w_clk = ~fifo.w_clk;
    end

    //read clock
    initial begin
        fifo.r_clk = 1'b0;
        #1;
        forever #R_CLK_HALF fifo.r_clk = ~fifo.r_clk;
    end

    //check that read and write enables overlap
    initial begin
        saw_both_enables = 1'b0;

        forever begin
            @(posedge fifo.w_clk or posedge fifo.r_clk);

            if(simultaneous_test && fifo.write_en && fifo.read_en)
                saw_both_enables = 1'b1;
        end
    end

    task automatic clear_scoreboard;
        begin
            sb_write_index = 0;
            sb_read_index = 0;
            sb_count = 0;
        end
    endtask

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

    task automatic add_expected(input logic [DATA_WIDTH-1:0] data);
        begin
            if(sb_count >= SCOREBOARD_SIZE)
                $fatal(1, "Scoreboard overflow");

            expected_data[sb_write_index] = data;
            sb_write_index = (sb_write_index + 1) % SCOREBOARD_SIZE;
            sb_count = sb_count + 1;
        end
    endtask

    task automatic check_read_data;
        logic [DATA_WIDTH-1:0] expected;
        begin
            check_count = check_count + 1;

            if(sb_count == 0) begin
                test_error("Read occurred while scoreboard was empty");
            end
            else begin
                expected = expected_data[sb_read_index];

                if(fifo.r_data !== expected)
                    test_error($sformatf(
                        "Data mismatch, expected 0x%0h but got 0x%0h",
                        expected,
                        fifo.r_data
                    ));

                sb_read_index = (sb_read_index + 1) % SCOREBOARD_SIZE;
                sb_count = sb_count - 1;
            end
        end
    endtask

    //reset both clock domains
    task automatic reset_fifo;
        begin
            fifo.write_en = 1'b0;
            fifo.read_en = 1'b0;
            fifo.w_data = '0;
            fifo.w_rst_b = 1'b0;
            fifo.r_rst_b = 1'b0;
            simultaneous_test = 1'b0;
            clear_scoreboard();

            fork
                repeat(3) @(posedge fifo.w_clk);
                repeat(3) @(posedge fifo.r_clk);
            join

            #1;
            fifo.w_rst_b = 1'b1;
            fifo.r_rst_b = 1'b1;

            fork
                repeat(2) @(posedge fifo.w_clk);
                repeat(2) @(posedge fifo.r_clk);
            join

            #1;
        end
    endtask

    //wait for the write pointer to reach the read side
    task automatic wait_read_side;
        begin
            repeat(4) @(posedge fifo.r_clk);
            #1;
        end
    endtask

    //wait for the read pointer to reach the write side
    task automatic wait_write_side;
        begin
            repeat(4) @(posedge fifo.w_clk);
            #1;
        end
    endtask

    //write one value
    task automatic write_fifo(input logic [DATA_WIDTH-1:0] data);
        begin
            @(negedge fifo.w_clk);

            while(fifo.full)
                @(negedge fifo.w_clk);

            fifo.w_data = data;
            fifo.write_en = 1'b1;

            @(posedge fifo.w_clk);
            #1;
            add_expected(data);

            @(negedge fifo.w_clk);
            fifo.write_en = 1'b0;
        end
    endtask

    //read one value and compare it
    task automatic read_fifo;
        begin
            @(negedge fifo.r_clk);

            while(fifo.empty)
                @(negedge fifo.r_clk);

            fifo.read_en = 1'b1;

            @(posedge fifo.r_clk);
            #1;
            check_read_data();

            @(negedge fifo.r_clk);
            fifo.read_en = 1'b0;
        end
    endtask

    //try a read while empty
    task automatic blocked_read;
        begin
            @(negedge fifo.r_clk);
            fifo.read_en = 1'b1;

            @(posedge fifo.r_clk);
            #1;
            check_flag("empty after blocked read", fifo.empty, 1'b1);

            @(negedge fifo.r_clk);
            fifo.read_en = 1'b0;
        end
    endtask

    //try a write while full
    task automatic blocked_write;
        begin
            @(negedge fifo.w_clk);
            fifo.w_data = '1;
            fifo.write_en = 1'b1;

            @(posedge fifo.w_clk);
            #1;
            check_flag("full after blocked write", fifo.full, 1'b1);

            @(negedge fifo.w_clk);
            fifo.write_en = 1'b0;
        end
    endtask

    //empty, full, and almost flag test
    task automatic fill_and_empty_test;
        integer i;
        integer entries_left;
        begin
            $display("Starting fill and empty test");

            check_flag("empty after reset", fifo.empty, 1'b1);
            check_flag("almost_empty after reset", fifo.almost_empty, 1'b1);
            check_flag("full after reset", fifo.full, 1'b0);
            check_flag("almost_full after reset", fifo.almost_full, 1'b0);

            blocked_read();

            //fill the FIFO
            for(i = 0; i < DEPTH; i = i + 1) begin
                write_fifo(8'h20 + i);

                check_flag(
                    "almost_full while filling",
                    fifo.almost_full,
                    ((i + 1) >= ALMOST_FULL_LEVEL)
                );

                check_flag(
                    "full while filling",
                    fifo.full,
                    ((i + 1) == DEPTH)
                );
            end

            wait_read_side();
            check_flag(
                "almost_empty when full",
                fifo.almost_empty,
                1'b0
            );

            blocked_write();

            //empty the FIFO
            for(i = 0; i < DEPTH; i = i + 1) begin
                read_fifo();
                entries_left = DEPTH - i - 1;

                check_flag(
                    "almost_empty while reading",
                    fifo.almost_empty,
                    (entries_left <= ALMOST_EMPTY_LEVEL)
                );

                check_flag(
                    "empty while reading",
                    fifo.empty,
                    (entries_left == 0)
                );
            end

            if(sb_count != 0)
                test_error("Scoreboard was not empty after FIFO drain");

            wait_write_side();

            check_flag("full after drain", fifo.full, 1'b0);
            check_flag("almost_full after drain", fifo.almost_full, 1'b0);

            $display("Fill and empty test complete");
        end
    endtask

    //simultaneous read and write test
    task automatic simultaneous_read_write_test;
        integer i;
        begin
            $display("Starting simultaneous read and write test");

            reset_fifo();

            //start with some data in the FIFO
            for(i = 0; i < (DEPTH / 2); i = i + 1)
                write_fifo(8'h40 + i);

            wait_read_side();
            simultaneous_test = 1'b1;

            fork
                begin
                    for(i = 0; i < SIM_WRITES; i = i + 1)
                        write_fifo(8'h80 + i);
                end

                begin
                    integer j;
                    for(j = 0; j < ((DEPTH / 2) + SIM_WRITES); j = j + 1)
                        read_fifo();
                end
            join

            simultaneous_test = 1'b0;

            if(!saw_both_enables)
                test_error("Read and write enables did not overlap");

            if(sb_count != 0)
                test_error("Scoreboard was not empty after simultaneous test");

            fork
                wait_write_side();
                wait_read_side();
            join

            check_flag("empty after simultaneous test", fifo.empty, 1'b1);
            check_flag(
                "almost_empty after simultaneous test",
                fifo.almost_empty,
                1'b1
            );
            check_flag("full after simultaneous test", fifo.full, 1'b0);
            check_flag(
                "almost_full after simultaneous test",
                fifo.almost_full,
                1'b0
            );

            $display("Simultaneous read and write test complete");
        end
    endtask

    //main test
    initial begin
        error_count = 0;
        check_count = 0;
        simultaneous_test = 1'b0;

        fifo.w_rst_b = 1'b0;
        fifo.r_rst_b = 1'b0;
        fifo.write_en = 1'b0;
        fifo.read_en = 1'b0;
        fifo.w_data = '0;

        reset_fifo();
        fill_and_empty_test();
        simultaneous_read_write_test();

        if(error_count == 0) begin
            $display("ASYNC FIFO TESTBENCH PASSED (%0d checks)", check_count);
            $finish;
        end
        else begin
            $display("ASYNC FIFO TESTBENCH FAILED (%0d errors)", error_count);
            $fatal(1, "FIFO verification failed");
        end
    end

    //simulation timeout
    initial begin
        #1000000; /// 1000000 ns stuck timer
        $fatal(1, "Simulation timeout");
    end

endmodule

