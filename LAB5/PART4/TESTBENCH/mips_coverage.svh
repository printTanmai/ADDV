`ifndef MIPS_COVERAGE_SVH
`define MIPS_COVERAGE_SVH

// The monitor supplies instructions that really reach EX, rather than counting
// the same fetch repeatedly during a stall or counting a flushed instruction.
class mips_coverage extends uvm_subscriber #(instruction);
    `uvm_component_utils(mips_coverage)

    instruction history[$];
    int unsigned instruction_count;
    int unsigned register_dependency_count;
    int unsigned memory_dependency_count;

    // Individual instruction fields. Setup ADDIs and the completion store are
    // excluded by write(), so they cannot inflate the requested coverage.
    covergroup cg_fields with function sample(
        instr_kind_e kind,
        bit [4:0] rs,
        bit [4:0] rt,
        bit [4:0] rd,
        bit [31:0] address,
        int signed branch_offset,
        bit branch_taken
    );
        option.per_instance = 1;

        cp_kind: coverpoint kind {
            bins add_op = {K_ADD};
            bins and_op = {K_AND};
            bins load_op = {K_LW};
            bins store_op = {K_SW};
            bins branch_op = {K_BEQ};
        }

        cp_alu_rs: coverpoint rs iff (kind inside {K_ADD, K_AND}) {
            bins regs[] = {[1:4]};
        }
        cp_alu_rt: coverpoint rt iff (kind inside {K_ADD, K_AND}) {
            bins regs[] = {[1:4]};
        }
        cp_alu_rd: coverpoint rd iff (kind inside {K_ADD, K_AND}) {
            bins regs[] = {[1:4]};
        }

        cp_mem_rt: coverpoint rt iff (kind inside {K_LW, K_SW}) {
            bins regs[] = {[1:4]};
        }
        cp_mem_address: coverpoint address iff (kind inside {K_LW, K_SW}) {
            bins words[] = {32'd0, 32'd4, 32'd8, 32'd12};
        }

        cp_branch_rs: coverpoint rs iff (kind == K_BEQ) {
            bins regs[] = {[1:4]};
        }
        cp_branch_rt: coverpoint rt iff (kind == K_BEQ) {
            bins regs[] = {[1:4]};
        }
        cp_branch_offset: coverpoint branch_offset iff (kind == K_BEQ) {
            bins offsets[] = {[1:4]};
        }
        cp_branch_taken: coverpoint branch_taken iff (kind == K_BEQ) {
            bins not_taken = {0};
            bins taken = {1};
        }
        branch_offset_x_outcome: cross cp_branch_offset, cp_branch_taken;
    endgroup

    // Ordered adjacent instruction pairs: ADD->AND differs from AND->ADD.
    // Each side has five explicit bins, producing 25 meaningful combinations.
    covergroup cg_order with function sample(
        instr_kind_e previous_kind,
        instr_kind_e current_kind
    );
        option.per_instance = 1;
        cp_previous: coverpoint previous_kind {
            bins add_op = {K_ADD};
            bins and_op = {K_AND};
            bins load_op = {K_LW};
            bins store_op = {K_SW};
            bins branch_op = {K_BEQ};
        }
        cp_current: coverpoint current_kind {
            bins add_op = {K_ADD};
            bins and_op = {K_AND};
            bins load_op = {K_LW};
            bins store_op = {K_SW};
            bins branch_op = {K_BEQ};
        }
        ordered_pair: cross cp_previous, cp_current;
    endgroup

    // A gap is the number of INTERVENING executed target instructions. It is
    // not a cycle count and not the difference between instruction addresses.
    covergroup cg_raw with function sample(
        instr_kind_e producer,
        instr_kind_e consumer,
        int unsigned gap,
        bit [4:0] register_number
    );
        option.per_instance = 1;
        cp_producer: coverpoint producer {
            bins add_op = {K_ADD};
            bins and_op = {K_AND};
            bins load_op = {K_LW};
        }
        cp_consumer: coverpoint consumer {
            bins add_op = {K_ADD};
            bins and_op = {K_AND};
            bins store_op = {K_SW};
            bins branch_op = {K_BEQ};
        }
        cp_gap: coverpoint gap { bins intervening[] = {[1:4]}; }
        cp_register: coverpoint register_number { bins regs[] = {[1:4]}; }
        register_x_gap: cross cp_register, cp_gap;
    endgroup

    // Explicitly cover the lab's example ADD->AND RAW dependency, including
    // every selected register and every selected instruction gap.
    covergroup cg_add_and with function sample(
        int unsigned gap,
        bit [4:0] register_number
    );
        option.per_instance = 1;
        cp_gap: coverpoint gap { bins intervening[] = {[1:4]}; }
        cp_register: coverpoint register_number { bins regs[] = {[1:4]}; }
        register_x_gap: cross cp_register, cp_gap;
    endgroup

    // Only the most recent preceding SW to this address can establish the
    // store-to-load memory dependency. Intervening overwrites are not counted.
    covergroup cg_store_load with function sample(
        int unsigned gap,
        bit [31:0] address
    );
        option.per_instance = 1;
        cp_gap: coverpoint gap { bins intervening[] = {[1:4]}; }
        cp_address: coverpoint address {
            bins words[] = {32'd0, 32'd4, 32'd8, 32'd12};
        }
        address_x_gap: cross cp_address, cp_gap;
    endgroup

    function new(string name = "mips_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_fields = new();
        cg_order = new();
        cg_raw = new();
        cg_add_and = new();
        cg_store_load = new();
        instruction_count = 0;
        register_dependency_count = 0;
        memory_dependency_count = 0;
    endfunction

    virtual function void write(instruction tr);
        int unsigned gap;
        instruction saved;

        if (tr == null)
            `uvm_fatal("NULL_TRANSACTION", "Coverage received a null transaction")

        if (!(tr.kind inside {K_ADD, K_AND, K_LW, K_SW, K_BEQ}))
            return;

        // 0xFC belongs to the testbench trick-box, not the four data words.
        if ((tr.kind == K_SW) && (tr.address == 32'h0000_00fc))
            return;

        instruction_count++;
        cg_fields.sample(tr.kind, tr.rs, tr.rt, tr.rd, tr.address,
                         int'($signed(tr.immediate)), tr.branch_taken);

        if (history.size() != 0)
            cg_order.sample(history[$].kind, tr.kind);

        // Scan backward independently for each source register. Stop at the
        // latest writer even when its gap is zero, so an older overwritten
        // value can never be claimed as a surviving RAW dependency.
        for (int r = 1; r <= 4; r++) begin
            if (tr.reads_reg(5'(r))) begin
                for (int i = history.size() - 1; i >= 0; i--) begin
                    if (history[i].writes_reg() &&
                        (history[i].dest_reg() == 5'(r))) begin
                        gap = history.size() - 1 - i;
                        if ((gap >= 1) && (gap <= 4)) begin
                            cg_raw.sample(history[i].kind, tr.kind, gap, 5'(r));
                            register_dependency_count++;
                            if ((history[i].kind == K_ADD) && (tr.kind == K_AND))
                                cg_add_and.sample(gap, 5'(r));
                        end
                        break;
                    end
                end
            end
        end

        if (tr.kind == K_LW) begin
            for (int i = history.size() - 1; i >= 0; i--) begin
                if ((history[i].kind == K_SW) &&
                    (history[i].address == tr.address)) begin
                    gap = history.size() - 1 - i;
                    if ((gap >= 1) && (gap <= 4)) begin
                        cg_store_load.sample(gap, tr.address);
                        memory_dependency_count++;
                    end
                    break;
                end
            end
        end

        // Retain a snapshot, not the caller's mutable transaction handle.
        saved = new("coverage_history");
        saved.kind = tr.kind;
        saved.rs = tr.rs;
        saved.rt = tr.rt;
        saved.rd = tr.rd;
        saved.opcode = tr.opcode;
        saved.funct = tr.funct;
        saved.pc = tr.pc;
        saved.raw = tr.raw;
        saved.immediate = tr.immediate;
        saved.address = tr.address;
        saved.branch_taken = tr.branch_taken;
        history.push_back(saved);
        if (history.size() > 5)
            saved = history.pop_front();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COVERAGE", $sformatf(
            "Sampled %0d target instructions, %0d register dependencies, %0d memory dependencies",
            instruction_count, register_dependency_count, memory_dependency_count), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Instruction fields: %0.2f%%", cg_fields.get_inst_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Ordered pairs: %0.2f%%", cg_order.get_inst_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Register RAW: %0.2f%%", cg_raw.get_inst_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("ADD -> AND: %0.2f%%", cg_add_and.get_inst_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("SW -> LW: %0.2f%%", cg_store_load.get_inst_coverage()), UVM_LOW)
    endfunction
endclass

`endif
