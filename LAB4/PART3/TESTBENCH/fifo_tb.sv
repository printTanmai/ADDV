`timescale 1ns/1ps

module fifo_tb;
	localparam int DATA_WIDTH = 8;
	localparam int DEPTH = 8;

	logic w_clk = 1'b0;
	logic r_clk = 1'b0;
	logic w_rst_b = 1'b0;
	logic r_rst_b = 1'b0;
	logic write_en = 1'b0;
	logic read_en = 1'b0;
	logic [DATA_WIDTH-1:0] w_data = '0;
	logic [DATA_WIDTH-1:0] r_data;
	logic full;
	logic empty;
	logic almost_full;
	logic almost_empty;

	always #5ns w_clk = ~w_clk;
	always #7ns r_clk = ~r_clk;

	fifo_write_if #(.DATA_WIDTH(DATA_WIDTH)) write_bus(.w_clk(w_clk));
	fifo_read_if #(.DATA_WIDTH(DATA_WIDTH)) read_bus(.r_clk(r_clk));

	assign write_bus.w_rst_b = w_rst_b;
	assign write_bus.write_en = write_en;
	assign write_bus.w_data = w_data;
	assign full = write_bus.full;
	assign almost_full = write_bus.almost_full;

	assign read_bus.r_rst_b = r_rst_b;
	assign read_bus.read_en = read_en;
	assign r_data = read_bus.r_data;
	assign empty = read_bus.empty;
	assign almost_empty = read_bus.almost_empty;

	async_fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(DEPTH)
	) dut (
		.write_fifo(write_bus),
		.read_fifo(read_bus)
	);

	mailbox #(fifo_transaction #(DATA_WIDTH)) transaction_mb;
	fifo_monitor #(.DATA_WIDTH(DATA_WIDTH)) monitor;
	fifo_scoreboard #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) scoreboard;

	initial begin : start_verification_components
		transaction_mb = new();
		monitor = new(write_bus, read_bus, transaction_mb);
		scoreboard = new(transaction_mb);
		fork
			monitor.run();
			scoreboard.run();
		join_none
	end

	task automatic write_word(input logic [DATA_WIDTH-1:0] data);
		@(negedge w_clk);
		w_data = data;
		write_en = 1'b1;
		@(negedge w_clk);
		write_en = 1'b0;
	endtask

	task automatic read_word();
		@(negedge r_clk);
		read_en = 1'b1;
		@(negedge r_clk);
		read_en = 1'b0;
	endtask

	initial begin : stimulus
		int round;
		int item;

		repeat (4) @(posedge w_clk);
		repeat (4) @(posedge r_clk);
		w_rst_b = 1'b1;
		r_rst_b = 1'b1;
		repeat (4) @(posedge w_clk);
		repeat (4) @(posedge r_clk);

		// Fill to full, attempt an over-capacity write, then drain to empty.
		// Repeating the sequence wraps both pointers through the whole memory.
		for (round = 0; round < 3; round++) begin
			for (item = 0; item < DEPTH; item++)
				write_word((round * DEPTH + item) & 8'hff);

			repeat (3) @(posedge w_clk);
			if (full !== 1'b1)
				$error("Expected full after filling FIFO (round %0d)", round);

			write_word(8'hfe);
			repeat (3) @(posedge w_clk);

			for (item = 0; item < DEPTH; item++)
				read_word();

			repeat (3) @(posedge r_clk);
			if (empty !== 1'b1)
				$error("Expected empty after draining FIFO (round %0d)", round);
		end

		$display("FIFO SystemVerilog scoreboard test completed");
		$finish;
	end

	initial begin : waveform_dump
		$fsdbDumpfile("fifo.fsdb");
		$fsdbDumpvars(0, fifo_tb);
	end
endmodule
