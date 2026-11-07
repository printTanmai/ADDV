SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

VCS ?= $(VCS_HOME)/bin/vcs
VERDI ?= $(VERDI_HOME)/bin/verdi
RTL_DIR := ../RTL
TB_DIR := ../TESTBENCH

SV_SOURCES := \
	$(RTL_DIR)/sync_fifo.sv \
	$(RTL_DIR)/read_arbiter.sv \
	$(RTL_DIR)/router.sv \
	$(RTL_DIR)/oddeven.sv \
	$(TB_DIR)/oddeven_sva_if.sv \
	$(TB_DIR)/oddeven_tb.sv
SIM_DEFINES := +define+ASSERTION_SIM

.PHONY: all compile compile_and_sim sim sim_error compile_verdi waves_verdi waves_error clean

all: compile_and_sim

compile:
	$(VCS) -full64 -sverilog -timescale=1ns/1ps -top oddeven_tb $(SIM_DEFINES) $(SV_SOURCES) -debug_access+all -kdb -lca -o simv |& tee compile.log

compile_and_sim: compile
	./simv 2>&1 | tee simulation.log
	! grep -Eq '(^Error:|^Fatal:|FAILED)' simulation.log

sim: compile_and_sim

# Fault injection in the read arbiter suppresses one valid read and should fail an assertion.
sim_error: compile
	@set +e; ./simv +inject_error 2>&1 | tee sim_error.log; sim_status=$$?; set -e; \
		grep -Fq '[READ_ARBITER] inject_error enabled: even reads are suppressed' sim_error.log || \
		{ echo 'Expected fault injection enable message was not detected'; exit 1; }; \
		grep -Fq 'arbiter did not assert exactly one FIFO read enable' sim_error.log || \
		{ echo 'Expected arbiter assertion failure was not detected'; exit 1; }; \
		echo "Expected injected assertion failure detected (simulator exit=$$sim_status)"

compile_verdi: compile

waves_verdi: compile
	rm -f novas.fsdb
	./simv 2>&1 | tee waves_run.log
	! grep -Eq '(^Error:|^Fatal:|FAILED)' waves_run.log
	$(VERDI) -dbdir ./simv.daidir -ssf novas.fsdb -nologo

waves_error: compile
	rm -f novas.fsdb
	@set +e; ./simv +inject_error 2>&1 | tee waves_error.log; sim_status=$$?; set -e; \
		grep -Fq '[READ_ARBITER] inject_error enabled: even reads are suppressed' waves_error.log || \
		{ echo 'Expected fault injection enable message was not detected'; exit 1; }; \
		grep -Fq 'arbiter did not assert exactly one FIFO read enable' waves_error.log || \
		{ echo 'Expected arbiter assertion failure was not detected'; exit 1; }; \
		echo "Expected injected assertion failure detected (simulator exit=$$sim_status)"
	$(VERDI) -dbdir ./simv.daidir -ssf novas.fsdb -nologo

clean:
	rm -rf csrc DVEFiles dveLog verdiLog simv.daidir *.daidir simv simv.vdb \
		*.vdb coverage AN.DB urgReport ucli.key vc_hdrs.h *.vpd *.vcd *.fsdb \
		*.log *.key novas.rc novas.conf
