package mips_part3_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum int {K_ADD, K_AND, K_LW, K_SW, K_BEQ, K_SETUP, K_OTHER}
        instr_kind_e;

    // Instruction object used both by the generator and passive monitor.
    class instruction extends uvm_transaction;
        `uvm_object_utils(instruction)

        rand instr_kind_e kind;
        rand bit [4:0] rs, rt, rd;
        rand bit signed [15:0] immediate;
        bit [5:0] opcode, funct;
        logic [31:0] pc, raw;
        bit [31:0] address;
        bit branch_taken;
        time observed_at;

        constraint valid_kind_c {
            kind inside {K_ADD, K_AND, K_LW, K_SW, K_BEQ};
        }
        constraint valid_fields_c {
            if (kind inside {K_ADD, K_AND}) {
                rs inside {[1:4]}; rt inside {[1:4]}; rd inside {[1:4]};
            }
            if (kind inside {K_LW, K_SW}) {
                rs == 0; rt inside {[1:4]};
                immediate inside {16'sd0,16'sd4,16'sd8,16'sd12};
            }
            if (kind == K_BEQ) {
                rs inside {[1:4]}; rt inside {[1:4]};
                immediate inside {[1:4]};
            }
        }

        function new(string name="instruction");
            super.new(name);
        endfunction

        function logic [31:0] to_machine_code();
            case (kind)
                K_ADD: return {6'b000000,rs,rt,rd,5'b0,6'b100000};
                K_AND: return {6'b000000,rs,rt,rd,5'b0,6'b100100};
                K_LW:  return {6'b100011,rs,rt,immediate};
                K_SW:  return {6'b101011,rs,rt,immediate};
                K_BEQ: return {6'b000100,rs,rt,immediate};
                K_SETUP: return {6'b001000,rs,rt,immediate};
                default: return 32'h00000020; // ADD $zero,$zero,$zero
            endcase
        endfunction

        function void decode(logic [31:0] word);
            raw = word;
            opcode = word[31:26]; funct = word[5:0];
            rs = word[25:21]; rt = word[20:16]; rd = word[15:11];
            immediate = word[15:0];
            kind = K_OTHER;
            case (opcode)
                6'h00: begin
                    if (funct == 6'h20) kind = K_ADD;
                    if (funct == 6'h24) kind = K_AND;
                end
                6'h23: kind = K_LW;
                6'h2b: kind = K_SW;
                6'h04: kind = K_BEQ;
                6'h08: kind = K_SETUP;
                default: kind = K_OTHER;
            endcase
        endfunction

        function bit writes_reg();
            return kind inside {K_ADD,K_AND,K_LW};
        endfunction

        function bit [4:0] dest_reg();
            return (kind == K_LW) ? rt : rd;
        endfunction

        function bit reads_reg(bit [4:0] regnum);
            if (regnum == 0) return 0;
            case (kind)
                K_ADD,K_AND,K_SW,K_BEQ: return rs == regnum || rt == regnum;
                K_LW: return rs == regnum;
                default: return 0;
            endcase
        endfunction

        function string convert2string();
            return $sformatf("time=%0t pc=%08h instr=%08h kind=%s rs=%0d rt=%0d rd=%0d imm=%0d addr=%08h taken=%0b",
                observed_at,pc,raw,kind.name(),rs,rt,rd,immediate,address,branch_taken);
        endfunction
    endclass

    `include "instruction_generator.svh"
    `include "mips_monitor.svh"
    `include "mips_coverage.svh"

    class mips_env extends uvm_env;
        `uvm_component_utils(mips_env)
        mips_monitor monitor;
        mips_coverage collector;

        function new(string name,uvm_component parent);
            super.new(name,parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor = mips_monitor::type_id::create("monitor",this);
            collector = mips_coverage::type_id::create("collector",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            monitor.ap.connect(collector.analysis_export);
        endfunction
    endclass

    class mips_coverage_test extends uvm_test;
        `uvm_component_utils(mips_coverage_test)
        mips_env env;
        virtual mips_fetch_if vif;

        function new(string name,uvm_component parent);
            super.new(name,parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual mips_fetch_if)::get(this,"","vif",vif))
                `uvm_fatal("NO_VIF","Missing instruction fetch interface")
            env = mips_env::type_id::create("env",this);
        endfunction
        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            wait (vif.done === 1'b1);
            `uvm_info("COMPLETE","Trickbox store observed; finishing coverage run",UVM_LOW)
            phase.drop_objection(this);
        endtask
    endclass
endpackage
