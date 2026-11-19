package mips_instruction_pkg;
    import uvm_pkg::*;

    localparam logic [5:0] OP_RTYPE = 6'b000000;
    localparam logic [5:0] OP_ADDI  = 6'b001000;
    localparam logic [5:0] OP_LW    = 6'b100011;
    localparam logic [5:0] OP_SW    = 6'b101011;
    localparam logic [5:0] OP_BEQ   = 6'b000100;

    localparam logic [5:0] FUNCT_ADD = 6'b100000;
    localparam logic [5:0] FUNCT_AND = 6'b100100;

    class instruction extends uvm_transaction;
        rand logic [5:0] opcode;
        rand logic [4:0] rs;
        rand logic [4:0] rt;
        rand logic [4:0] rd;
        rand logic [4:0] shamt;
        rand logic [5:0] funct;
        rand logic signed [15:0] immediate;

        constraint supported_opcode_c {
            opcode inside {OP_RTYPE, OP_ADDI, OP_LW, OP_SW, OP_BEQ};
        }

        constraint instruction_fields_c {
            if (opcode == OP_RTYPE) {
                funct inside {FUNCT_ADD, FUNCT_AND};
                shamt == 0;
                rs inside {[1:10]};
                rt inside {[1:10]};
                rd inside {[5:10]};
            } else if (opcode == OP_ADDI) {
                rs == 0;
                rt inside {[1:10]};
                immediate inside {[1:31]};
            } else if (opcode == OP_LW) {
                rs == 0;
                rt inside {[5:10]};
                immediate inside {16'sd0, 16'sd4, 16'sd8};
            } else if (opcode == OP_SW) {
                rs == 0;
                rt inside {[1:10]};
                immediate inside {[0:248]};
                immediate[1:0] == 0;
            } else {
                rs inside {[1:10]};
                rt inside {[1:10]};
                immediate inside {[-16:16]};
            }
        }

        function new(string name = "instruction");
            super.new(name);
        endfunction

        function logic [31:0] to_machine_code();
            if (opcode == OP_RTYPE)
                return {opcode, rs, rt, rd, shamt, funct};
            return {opcode, rs, rt, immediate};
        endfunction
    endclass

    class instruction_sequence extends uvm_object;
        rand int unsigned add_gap;
        rand int unsigned pair_gap;
        rand int unsigned random_count;
        logic [31:0] instruction_words[];

        constraint sequence_size_c {
            add_gap inside {[0:3]};
            pair_gap inside {[0:3]};
            random_count inside {[6:10]};
        }

        function new(string name = "instruction_sequence");
            super.new(name);
            instruction_words = new[0];
        endfunction

        function void append_word(logic [31:0] word);
            logic [31:0] resized_words[];
            int unsigned old_size;

            old_size = instruction_words.size();
            resized_words = new[old_size + 1];
            foreach (instruction_words[i])
                resized_words[i] = instruction_words[i];
            resized_words[old_size] = word;
            instruction_words = resized_words;
        endfunction

        function bit append_addi(logic [4:0] destination,
                                 logic signed [15:0] value);
            instruction tr;
            tr = new("setup_addi");
            tr.opcode = OP_ADDI;
            tr.rs = 5'd0;
            tr.rt = destination;
            tr.immediate = value;
            append_word(tr.to_machine_code());
            return 1;
        endfunction

        function bit append_store(logic [4:0] source,
                                  logic signed [15:0] offset);
            instruction tr;
            tr = new("store");
            tr.opcode = OP_SW;
            tr.rs = 5'd0;
            tr.rt = source;
            tr.immediate = offset;
            append_word(tr.to_machine_code());
            return 1;
        endfunction

        function bit append_load(logic [4:0] destination,
                                 logic signed [15:0] offset);
            instruction tr;
            tr = new("load");
            tr.opcode = OP_LW;
            tr.rs = 5'd0;
            tr.rt = destination;
            tr.immediate = offset;
            append_word(tr.to_machine_code());
            return 1;
        endfunction

        function bit append_random();
            instruction tr;
            tr = new("random_instruction");
            if (!tr.randomize() with {
                opcode inside {OP_RTYPE, OP_LW, OP_SW};
            })
                return 0;
            append_word(tr.to_machine_code());
            return 1;
        endfunction

        function bit append_add_gap_random();
            instruction tr;
            tr = new("add_gap_instruction");
            if (!tr.randomize() with {
                opcode inside {OP_RTYPE, OP_LW, OP_SW};
                if (opcode == OP_RTYPE)
                    rd != 5'd5;
                if (opcode == OP_LW)
                    rt != 5'd5;
            })
                return 0;
            append_word(tr.to_machine_code());
            return 1;
        endfunction

        function bit append_memory_gap_random();
            instruction tr;
            tr = new("memory_gap_instruction");
            if (!tr.randomize() with {
                opcode inside {OP_RTYPE, OP_LW, OP_SW};
                if (opcode == OP_SW)
                    immediate != 16'sd8;
            })
                return 0;
            append_word(tr.to_machine_code());
            return 1;
        endfunction

        function bit append_add_dependency_pair();
            instruction tr;
            int unsigned gap_index;

            tr = new("dependent_add");
            if (!tr.randomize() with {
                opcode == OP_RTYPE;
                funct == FUNCT_ADD;
                rs == 5'd1;
                rt == 5'd2;
                rd == 5'd5;
            })
                return 0;
            append_word(tr.to_machine_code());

            for (gap_index = 0; gap_index < add_gap; gap_index++)
                if (!append_add_gap_random())
                    return 0;

            tr = new("dependent_and");
            if (!tr.randomize() with {
                opcode == OP_RTYPE;
                funct == FUNCT_AND;
                rs == 5'd5;
                rt == 5'd1;
                rd == 5'd6;
            })
                return 0;
            append_word(tr.to_machine_code());

            return 1;
        endfunction

        function bit append_branch(bit taken);
            instruction tr;
            tr = new(taken ? "taken_branch" : "not_taken_branch");

            if (taken) begin
                if (!tr.randomize() with {
                    opcode == OP_BEQ;
                    rs == 5'd1;
                    rt == 5'd1;
                    immediate == 16'sd1;
                })
                    return 0;
            end else begin
                if (!tr.randomize() with {
                    opcode == OP_BEQ;
                    rs == 5'd1;
                    rt == 5'd2;
                    immediate == 16'sd1;
                })
                    return 0;
            end

            append_word(tr.to_machine_code());
            return 1;
        endfunction

        function bit generate_program();
            int unsigned reg_index;
            int unsigned gap_index;
            int unsigned random_index;

            instruction_words = new[0];

            if (!randomize())
                return 0;

            // Basic register setup
            for (reg_index = 1; reg_index <= 10; reg_index++)
                append_addi(reg_index[4:0], 16'(reg_index * 3 + 1));

            // Basic memory setup
            append_store(5'd1, 16'sd0);
            append_store(5'd2, 16'sd4);

            // ADD -> AND dependency with random gap
            if (!append_add_dependency_pair())
                return 0;

            // SW -> LW dependency with random gap
            append_store(5'd5, 16'sd8);

            for (gap_index = 0; gap_index < pair_gap; gap_index++)
                if (!append_memory_gap_random())
                    return 0;

            append_load(5'd7, 16'sd8);

            // Taken and not-taken branches
            if (!append_branch(1'b1) || !append_random() || !append_random())
                return 0;

            if (!append_branch(1'b0) || !append_random() || !append_random())
                return 0;

            // Random instruction sequence
            for (random_index = 0; random_index < random_count; random_index++)
                if (!append_random())
                    return 0;

            // End simulation marker
            append_store(5'd0, 16'sd252);

            if (instruction_words.size() > 64)
                return 0;

            return 1;
        endfunction
    endclass

endpackage