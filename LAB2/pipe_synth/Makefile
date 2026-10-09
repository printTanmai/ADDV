SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

.PHONY: all synth clean clean_synth

all: synth

# Run DC synthesis flow using compile_pipe.tcl
synth:
	dc_shell-t -f compile_pipe.tcl |& tee synth.log

clean_synth:
	rm -rf WORK *.syn *.pvl *.mr *.svf command.log default.svf

clean: clean_synth
	rm -f *.rep synth.log *.vh *.sdc *.db