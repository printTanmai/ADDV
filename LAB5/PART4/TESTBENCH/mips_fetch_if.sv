// Passive observation interface. No DUT signal is driven by UVM.
interface mips_fetch_if(input logic clk);
    logic reset;
    logic [31:0] pc, instr;
    logic stallD, flushD, flushE;
    logic branch_E, pcsrc_E;
    logic [31:0] address_E;
    logic [31:0] operand_a_E, operand_b_E;
    logic done;
    int unsigned program_words;

    // Sample before the active edge: these are the values captured by the
    // pipeline registers, not their newly updated (post-NBA) values.
    clocking monitor_cb @(posedge clk);
        default input #1step;
        input reset, pc, instr;
        input stallD, flushD, flushE;
        input branch_E, pcsrc_E, address_E;
        input operand_a_E, operand_b_E;
        input done, program_words;
    endclocking
endinterface
