SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

VCS ?= $(VCS_HOME)/bin/vcs
VERDI ?= $(VERDI_HOME)/bin/verdi
RTL_DIR := ../RTL
TB_DIR := ../TESTBENCH

SV_SOURCES := \
	$(TB_DIR)/fifo_if.sv \
	$(TB_DIR)/fifo_transaction.sv \
	$(TB_DIR)/fifo_monitor.sv \
	$(TB_DIR)/fifo_scoreboard.sv \
	$(RTL_DIR)/bin2gray.sv \
	$(RTL_DIR)/gray2bin.sv \
	$(RTL_DIR)/synchronizer.sv \
	$(RTL_DIR)/fifo_mem.sv \
	$(RTL_DIR)/write_ptr.sv \
	$(RTL_DIR)/read_ptr.sv \
	$(RTL_DIR)/async_fifo.sv \
	$(TB_DIR)/fifo_tb.sv

.PHONY: all compile_and_sim compile compile_verdi sim sim_verdi verdi waves_verdi clean

all: compile_and_sim

compile_and_sim:
	$(VCS) -R -full64 -sverilog -timescale=1ns/1ps $(SV_SOURCES) -debug_access+all |& tee compile_and_sim.log
	! grep -Eq '(^Error:|^Fatal:|\*Verdi\* ERROR:|FAILED)' compile_and_sim.log

compile:
	$(VCS) -full64 -sverilog -timescale=1ns/1ps $(SV_SOURCES) -debug_access+all -o simv |& tee compile.log

compile_verdi:
	$(VCS) -full64 -sverilog -timescale=1ns/1ps $(SV_SOURCES) -debug_access+all -kdb -lca -o simv |& tee compile_verdi.log

sim: compile
	./simv 2>&1 | tee sim.log
	! grep -Eq '(^Error:|^Fatal:|\*Verdi\* ERROR:|FAILED)' sim.log

sim_verdi: compile_verdi
	./simv $(RUN_ARGS) 2>&1 | tee sim_verdi.log
	! grep -Eq '(^Error:|^Fatal:|\*Verdi\* ERROR:|FAILED)' sim_verdi.log

verdi: compile_verdi
	$(VERDI) -dbdir ./simv.daidir -nologo

waves_verdi: sim_verdi
	$(VERDI) -dbdir ./simv.daidir -ssf fifo.fsdb -nologo

clean:
	rm -rf csrc DVEFiles dveLog verdiLog simv.daidir *.daidir simv simv.vdb \
		*.vdb coverage AN.DB urgReport ucli.key vc_hdrs.h *.vpd *.vcd *.fsdb \
		*.log *.key novas.rc novas.conf
