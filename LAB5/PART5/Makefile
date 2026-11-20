SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c

VCS := $(if $(strip $(VCS_HOME)),$(VCS_HOME)/bin/vcs,vcs)
VERDI := $(if $(strip $(VERDI_HOME)),$(VERDI_HOME)/bin/verdi,verdi)
PYTHON ?= python3

TOP := MIPS_Testbench
PROGRAMS := alu memory branch
CASE ?= branch
TIMEOUT ?= 300

RTL_SOURCES := \
	RTL/flopenc.sv \
	RTL/mux3.sv \
	RTL/pipe_if_id.sv \
	RTL/pipe_id_ex.sv \
	RTL/pipe_ex_mem.sv \
	RTL/pipe_mem_wb.sv \
	RTL/controller.sv \
	RTL/hazard_unit.sv \
	RTL/datapath.sv \
	RTL/top.sv

TB_SOURCE := TESTBENCH/testbench.sv
SV_SOURCES := $(RTL_SOURCES) $(TB_SOURCE)

ISS_TARGETS := $(addprefix iss_,$(PROGRAMS))
RTL_TARGETS := $(addprefix rtl_,$(PROGRAMS))
COMPARE_TARGETS := $(addprefix compare_,$(PROGRAMS))
RUN_TARGETS := $(addprefix run_,$(PROGRAMS))

.PHONY: all help dirs compile regress sim waves clean \
	$(ISS_TARGETS) $(RTL_TARGETS) $(COMPARE_TARGETS) $(RUN_TARGETS)

all: regress

help:
	@echo "make compile              Compile the pipelined MIPS RTL"
	@echo "make run_alu              Run and compare the ALU program"
	@echo "make run_memory           Run and compare the memory program"
	@echo "make run_branch           Run and compare the branch program"
	@echo "make regress              Run and compare all three programs"
	@echo "make waves CASE=branch    Open one test in Verdi"
	@echo "make clean                Remove generated files"

dirs:
	@mkdir -p build logs traces

build/simv: $(SV_SOURCES) | dirs
	$(VCS) -full64 -sverilog -timescale=1ns/1ps \
		-top $(TOP) \
		-debug_access+all -kdb -lca +define+FSDB \
		$(SV_SOURCES) \
		-Mdir=build/csrc -o build/simv \
		2>&1 | tee logs/vcs_compile.log

compile: build/simv

$(ISS_TARGETS): iss_%: programs/%.asm scripts/run_iss.py ISS/Mips_Simulator.py | dirs
	$(PYTHON) scripts/run_iss.py \
		--iss ISS/Mips_Simulator.py \
		--asm programs/$*.asm \
		--binary build/$*.bin \
		--hex build/$*.hex \
		--trace traces/$*_iss.trace \
		--max-instructions 200 \
		2>&1 | tee logs/iss_$*.log

# The ISS target also creates build/<case>.hex, so it must run before RTL.
$(RTL_TARGETS): rtl_%: build/simv iss_% | dirs
	./build/simv \
		+MEMFILE=$(abspath build/$*.hex) \
		+TRACE=$(abspath traces/$*_rtl.trace) \
		+FSDB=$(abspath build/$*.fsdb) \
		+TIMEOUT=$(TIMEOUT) \
		2>&1 | tee logs/rtl_$*.log

$(COMPARE_TARGETS): compare_%: rtl_% scripts/compare_traces.py | dirs
	$(PYTHON) scripts/compare_traces.py \
		traces/$*_iss.trace traces/$*_rtl.trace \
		2>&1 | tee logs/compare_$*.log

$(RUN_TARGETS): run_%: compare_%

regress: $(RUN_TARGETS)
	@echo "All three ISS-to-RTL comparisons passed."

sim: run_$(CASE)

waves: rtl_$(CASE)
	$(VERDI) -dbdir build/simv.daidir \
		-ssf build/$(CASE).fsdb -nologo

clean:
	rm -rf build logs
	rm -f traces/*_iss.trace traces/*_rtl.trace
	rm -rf csrc simv simv.daidir DVEFiles DVEfiles ucli.key vc_hdrs.h
	rm -rf novas.conf novas.rc verdiLog
	rm -rf ISS/__pycache__ scripts/__pycache__
