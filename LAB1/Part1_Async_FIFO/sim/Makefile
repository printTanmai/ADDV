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
	$(TB_DIR)/async_fifo_tb.sv

.PHONY: all compile_and_sim compile compile_verdi sim clean

all: compile_and_sim

compile_and_sim:
	$(VCS) -R -full64 -sverilog -timescale=1ns/1ps $(SV_SOURCES) -debug_access+all |& tee compile_and_sim.log

compile:
	$(VCS) -full64 -sverilog $(SV_SOURCES) -debug_access+all -o simv |& tee compile.log

compile_verdi:
	$(VCS) -full64 -sverilog $(SV_SOURCES) -debug_access+all -kdb -lca -o simv |& tee compile_verdi.log

sim: compile
	./simv

clean:
	rm -rf csrc DVEFiles simv.daidir simv ucli.key vcdplus.vpd *.log *.key
