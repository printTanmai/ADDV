# Part 1: Asynchronous FIFO

This directory contains the asynchronous FIFO RTL, its SystemVerilog testbench,
and the VCS and Design Compiler flows. Run commands from the relevant `sim/` or
`synth/` directory so that build products stay with that flow.

## Project layout

```text
Part1_Async_FIFO/
├── RTL/         FIFO, pointer, synchronizer, Gray-code, and wrapper modules
├── TESTBENCH/   FIFO interface and self-checking testbench
├── sim/         VCS simulation Makefile
├── synth/       Design Compiler Tcl and Makefile
└── env.cshrc    Synopsys tools, license, and PDK environment
```

## Requirements

- Synopsys VCS for simulation
- Synopsys Design Compiler and the OSU FreePDK45 library for synthesis
- A supported C shell (`csh` or `tcsh`) to source `env.cshrc`
- Access to the Synopsys license server configured in `env.cshrc`

The environment file contains site-specific installation and license paths. If
you use a different machine, update those paths to match its tool installation.

## Set up the environment

From a terminal, enter the Part 1 directory in C shell and source the environment
file. Keep this shell open while running VCS or Design Compiler:

```csh
cd LAB1/Part1_Async_FIFO
source env.cshrc
```

The script sets `VCS_HOME`, `VERDI_HOME`, the Synopsys license variables,
`PDK_DIR`, and the tool paths.

## Run the simulation

```csh
cd sim
make compile_and_sim
```

`compile_and_sim` compiles the interface, RTL, and testbench with VCS, then runs
the simulation. The self-checking testbench reports its checks and errors in the
terminal. To compile without running, use `make compile`; then run the resulting
binary with `./simv`. The `make sim` target compiles and runs it:

```csh
make compile
./simv
```

Optional targets are `make compile_verdi` to build a Verdi database,
`make verdi` to open that database, and `make waves_verdi` to open it with a
waveform file. `make clean` removes generated simulation products from `sim/`.

## Run synthesis

In the same environment-enabled shell:

```csh
cd ../synth
make synth
```

The Makefile runs `dc_shell-t -f compile_dc.tcl`. The Tcl resolves RTL and
testbench paths relative to the Part 1 directory, so it does not depend on the
terminal's starting directory. It elaborates `fifo_wrapper`, maps to the
FreePDK45 `gscl45nm.db` library, applies timing constraints, and writes a mapped
Verilog netlist and SDC beside the Tcl script.

The synthesis constraints in `compile_dc.tcl` are:

- Separate 1.5 GHz `w_clk` and `r_clk` clocks (0.6667 ns period each).
- The two clocks are declared asynchronous with `set_clock_groups`, so DC does
  not attempt to close timing on paths crossing between the clock domains.
- False paths from the active-low reset ports `w_rst_b` and `r_rst_b`.
- 0.1 ns input delays on `write_en`/`w_data` relative to `w_clk` and `read_en`
  relative to `r_clk`.
- 0.1 ns output delays on `full`/`almost_full` relative to `w_clk` and on
  `empty`/`almost_empty`/`r_data` relative to `r_clk`.
- `INVX1` is used as the modeled driver for data/control inputs. No explicit
  external output loads are specified in this synthesis estimate.

DC generates `fifo_wrapper.v`, `fifo_wrapper.sdc`, `synth.log`, and timing,
constraint, capacitance, area, power, clock, cell, and port reports. These files
are tool outputs and are intentionally not tracked in Git; regenerate them with
`make synth`. `make clean_synth` removes the DC work database and intermediate
files. `make clean` also removes the generated reports, netlist, SDC, and log.

### Interpreting synthesis reports

Timing, area, and power are pre-layout estimates using the selected library and
Design Compiler's synthesis models. The power report uses low-effort estimated
switching activity; annotate realistic activity for a more representative power
estimate. Total cell area is available in `area.rep`; wire/interconnect area is
not available from this flow.

The supplied FreePDK45 library has zero `max_capacitance` values on some output
pins. Design Compiler treats those as zero-load limits, so the capacitance
report can show violations even when the actual net capacitance is very small.
The design-rule-only compile pass is enabled, but those library limits need a
corrected, characterized library value to be cleared legitimately. Do not hide
them by relaxing constraints without validating the library data.
