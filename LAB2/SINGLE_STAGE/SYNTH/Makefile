SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

.PHONY: all synth check clean_synth clean

all: synth check

# This runs synthesis with Design Compiler
synth:
	dc_shell-t -f compile.tcl |& tee synth.log

# This checks for synthesis errors and unresolved modules
check:
	@if grep -nE "^Error:|Unable to resolve reference|has '[1-9][0-9]*' unresolved references" synth.log; then \
		echo "Synthesis contains errors or unresolved references."; \
		exit 1; \
	else \
		echo "Synthesis completed without errors or unresolved references."; \
	fi

clean_synth:
	rm -rf *.syn *.pvl *.mr *.svf command.log WORK alib-* \
		timing.rep cell.rep power.rep area.rep

clean: clean_synth
	rm -f synth.log