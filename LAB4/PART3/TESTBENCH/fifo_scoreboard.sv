class fifo_scoreboard #(
	parameter int DATA_WIDTH = 8,
	parameter int DEPTH = 8
);
	mailbox #(fifo_transaction #(DATA_WIDTH)) transaction_mb;
	logic [DATA_WIDTH-1:0] expected_q[$];

	function new(mailbox #(fifo_transaction #(DATA_WIDTH)) transaction_mb);
		this.transaction_mb = transaction_mb;
	endfunction

	// Consume monitored operations and update/check the reference FIFO model.
	task run();
		fifo_transaction #(DATA_WIDTH) transaction;
		logic [DATA_WIDTH-1:0] expected_data;

		forever begin
			transaction_mb.get(transaction);

			case (transaction.operation)
				FIFO_WRITE: begin
					if (transaction.accepted) begin
						if (expected_q.size() >= DEPTH) begin
							$error("[FIFO_SCOREBOARD] Accepted write while reference FIFO is full: data=0x%0h time=%0t",
								transaction.w_data, transaction.timestamp);
						end else begin
							expected_q.push_back(transaction.w_data);
						end
					end else if (transaction.full !== 1'b1) begin
						$error("[FIFO_SCOREBOARD] Write request was not accepted while full was not asserted: data=0x%0h time=%0t",
							transaction.w_data, transaction.timestamp);
					end
				end

				FIFO_READ: begin
					if (transaction.accepted) begin
						if (expected_q.size() == 0) begin
							$error("[FIFO_SCOREBOARD] Accepted read while reference FIFO is empty: time=%0t",
								transaction.timestamp);
						end else begin
							expected_data = expected_q.pop_front();
							if (transaction.r_data !== expected_data) begin
								$error("[FIFO_SCOREBOARD] Data mismatch: expected=0x%0h actual=0x%0h time=%0t",
									expected_data, transaction.r_data, transaction.timestamp);
							end else begin
								$display("[FIFO_SCOREBOARD] Read matched: data=0x%0h occupancy=%0d time=%0t",
									transaction.r_data, expected_q.size(), transaction.timestamp);
							end
						end
					end else if (transaction.empty !== 1'b1) begin
						$error("[FIFO_SCOREBOARD] Read request was not accepted while empty was not asserted: time=%0t",
							transaction.timestamp);
					end
				end

				default: $error("[FIFO_SCOREBOARD] Unknown operation in transaction at time %0t",
					transaction.timestamp);
			endcase
		end
	endtask
endclass
