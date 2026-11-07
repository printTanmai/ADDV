`timescale 1ns/1ps

module dpi_checker #(
	parameter int DATA_WIDTH = 8,
	parameter int DEPTH = 8
)(
	input logic                  w_clk,
	input logic                  r_clk,
	input logic                  w_rst_b,
	input logic                  r_rst_b,
	input logic                  write_en,
	input logic                  read_en,
	input logic [DATA_WIDTH-1:0] w_data,
	input logic [DATA_WIDTH-1:0] r_data,
	input logic                  full,
	input logic                  empty
);
	import "DPI-C" function int fifo_model_init(input int depth);
	import "DPI-C" function void fifo_model_reset();
	import "DPI-C" function int fifo_model_push(input int data);
	import "DPI-C" function int fifo_model_pop();
	import "DPI-C" function int fifo_model_is_empty();
	import "DPI-C" function int fifo_model_is_full();
	import "DPI-C" function int fifo_model_count();

	int empty_settle_cycles;
	int full_settle_cycles;
	int model_result;
	int expected_data;
	int model_empty;
	int model_full;
	int error_count;

	task automatic report_error(input string message);
		error_count = error_count + 1;
		$error("%s", message);
	endtask

	initial begin
		empty_settle_cycles = 3;
		full_settle_cycles = 3;
		error_count = 0;
		if (!fifo_model_init(DEPTH))
			$fatal(1, "DPI FIFO model initialization failed (depth=%0d)", DEPTH);
	end

	always @(negedge w_rst_b or negedge r_rst_b) begin
		if (!w_rst_b && !r_rst_b) begin
			fifo_model_reset();
			empty_settle_cycles = 3;
			full_settle_cycles = 3;
		end
	end

	always @(posedge w_clk) begin : write_model_update
		if (w_rst_b && write_en && !full) begin
			if (fifo_model_is_full()) begin
				report_error($sformatf("DUT accepted write data 0x%0h while the reference FIFO is full", w_data));
			end else begin
				model_result = fifo_model_push(int'(w_data));
				if (!model_result)
					report_error($sformatf("DPI model rejected accepted write data 0x%0h", w_data));
			end
			empty_settle_cycles = 3;
		end
	end

	always @(posedge r_clk) begin : read_model_update
		if (r_rst_b && read_en && !empty) begin
			expected_data = fifo_model_pop();
			if (expected_data < 0)
				report_error("DPI model underflow while DUT accepted a read");
			#1ps;
			if (r_data !== DATA_WIDTH'(expected_data))
				report_error($sformatf("FIFO data mismatch: expected 0x%0h, got 0x%0h at %0t",
								 DATA_WIDTH'(expected_data), r_data, $time));
			full_settle_cycles = 3;
		end
	end

	always @(posedge r_clk) begin : empty_flag_check
		if (r_rst_b) begin
			#1ps;
			model_empty = fifo_model_is_empty();
			if (empty_settle_cycles > 0)
				empty_settle_cycles = empty_settle_cycles - 1;
			else if (empty !== 1'(model_empty))
				report_error($sformatf("FIFO empty mismatch: model=%0b DUT=%0b at %0t",
								 model_empty, empty, $time));
		end
	end

	always @(posedge w_clk) begin : full_flag_check
		if (w_rst_b) begin
			#1ps;
			model_full = fifo_model_is_full();
			if (full_settle_cycles > 0)
				full_settle_cycles = full_settle_cycles - 1;
			else if (full !== 1'(model_full))
				report_error($sformatf("FIFO full mismatch: model=%0b DUT=%0b at %0t",
								 model_full, full, $time));
		end
	end
endmodule
