// This file is included inside mips_part3_pkg after the instruction class.
// A gap is the number of executed instructions BETWEEN a producer and consumer.
class instruction_sequence extends uvm_object;
    `uvm_object_utils(instruction_sequence)

    logic [31:0] instruction_words[];
    logic [31:0] words_q[$];
    bit [31:0] model_regs[0:4];
    bit [31:0] model_mem[0:3];
    string mode;
    int case_id;
    rand int unsigned register_gap;
    rand int unsigned memory_gap;
    rand int unsigned producer_register;
    rand int unsigned memory_index;

    constraint template_c {
        register_gap inside {[1:4]};
        memory_gap inside {[1:4]};
        producer_register inside {[1:4]};
        memory_index inside {[0:3]};
    }

    function new(string name = "instruction_sequence");
        super.new(name);
    endfunction

    // The small model is used only to select known taken/not-taken BEQ inputs.
    // It is not the checker, and it never supplies values to the coverage bins.
    function void remember(instruction tr);
        case (tr.kind)
            K_ADD: model_regs[tr.rd] = model_regs[tr.rs] + model_regs[tr.rt];
            K_AND: model_regs[tr.rd] = model_regs[tr.rs] & model_regs[tr.rt];
            K_LW:  model_regs[tr.rt] = model_mem[int'(tr.immediate) / 4];
            K_SW:  model_mem[int'(tr.immediate) / 4] = model_regs[tr.rt];
            default: ;
        endcase
    endfunction

    function void emit(instr_kind_e selected_kind, int source_a = -1,
                       int source_b = -1, int destination = -1,
                       int offset = -1);
        instruction tr;
        tr = new("generated_instruction");
        if (!tr.randomize() with {
            kind == local::selected_kind;
            if (local::source_a >= 0) rs == local::source_a;
            if (local::source_b >= 0) rt == local::source_b;
            if (local::destination >= 0) rd == local::destination;
            if (local::offset >= 0) immediate == local::offset;
        }) begin
            `uvm_fatal("GEN_RANDOMIZE", "Could not generate a valid instruction")
        end
        words_q.push_back(tr.to_machine_code());
        remember(tr);
    endfunction

    function void setup_register(int register_number, int value);
        instruction tr;
        tr = new("setup_addi");
        tr.kind = K_SETUP;
        tr.rs = 0;
        tr.rt = register_number;
        tr.immediate = value;
        words_q.push_back(tr.to_machine_code());
        model_regs[register_number] = value;
    endfunction

    function void setup_program();
        foreach (model_regs[r]) model_regs[r] = 0;
        foreach (model_mem[m]) model_mem[m] = 0;
        for (int r = 1; r <= 4; r++) setup_register(r, r);
        for (int m = 0; m < 4; m++) emit(K_SW, 0, m + 1, -1, m * 4);
    endfunction

    // AND a register with itself. It changes no architectural state and can
    // preserve a selected producer's value or a selected memory location.
    function void filler(int avoid_register = 0);
        int r;
        r = (avoid_register % 4) + 1;
        emit(K_AND, r, r, r);
    endfunction

    function void branch_inputs(bit taken, output int source_a,
                                output int source_b);
        source_a = $urandom_range(1, 4);
        source_b = source_a;
        if (!taken) begin
            for (int a = 1; a <= 4; a++) begin
                for (int b = 1; b <= 4; b++) begin
                    if (model_regs[a] != model_regs[b]) begin
                        source_a = a;
                        source_b = b;
                        return;
                    end
                end
            end
            `uvm_fatal("BEQ_INPUTS", "No unequal pair exists for a not-taken BEQ")
        end
    endfunction

    function void branch_block(bit taken, int offset);
        int a, b;
        branch_inputs(taken, a, b);
        emit(K_BEQ, a, b, -1, offset);
        // Positive branch offsets always land inside the generated program.
        // Fillers on the skipped path are harmless AND-self instructions.
        repeat (offset) filler();
    endfunction

    function void register_pair(int register_number, int gap);
        emit(K_ADD, -1, -1, register_number);
        repeat (gap) filler(register_number);
        emit(K_AND, register_number, -1, -1);
    endfunction

    function void memory_pair(int address_index, int gap);
        emit(K_SW, 0, -1, -1, address_index * 4);
        repeat (gap) filler();
        emit(K_LW, 0, -1, -1, address_index * 4);
    endfunction

    function instr_kind_e kind_from_index(int index);
        case (index)
            0: return K_ADD;
            1: return K_AND;
            2: return K_LW;
            3: return K_SW;
            default: return K_BEQ;
        endcase
    endfunction

    function void emit_order_kind(instr_kind_e selected_kind);
        int a, b;
        if (selected_kind == K_BEQ) begin
            // A not-taken branch keeps the ordered pair adjacent at execution.
            branch_inputs(0, a, b);
            emit(K_BEQ, a, b, -1, 1);
        end else begin
            emit(selected_kind);
        end
    endfunction

    function void initial_program();
        // A first, deliberately short run. Closure runs fill its missing bins.
        // Branches come before random arithmetic so unequal setup values exist.
        branch_block(0, $urandom_range(1, 4));
        branch_block(1, $urandom_range(1, 4));
        register_pair(producer_register, register_gap);
        memory_pair(memory_index, memory_gap);
        repeat (6) begin
            case ($urandom_range(0, 3))
                0: emit(K_ADD);
                1: emit(K_AND);
                2: emit(K_LW);
                3: emit(K_SW);
            endcase
        end
    endfunction

    function void closure_program();
        int selected;
        int r, next_r, third_r;
        if (case_id < 25) begin
            // All 25 adjacent instruction-kind orders, including BEQ pairs.
            emit_order_kind(kind_from_index(case_id / 5));
            emit_order_kind(kind_from_index(case_id % 5));
            // A branch in the second position may target this padding word.
            filler();
        end else if (case_id < 41) begin
            selected = case_id - 25;
            register_pair((selected / 4) + 1, (selected % 4) + 1);
        end else if (case_id < 57) begin
            selected = case_id - 41;
            memory_pair(selected / 4, (selected % 4) + 1);
        end else if (case_id < 65) begin
            selected = case_id - 57;
            branch_block(bit'(selected / 4), (selected % 4) + 1);
        end else if (case_id < 69) begin
            // Four field sweeps guarantee all register bins, all memory bins,
            // and representative actual RAW dependencies for each producer.
            r = case_id - 64;
            next_r = (r % 4) + 1;
            third_r = (next_r % 4) + 1;

            emit(K_BEQ, r, r, -1, 1);
            filler();
            emit(K_BEQ, r, next_r, -1, 1);
            filler();

            for (int m = 0; m < 4; m++) begin
                emit(K_LW, 0, r, -1, m * 4);
                filler(r);
                emit(K_SW, 0, r, -1, m * 4);
            end

            emit(K_LW, 0, r, -1, 0);
            filler(r);
            emit(K_ADD, r, next_r, third_r);
            filler(third_r);
            emit(K_AND, next_r, third_r, r);
            filler(r);
            emit(K_SW, 0, r, -1, 0);
            emit(K_ADD, next_r, next_r, r);
            filler(r);
            emit(K_BEQ, r, r, -1, 1);
            filler();
        end else begin
            `uvm_fatal("GEN_CASE", "Closure CASE must be in the range 0..68")
        end
    endfunction

    function bit generate_program();
        int unused;
        words_q.delete();
        mode = "initial";
        case_id = 0;
        unused = $value$plusargs("MODE=%s", mode);
        unused = $value$plusargs("CASE=%d", case_id);
        if (!randomize()) return 0;

        setup_program();
        if (mode == "initial") initial_program();
        else if (mode == "closure") closure_program();
        else begin
            `uvm_error("GEN_MODE", "MODE must be initial or closure")
            return 0;
        end

        // Trick-box store: no new ISA opcode, just SW to a reserved address.
        // The monitor excludes this control marker from functional coverage.
        words_q.push_back({6'b101011, 5'd0, 5'd0, 16'd252});
        if (words_q.size() > 64) begin
            `uvm_error("GEN_SIZE", "Generated program exceeds 64-word instruction RAM")
            return 0;
        end
        instruction_words = new[words_q.size()];
        foreach (instruction_words[i]) instruction_words[i] = words_q[i];
        `uvm_info("GEN_PROGRAM", $sformatf("MODE=%s CASE=%0d words=%0d register_gap=%0d memory_gap=%0d", mode, case_id, instruction_words.size(), register_gap, memory_gap), UVM_LOW)
        return 1;
    endfunction
endclass
