interface oddeven_sva_if (
    input logic       clk,
    input logic       reset,
    input logic       write_en,
    input logic       read_en,
    input logic [7:0] data_in,
    input logic [7:0] data_out
);
    int hit_even_route = 0;
    int hit_odd_route = 0;
    int hit_even_empty_read = 0;
    int hit_odd_empty_read = 0;
    int hit_even_full_write = 0;
    int hit_odd_full_write = 0;
    int hit_arbiter_output = 0;
    int hit_output_read = 0;

    // Track assertion antecedents so the normal test cannot pass vacuously.
    always @(posedge clk) begin
        if(!reset) begin
            if(write_en && !data_in[0]) hit_even_route = hit_even_route + 1;
            if(write_en && data_in[0]) hit_odd_route = hit_odd_route + 1;
            if(read_en && oddeven_tb.dut.even_empty)
                hit_even_empty_read = hit_even_empty_read + 1;
            if(read_en && oddeven_tb.dut.odd_empty)
                hit_odd_empty_read = hit_odd_empty_read + 1;
            if(oddeven_tb.dut.even_full && oddeven_tb.dut.even_wen)
                hit_even_full_write = hit_even_full_write + 1;
            if(oddeven_tb.dut.odd_full && oddeven_tb.dut.odd_wen)
                hit_odd_full_write = hit_odd_full_write + 1;
            if(oddeven_tb.dut.arbiter_inst.can_output)
                hit_arbiter_output = hit_arbiter_output + 1;
            if(oddeven_tb.dut.even_ren || oddeven_tb.dut.odd_ren)
                hit_output_read = hit_output_read + 1;
        end
    end

    task automatic check_antecedent_coverage();
        $display("SVA antecedent hits: even-route=%0d odd-route=%0d even-empty-read=%0d odd-empty-read=%0d even-full-write=%0d odd-full-write=%0d arbiter=%0d output-read=%0d",
            hit_even_route, hit_odd_route, hit_even_empty_read, hit_odd_empty_read,
            hit_even_full_write, hit_odd_full_write, hit_arbiter_output,
            hit_output_read);
        if(hit_even_route == 0 || hit_odd_route == 0 ||
           hit_even_empty_read == 0 || hit_odd_empty_read == 0 ||
           hit_even_full_write == 0 || hit_odd_full_write == 0 ||
           hit_arbiter_output == 0 || hit_output_read == 0)
            $fatal(1, "one or more SVA antecedents were never exercised");
    endtask

    // XMRs probe internal DUT signals for these interface assertions.
    a_even_route: assert property (@(posedge clk) disable iff (reset)
        (write_en && !data_in[0]) |->
            (oddeven_tb.dut.even_wen && !oddeven_tb.dut.odd_wen))
        else $fatal(1, "even input was not routed exclusively to the even FIFO");

    a_odd_route: assert property (@(posedge clk) disable iff (reset)
        (write_en && data_in[0]) |->
            (oddeven_tb.dut.odd_wen && !oddeven_tb.dut.even_wen))
        else $fatal(1, "odd input was not routed exclusively to the odd FIFO");

    a_even_full_write_pointer_stable: assert property (@(posedge clk) disable iff (reset)
        (oddeven_tb.dut.even_full && oddeven_tb.dut.even_wen) |=>
            $stable(oddeven_tb.dut.even_fifo_inst.wptr))
        else $error("even FIFO write pointer changed while full");

    a_odd_full_write_pointer_stable: assert property (@(posedge clk) disable iff (reset)
        (oddeven_tb.dut.odd_full && oddeven_tb.dut.odd_wen) |=>
            $stable(oddeven_tb.dut.odd_fifo_inst.wptr))
        else $error("odd FIFO write pointer changed while full");

    a_even_empty_read_pointer_stable: assert property (@(posedge clk) disable iff (reset)
        (read_en && oddeven_tb.dut.even_empty) |=>
            $stable(oddeven_tb.dut.even_fifo_inst.rptr))
        else $error("even FIFO read pointer changed while empty");

    a_odd_empty_read_pointer_stable: assert property (@(posedge clk) disable iff (reset)
        (read_en && oddeven_tb.dut.odd_empty) |=>
            $stable(oddeven_tb.dut.odd_fifo_inst.rptr))
        else $error("odd FIFO read pointer changed while empty");

    // When output is available, exactly one FIFO read enable must be asserted.
    a_arbiter_onehot_when_output_possible: assert property (@(posedge clk) disable iff (reset)
        oddeven_tb.dut.arbiter_inst.can_output |->
            (oddeven_tb.dut.even_ren ^ oddeven_tb.dut.odd_ren))
        else $fatal(1, "arbiter did not assert exactly one FIFO read enable");

    a_output_matches_selected_head: assert property (@(posedge clk) disable iff (reset)
        (oddeven_tb.dut.even_ren || oddeven_tb.dut.odd_ren) |=>
            data_out == $past(oddeven_tb.dut.even_ren ?
                              oddeven_tb.dut.even_rdata :
                              oddeven_tb.dut.odd_rdata))
        else $error("output did not match the selected FIFO head");
endinterface
