SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

# Defaults match env.cshrc; override these for a different Synopsys install.
VCS_HOME ?= /usr/local2/synopsys/vcs_2024/vcs/W-2024.09-SP2-3
VERDI_HOME ?= /usr/local2/synopsys/verdi_2024.09/verdi_2024
LM_LICENSE_FILE ?= 27020@enlicense5.eas.asu.edu
SNPSLMD_LICENSE_FILE ?= $(LM_LICENSE_FILE)
export VCS_HOME VERDI_HOME LM_LICENSE_FILE SNPSLMD_LICENSE_FILE

VCS ?= $(VCS_HOME)/bin/vcs
VERDI := $(VERDI_HOME)/bin/verdi

RTL_DIR := ../RTL
TB_DIR := ../TESTBENCH

SV_SOURCES := \
	$(RTL_DIR)/controller.sv \
	$(RTL_DIR)/datapath.sv \
	$(RTL_DIR)/flopenc.sv \
	$(RTL_DIR)/hazard_unit.sv \
	$(RTL_DIR)/mux3.sv \
	$(RTL_DIR)/pipe_ex_mem.sv \
	$(RTL_DIR)/pipe_id_ex.sv \
	$(RTL_DIR)/pipe_if_id.sv \
	$(RTL_DIR)/pipe_mem_wb.sv \
	$(RTL_DIR)/top.sv \
	$(TB_DIR)/testbench.sv

.PHONY: all compile_and_sim compile compile_verdi sim sim_verdi verdi waves_verdi clean

all: compile_and_sim

# Compile the design and testbench.
compile_and_sim:
	$(VCS) -R -full64 -sverilog -timescale=1ns/1ps $(SV_SOURCES) -debug_access+all |& tee compile_and_sim.log

compile:
	$(VCS) -full64 -sverilog -timescale=1ns/1ps $(SV_SOURCES) -debug_access+all -o simv |& tee compile.log

compile_verdi:
	$(VCS) -full64 -sverilog -timescale=1ns/1ps $(SV_SOURCES) -debug_access+all -kdb -lca -o simv |& tee compile_verdi.log

# Run the Verdi-enabled simulation from sim/; the testbench writes novas.fsdb
# and the simulation log relative to its current working directory.
sim_verdi: compile_verdi
	rm -f novas.fsdb
	./simv 2>&1 | tee sim_verdi.log

# Build and run from sim/; simulation output files are written here.
sim: compile
	./simv

verdi:
	$(VERDI) -dbdir ./simv.daidir -nologo

waves_verdi:
	$(MAKE) sim_verdi
	$(VERDI) -dbdir ./simv.daidir -ssf novas.fsdb -nologo

clean:
	rm -rf *.log *.h csrc DVEFiles simv.daidir simv ucli.key vcdplus.vpd *.syn *.pvl *.mr *.svf command.log *.txt novas.conf novas.rc verdi_config_file verdiLog novas.fsdb novas.log novas_dump.log

