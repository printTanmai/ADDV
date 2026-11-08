typedef enum logic {
	FIFO_WRITE,
	FIFO_READ
} fifo_operation_e;

// One requested FIFO operation and the results/status observed for it.
class fifo_transaction #(
	parameter int DATA_WIDTH = 8
);
	rand fifo_operation_e operation;
	rand logic [DATA_WIDTH-1:0] w_data;
	logic [DATA_WIDTH-1:0] r_data;
	logic accepted;

	logic full;
	logic almost_full;
	logic empty;
	logic almost_empty;
	time timestamp;

	function new();
		operation    = FIFO_WRITE;
		w_data       = '0;
		r_data       = '0;
		accepted     = 1'b0;
		full         = 1'b0;
		almost_full  = 1'b0;
		empty        = 1'b1;
		almost_empty = 1'b1;
		timestamp    = 0;
	endfunction

	function fifo_transaction #(DATA_WIDTH) copy();
		fifo_transaction #(DATA_WIDTH) transaction_copy;
		transaction_copy = new();

		transaction_copy.operation    = operation;
		transaction_copy.w_data       = w_data;
		transaction_copy.r_data       = r_data;
		transaction_copy.accepted     = accepted;
		transaction_copy.full         = full;
		transaction_copy.almost_full  = almost_full;
		transaction_copy.empty        = empty;
		transaction_copy.almost_empty = almost_empty;
		transaction_copy.timestamp    = timestamp;

		return transaction_copy;
	endfunction
endclass
