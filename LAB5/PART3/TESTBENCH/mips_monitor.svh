class mips_monitor extends uvm_monitor;
    `uvm_component_utils(mips_monitor)

    virtual mips_fetch_if vif;
    uvm_analysis_port #(instruction) ap;
    bit valid_D, valid_E;
    logic [31:0] pc_D, word_D, pc_E, word_E;
    bit marker_seen;
    int unsigned observed_count;
    int log_transactions;

    function new(string name,uvm_component parent);
        super.new(name,parent);
        ap = new("ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual mips_fetch_if)::get(this,"","vif",vif))
            `uvm_fatal("NO_VIF","Monitor has no instruction fetch interface")
    endfunction

    task run_phase(uvm_phase phase);
        instruction tr;
        int unused;
        log_transactions=0;
        unused=$value$plusargs("LOG_TRANSACTIONS=%d",log_transactions);
        valid_D=0; valid_E=0; marker_seen=0; observed_count=0;
        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.reset) begin
                valid_D=0; valid_E=0; marker_seen=0;
                continue;
            end

            // Use the OLD EX metadata with the OLD EX observation signals.
            // This is an execution-qualified fetch transaction, not WB
            // retirement. Publishing is delayed only until speculation ends.
            if (valid_E && !marker_seen) begin
                if ($isunknown(word_E))
                    `uvm_fatal("FETCH_X","Unknown instruction reached execute")
                tr = instruction::type_id::create("observed_instruction");
                tr.decode(word_E);
                tr.pc = pc_E;
                tr.observed_at = $time;
                tr.address = vif.monitor_cb.address_E;
                tr.branch_taken = vif.monitor_cb.pcsrc_E;

                // Exclude the termination protocol from functional ISA bins.
                if (tr.kind == K_SW && tr.rs==0 && tr.rt==0 &&
                    tr.immediate==252) begin
                    marker_seen=1;
                end else begin
                    if (tr.kind == K_OTHER)
                        `uvm_fatal("BAD_INSTR",tr.convert2string())
                    if (tr.kind == K_BEQ) begin
                        if ($isunknown({vif.monitor_cb.branch_E,
                                        vif.monitor_cb.pcsrc_E,
                                        vif.monitor_cb.operand_a_E,
                                        vif.monitor_cb.operand_b_E}))
                            `uvm_fatal("BRANCH_X","Unknown branch decision or operands")
                        if (!vif.monitor_cb.branch_E)
                            `uvm_fatal("ALIGNMENT","Fetch shadow and EX branch disagree")
                        if (tr.branch_taken !=
                            (vif.monitor_cb.operand_a_E == vif.monitor_cb.operand_b_E))
                            `uvm_fatal("BRANCH","BEQ result disagrees with compared operands")
                    end
                    if (tr.kind inside {K_LW,K_SW}) begin
                        if ($isunknown(vif.monitor_cb.address_E))
                            `uvm_fatal("ADDRESS_X","Unknown effective memory address")
                        if (!(tr.address inside {0,4,8,12}))
                            `uvm_fatal("ADDRESS","Effective address outside the four planned locations")
                    end
                    observed_count++;
                    if (log_transactions != 0)
                        `uvm_info("INSTRUCTION",tr.convert2string(),UVM_LOW)
                    // write() is a function: sampling is immediate and each
                    // object is freshly allocated, so history stays immutable.
                    ap.write(tr);
                end
            end

            // Shadow only the IF/ID and ID/EX control rules. No operand
            // values or architectural execution results are predicted here.
            valid_E = valid_D && !vif.monitor_cb.flushE;
            pc_E=pc_D; word_E=word_D;
            if (vif.monitor_cb.flushD) begin
                valid_D=0;
            end else if (!vif.monitor_cb.stallD) begin
                valid_D = vif.monitor_cb.pc < 4*vif.monitor_cb.program_words;
                pc_D=vif.monitor_cb.pc;
                word_D=vif.monitor_cb.instr;
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("MONITOR_SUMMARY",$sformatf("Observed %0d execution-qualified instructions (including setup)",observed_count),UVM_LOW)
    endfunction
endclass
