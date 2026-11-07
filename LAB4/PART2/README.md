# Part 2: DPI-Based FIFO Verification

This part verifies the asynchronous FIFO using a C reference model connected
to the SystemVerilog testbench through the DPI.

## Contents

- `RTL/`: asynchronous FIFO, pointers, synchronizers, and wrapper.
- `TESTBENCH/fifo_model.c` and `fifo_model.h`: C queue model with push, pop,
  empty, full, and occupancy functions.
- `TESTBENCH/dpi_checker.sv`: DPI imports and comparisons for FIFO data and
  status flags.
- `TESTBENCH/fifo_tb.sv`: reset, fill, overflow-attempt, drain, and pointer
  wrap stimulus.
- `sim/Makefile`: VCS compile, simulation, fault-injection, and Verdi targets.

## Run the normal simulation

In a C shell, source the environment from the simulation directory and run the
normal test:

```csh
cd PART2/sim
source env.cshrc
make sim
```

The run compiles the SystemVerilog and C sources, then checks FIFO reads and
empty/full flags against the DPI reference model. A successful run ends with
`FIFO DPI test passed`; its output is saved in `sim.log`.

## Run the injected-error simulation

`make sim_error` runs the design with `+DROP_EVERY=5`. The simulation drops
every fifth eligible write, and the DPI checker should report a data mismatch.
The Makefile verifies that the injected error was detected and saves the output
in `sim_error.log`. This run is expected to report a checker failure; it is
the demonstration that the checker catches the injected fault.

To select a different drop interval manually, compile with `make compile` and
run:

```csh
./simv +DROP_EVERY=3
```

## Waveforms

The testbench dumps `novas.fsdb`. After running a simulation, open the wave in
Verdi with:

```csh
make waves_verdi
```

Useful signals include `write_en`, `w_data`, `dut.drop_write`,
`dut.write_en`, the FIFO pointers, `full`, `empty`, and `r_data`. With the
fault enabled, `dut.drop_write` marks a suppressed write request.

Use `make clean` to remove generated simulation files and logs from `sim/`.
