class fifo_monitor #(
	parameter int DATA_WIDTH = 8
);
	virtual fifo_write_if #(.DATA_WIDTH(DATA_WIDTH)).MONITOR write_vif;
	virtual fifo_read_if #(.DATA_WIDTH(DATA_WIDTH)).MONITOR read_vif;
	mailbox #(fifo_transaction #(DATA_WIDTH)) transaction_mb;
	int log_level;

	function new(
		virtual fifo_write_if #(.DATA_WIDTH(DATA_WIDTH)).MONITOR write_vif,
		virtual fifo_read_if #(.DATA_WIDTH(DATA_WIDTH)).MONITOR read_vif,
		mailbox #(fifo_transaction #(DATA_WIDTH)) transaction_mb
	);
		this.write_vif = write_vif;
		this.read_vif = read_vif;
		this.transaction_mb = transaction_mb;
		log_level = 0;
		if ($value$plusargs("FIFO_LOG=%d", log_level)) begin
			if ((log_level < 0) || (log_level > 2)) begin
				$display("[FIFO_MONITOR] Invalid FIFO_LOG=%0d; logging disabled (use 0, 1, or 2)", log_level);
				log_level = 0;
			end
		end
	endfunction

	// Run independent samplers because the FIFO has separate read/write clocks.
	task run();
		fork
			monitor_write_side();
			monitor_read_side();
		join
	endtask

	protected task monitor_write_side();
		fifo_transaction #(DATA_WIDTH) transaction;

		forever begin
			@(posedge write_vif.w_clk);
			if ((write_vif.w_rst_b === 1'b1) &&
			    (write_vif.write_en === 1'b1)) begin
				transaction = new();
				transaction.operation = FIFO_WRITE;
				transaction.w_data = write_vif.w_data;
				transaction.r_data = 'x;
				transaction.accepted = (write_vif.full === 1'b0);
				transaction.full = write_vif.full;
				transaction.almost_full = write_vif.almost_full;
				transaction.empty = 'x;
				transaction.almost_empty = 'x;
				transaction.timestamp = $time;
				transaction_mb.put(transaction);
				log_transaction(transaction);
			end
		end
	endtask

	protected task monitor_read_side();
		fifo_transaction #(DATA_WIDTH) transaction;

		forever begin
			@(posedge read_vif.r_clk);
			if ((read_vif.r_rst_b === 1'b1) &&
			    (read_vif.read_en === 1'b1)) begin
				transaction = new();
				transaction.operation = FIFO_READ;
				transaction.w_data = 'x;
				transaction.r_data = 'x;
				transaction.accepted = (read_vif.empty === 1'b0);
				transaction.full = 'x;
				transaction.almost_full = 'x;
				transaction.empty = read_vif.empty;
				transaction.almost_empty = read_vif.almost_empty;
				transaction.timestamp = $time;
				// FIFO memory updates r_data in the read clock's NBA region.
				#1ps;
				transaction.r_data = read_vif.r_data;
				transaction_mb.put(transaction);
				log_transaction(transaction);
			end
		end
	endtask

	protected function void log_transaction(fifo_transaction #(DATA_WIDTH) transaction);
		if (log_level == 1) begin
			$display("[FIFO_MONITOR] %s transaction generated at time %0t",
				(transaction.operation == FIFO_WRITE) ? "WRITE" : "READ",
				transaction.timestamp);
		end else if (log_level == 2) begin
			$display("[FIFO_MONITOR] transaction: operation=%s w_data=0x%0h r_data=0x%0h accepted=%0b full=%0b almost_full=%0b empty=%0b almost_empty=%0b timestamp=%0t",
				(transaction.operation == FIFO_WRITE) ? "WRITE" : "READ",
				transaction.w_data,
				transaction.r_data,
				transaction.accepted,
				transaction.full,
				transaction.almost_full,
				transaction.empty,
				transaction.almost_empty,
				transaction.timestamp);
		end
	endfunction
endclass
