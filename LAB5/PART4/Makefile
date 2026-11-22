SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c

VCS ?= $(if $(strip $(VCS_HOME)),$(VCS_HOME)/bin/vcs,vcs)
VERDI ?= $(if $(strip $(VERDI_HOME)),$(VERDI_HOME)/bin/verdi,verdi)
URG ?= $(if $(strip $(VCS_HOME)),$(VCS_HOME)/bin/urg,urg)

TOP := MIPS_Testbench
SEED ?= 1
SEEDS ?= 1
MODE ?= initial
CASE ?= 0
TIMEOUT ?= 600
LOG_TRANSACTIONS ?= 0
WAVE_RUN ?= initial
CASES ?= $(shell seq 0 68)

# Part 4: instrument code coverage at compile time and collect it at runtime.
# Keep all DUT RTL in scope; omit testbench and UVM library implementation.
COV_METRICS := line+tgl+cond+fsm
COV_HIER := cm_hier.cfg

SV_SOURCES := \
	TESTBENCH/mips_fetch_if.sv \
	TESTBENCH/mips_part3_pkg.sv \
	RTL/flopenc.sv \
	RTL/mux3.sv \
	RTL/pipe_if_id.sv \
	RTL/pipe_id_ex.sv \
	RTL/pipe_ex_mem.sv \
	RTL/pipe_mem_wb.sv \
	RTL/controller.sv \
	RTL/hazard_unit.sv \
	RTL/datapath.sv \
	RTL/top.sv \
	TESTBENCH/testbench.sv

SV_HEADERS := $(wildcard TESTBENCH/*.svh)

.PHONY: all help dirs compile initial sim closure merge coverage_initial coverage_final report_initial report_final waves clean

# Start with one run so its initial coverage can be captured before closure.
all: initial

help:
	@echo 'make initial SEED=1                 First code-coverage run and database'
	@echo 'make coverage_initial               Open initial CODE coverage in Verdi'
	@echo 'make closure                        Run closure templates 0 through 68'
	@echo 'make closure SEEDS="1 2 3"          Repeat closure templates with multiple seeds'
	@echo 'make merge                          Merge initial and closure CODE coverage'
	@echo 'make coverage_final                 Open merged CODE coverage in Verdi'
	@echo 'make report_initial                 Generate initial code-coverage HTML report'
	@echo 'make report_final                   Generate merged code-coverage HTML report'
	@echo 'make sim MODE=closure CASE=25 SEED=2 Run one selected template'
	@echo 'make waves WAVE_RUN=initial          Open an existing waveform database'
	@echo 'make clean                          Remove generated products only'

dirs:
	@mkdir -p build logs coverage reports

build/simv: $(SV_SOURCES) $(SV_HEADERS) $(COV_HIER) Makefile | dirs
	$(VCS) -full64 -sverilog -timescale=1ns/1ps \
		-ntb_opts uvm -top $(TOP) +incdir+TESTBENCH \
		-debug_access+all -kdb -lca +define+FSDB \
		-cm $(COV_METRICS) -cm_hier $(COV_HIER) \
		-cm_dir build/part4_compile.vdb \
		$(SV_SOURCES) -Mdir=build/csrc -o build/simv \
		2>&1 | tee logs/compile.log

compile: build/simv

# UVM can finish with a zero shell exit code after reporting a fatal error.
# Check both individual report lines and the final UVM report counters.
define check_log
awk '/^UVM_(ERROR|FATAL)[[:space:]]+@/ {bad=1} /^UVM_(ERROR|FATAL)[[:space:]]*:[[:space:]]*[1-9]/ {bad=1} END {exit bad}' $(1) || { echo 'UVM ERROR/FATAL found; inspect $(1).'; exit 1; }
endef

initial: build/simv | dirs
	./build/simv +MODE=initial +CASE=0 +ntb_random_seed=$(SEED) \
		+PROGRAM_FILE=build/initial.hex +FSDB=build/initial.fsdb \
		+LOG_TRANSACTIONS=$(LOG_TRANSACTIONS) +TIMEOUT=$(TIMEOUT) \
		-cm $(COV_METRICS) -cm_dir coverage/initial.vdb -cm_name initial_s$(SEED) \
		2>&1 | tee logs/initial.log
	@$(call check_log,logs/initial.log)

sim: build/simv | dirs
	./build/simv +MODE=$(MODE) +CASE=$(CASE) +ntb_random_seed=$(SEED) \
		+PROGRAM_FILE=build/selected.hex +FSDB=build/selected.fsdb \
		+LOG_TRANSACTIONS=$(LOG_TRANSACTIONS) +TIMEOUT=$(TIMEOUT) \
		-cm $(COV_METRICS) -cm_dir coverage/selected.vdb -cm_name selected_s$(SEED) \
		2>&1 | tee logs/selected.log
	@$(call check_log,logs/selected.log)

closure: build/simv | dirs
	@for seed_value in $(SEEDS); do \
		for case_value in $(CASES); do \
			run_name="closure_c$${case_value}_s$${seed_value}"; \
			echo "Running $${run_name}"; \
			./build/simv +MODE=closure +CASE=$${case_value} \
				+ntb_random_seed=$${seed_value} \
				+PROGRAM_FILE=build/$${run_name}.hex \
				+FSDB=build/$${run_name}.fsdb \
				+LOG_TRANSACTIONS=$(LOG_TRANSACTIONS) +TIMEOUT=$(TIMEOUT) \
				-cm $(COV_METRICS) -cm_dir coverage/$${run_name}.vdb -cm_name $${run_name} \
				2>&1 | tee logs/$${run_name}.log; \
			awk '/^UVM_(ERROR|FATAL)[[:space:]]+@/ {bad=1} /^UVM_(ERROR|FATAL)[[:space:]]*:[[:space:]]*[1-9]/ {bad=1} END {exit bad}' logs/$${run_name}.log \
				|| { echo "UVM ERROR/FATAL found in logs/$${run_name}.log"; exit 1; }; \
		done; \
	done

merge: | dirs
	@shopt -s nullglob; \
	databases=(build/part4_compile.vdb coverage/initial.vdb coverage/closure_*.vdb); \
	if [[ ! -d build/part4_compile.vdb ]]; then \
		echo 'Missing compile-time coverage model: build/part4_compile.vdb'; exit 1; \
	fi; \
	if [[ ! -d coverage/initial.vdb ]]; then \
		echo 'Run make initial before merging.'; exit 1; \
	fi; \
	if (( $${#databases[@]} < 3 )); then \
		echo 'Run make closure before merging.'; exit 1; \
	fi; \
	$(URG) -dir "$${databases[@]}" -dbname coverage/merged.vdb \
		-metric $(COV_METRICS) -report reports/merged 2>&1 | tee logs/merge.log

coverage_initial: report_initial
	$(VERDI) -cov -covdir coverage/initial_complete.vdb

coverage_final:
	@test -d coverage/merged.vdb || { echo 'Run make merge first.'; exit 1; }
	$(VERDI) -cov -covdir coverage/merged.vdb

report_initial: | dirs
	@test -d build/part4_compile.vdb || { echo 'Missing compile-time coverage model.'; exit 1; }
	@test -d coverage/initial.vdb || { echo 'Run make initial first.'; exit 1; }
	$(URG) -dir build/part4_compile.vdb coverage/initial.vdb \
		-dbname coverage/initial_complete.vdb -metric $(COV_METRICS) \
		-report reports/initial 2>&1 | tee logs/report_initial.log

report_final: | dirs
	@test -d coverage/merged.vdb || { echo 'Run make merge first.'; exit 1; }
	$(URG) -dir coverage/merged.vdb -metric $(COV_METRICS) \
		-report reports/final 2>&1 | tee logs/report_final.log

waves:
	@test -f build/$(WAVE_RUN).fsdb || { echo 'No waveform for WAVE_RUN=$(WAVE_RUN); run that simulation first.'; exit 1; }
	$(VERDI) -dbdir build/simv.daidir -ssf build/$(WAVE_RUN).fsdb -nologo

clean:
	rm -rf build logs coverage reports
	rm -rf csrc simv simv.daidir simv.vdb DVEFiles verdiLog
	rm -f ucli.key vc_hdrs.h novas.conf novas.rc

