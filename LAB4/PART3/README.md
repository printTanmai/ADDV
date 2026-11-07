# Part 3: SystemVerilog Scoreboard Verification

This part verifies the asynchronous FIFO with a SystemVerilog transaction,
monitor, mailbox, and queue-based scoreboard.

## Contents

- `RTL/`: asynchronous FIFO implementation.
- `TESTBENCH/fifo_if.sv`: separate write- and read-side interfaces.
- `TESTBENCH/fifo_transaction.sv`: operation, data, acceptance, status, and
  timestamp fields for monitored transactions.
- `TESTBENCH/fifo_monitor.sv`: independent write/read clock samplers and the
  `FIFO_LOG` plusarg-controlled logger.
- `TESTBENCH/fifo_scoreboard.sv`: queue-based reference model and read-data
  checks.
- `sim/`: VCS simulation and Verdi build targets.

## Run the simulation

From a C shell, source the environment and run the test from `sim/`:

```csh
cd PART3/sim
source env.cshrc
make sim
```

The normal simulation checks output data against the SV queue and ends with
`FIFO SystemVerilog scoreboard test completed`. `make sim` saves compiler and
simulation output in `compile.log` and `sim.log`.

The monitor logger is controlled at runtime with `FIFO_LOG`: `0` disables
monitor messages, `1` prints brief operation and timestamp messages, and `2`
prints all transaction fields. For example:

```csh
./simv +FIFO_LOG=1
./simv +FIFO_LOG=2
```

Use `make compile_and_sim` to compile and run in one step, `make compile_verdi`
to create a Verdi database, and `make verdi` to open it. To compile, simulate,
and open the FSDB waveform in Verdi, run:

```csh
make waves_verdi
```

Pass runtime options through `RUN_ARGS`, for example:

```csh
make waves_verdi RUN_ARGS=+FIFO_LOG=2
```

The generated waveform is `sim/fifo.fsdb`. Run `make clean` to remove generated
simulation and Verdi files while preserving source files.
