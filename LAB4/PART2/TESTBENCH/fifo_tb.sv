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
	int drop_every = 0;

	always #5ns w_clk = ~w_clk;
	always #7ns r_clk = ~r_clk;

	initial begin
		if ($value$plusargs("DROP_EVERY=%d", drop_every)) begin
			$display("[TB] RTL fault injection enabled: drop every %0d accepted write request", drop_every);
		end
	end

	fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_bus();

	assign fifo_bus.w_clk = w_clk;
	assign fifo_bus.r_clk = r_clk;
	assign fifo_bus.w_rst_b = w_rst_b;
	assign fifo_bus.r_rst_b = r_rst_b;
	assign fifo_bus.write_en = write_en;
	assign fifo_bus.read_en = read_en;
	assign fifo_bus.w_data = w_data;
	assign r_data = fifo_bus.r_data;
	assign full = fifo_bus.full;
	assign empty = fifo_bus.empty;
	assign almost_full = fifo_bus.almost_full;
	assign almost_empty = fifo_bus.almost_empty;

	async_fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(DEPTH)
	) dut (
		.fifo(fifo_bus)
	);

	dpi_checker #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(DEPTH)
	) checker (
		.w_clk(w_clk),
		.r_clk(r_clk),
		.w_rst_b(w_rst_b),
		.r_rst_b(r_rst_b),
		.write_en(write_en),
		.read_en(read_en),
		.w_data(w_data),
		.r_data(r_data),
		.full(full),
		.empty(empty)
	);

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
		int rounds;

		repeat (4) @(posedge w_clk);
		repeat (4) @(posedge r_clk);
		w_rst_b = 1'b1;
		r_rst_b = 1'b1;
		repeat (4) @(posedge w_clk);
		repeat (4) @(posedge r_clk);

		rounds = (drop_every > 0) ? 1 : 3;
		// Fill to full, attempt an over-capacity write, then drain to empty.
		// Repeating the sequence wraps both pointers through the whole memory.
		for (round = 0; round < rounds; round++) begin
			for (item = 0; item < DEPTH; item++)
				write_word((round * DEPTH + item) & 8'hff);

			repeat (3) @(posedge w_clk);
			if ((drop_every == 0) && (full !== 1'b1))
				$error("Expected full after filling FIFO (round %0d)", round);

			write_word(8'hfe);
			repeat (3) @(posedge w_clk);

			for (item = 0; item < DEPTH; item++)
				read_word();

			repeat (3) @(posedge r_clk);
			if ((drop_every == 0) && (empty !== 1'b1))
				$error("Expected empty after draining FIFO (round %0d)", round);
		end

		if (checker.error_count != 0)
			$fatal(1, "FIFO DPI test failed with %0d checker error(s)", checker.error_count);
		$display("FIFO DPI test passed");
		$finish;
	end

initial begin
    $fsdbDumpfile("novas.fsdb");
    $fsdbDumpvars(0, fifo_tb);
end
endmodule
