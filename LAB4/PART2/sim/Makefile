SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

VCS ?= $(VCS_HOME)/bin/vcs
RTL_DIR := ../RTL
TB_DIR := ../TESTBENCH

SV_SOURCES := \
	$(TB_DIR)/fifo_if.sv \
	$(RTL_DIR)/bin2gray.sv \
	$(RTL_DIR)/gray2bin.sv \
	$(RTL_DIR)/synchronizer.sv \
	$(RTL_DIR)/fifo_mem.sv \
	$(RTL_DIR)/write_ptr.sv \
	$(RTL_DIR)/read_ptr.sv \
	$(RTL_DIR)/async_fifo.sv \
	$(TB_DIR)/dpi_checker.sv \
	$(TB_DIR)/fifo_tb.sv

C_SOURCES := $(TB_DIR)/fifo_model.c
C_FLAGS := -CFLAGS "-I$(TB_DIR)"
SIM_DEFINES := +define+FIFO_SIMULATION

.PHONY: all compile_and_sim compile compile_verdi sim sim_error verdi waves_verdi clean

all: compile_and_sim

compile_and_sim:
	$(VCS) -R -full64 -sverilog -timescale=1ns/1ps $(SIM_DEFINES) $(SV_SOURCES) $(C_SOURCES) $(C_FLAGS) -debug_access+all |& tee compile_and_sim.log
	! grep -Eq '(^Error:|^Fatal:)' compile_and_sim.log

compile:
	$(VCS) -full64 -sverilog -timescale=1ns/1ps $(SIM_DEFINES) $(SV_SOURCES) $(C_SOURCES) $(C_FLAGS) -debug_access+all -kdb -o simv |& tee compile.log

compile_verdi:
	$(VCS) -full64 -sverilog -timescale=1ns/1ps $(SIM_DEFINES) $(SV_SOURCES) $(C_SOURCES) $(C_FLAGS) -debug_access+all -kdb -lca -o simv |& tee compile_verdi.log

sim: compile
	./simv 2>&1 | tee sim.log
	! grep -Eq '(^Error:|^Fatal:)' sim.log

sim_error: compile
	@set +e; ./simv +DROP_EVERY=5 2>&1 | tee sim_error.log; sim_status=$$?; set -e; \
		grep -Fq 'RTL fault injection enabled' sim_error.log && \
		grep -Fq 'FIFO data mismatch:' sim_error.log || { echo 'Expected injected FIFO error was not detected'; exit 1; }; \
		echo "Expected injected FIFO error detected (simulator exit=$$sim_status)"

verdi: compile_verdi
	$(VERDI) -dbdir ./simv.daidir -nologo

waves_verdi:
	$(VERDI_HOME)/bin/verdi -dbdir ./simv.daidir -ssf novas.fsdb -nologo	

clean:
	rm -rf csrc DVEFiles simv.daidir simv ucli.key vcdplus.vpd novas.fsdb *.log *.key
