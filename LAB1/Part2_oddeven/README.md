# Odd/Even Stream Formatter

This project accepts an 8-bit stream containing an equal number of even and
odd values. It stores the two parities in separate synchronous FIFOs and
produces an output stream that alternates between even and odd values. The
order of values within each parity stream is preserved.

## Directory Structure

```text
Part2_oddeven_submission/
|-- RTL/
|   |-- oddeven.sv
|   |-- router.sv
|   |-- sync_fifo.sv
|   `-- read_arbiter.sv
|-- TESTBENCH/
|   `-- oddeven_tb.sv
|-- sim/
|   `-- Makefile
|-- README.md
`-- REPORT_SECTIONS.md
```

## Design Overview

The design contains four RTL modules:

- `router.sv` examines `data_in[0]` and routes each accepted value to the even
  or odd FIFO.
- `sync_fifo.sv` stores values in arrival order. Each FIFO has a depth of 40.
- `read_arbiter.sv` is a two-state controller that alternates between the even
  and odd FIFOs. If the required FIFO is empty, it pauses and holds the current
  output value.
- `oddeven.sv` connects the router, two FIFOs, and read arbiter.

## Design Assumptions

- Exactly 80 input items are offered during every 100 clock cycles.
- Each set of 80 input items contains 40 even and 40 odd values.
- Read requests are generated at a rate of 8 requests per 10 clock cycles.
- The arbiter begins by expecting an even value after reset.
- A paused cycle does not produce a new output item. `data_out` holds its
  previous value instead of being forced to zero.

## Testbench

The testbench is procedural SystemVerilog and does not use classes or UVM. It
asserts `write_en` for eight cycles and deasserts it for two cycles in every
ten-cycle group. The same pattern is used for `read_en`. The testbench verifies
the rates by counting exactly 80 write requests and 80 read requests during
each 100-cycle input window.

Two cases are tested:

1. Forty odd values followed by forty even values. This is the depth-setting
   case and fills the odd FIFO to 40 entries.
2. Alternating even and odd values. This checks balanced operation without a
   long parity burst.

Separate software scoreboards model the even and odd FIFOs. The testbench
checks data values, alternating parity, FIFO occupancy flags, accepted writes,
accepted reads, and complete draining of both FIFOs.

## FIFO Depth

Each 80-item window contains 40 values of each parity. In the worst ordering,
all 40 values of a parity that is not currently expected can arrive before the
other parity appears. None of those values can be read during that interval,
so the required FIFO depth is 40. Both FIFOs use the same depth because either
parity can become the blocked stream.

## Running the Simulation

The course environment must be loaded before running VCS. From the project
directory:

```bash
source env.cshrc
cd sim
```

Compile and run:

```bash
make clean
make compile_and_sim
```

The expected final console message is:

```text
ODDEVEN TESTBENCH PASSED
```

## Opening the Waveforms

Compile with the Verdi database options, run the executable, and open the FSDB
file:

```bash
make clean
make compile_verdi
./simv
make waves_verdi
```

Useful waveform signals are:

```text
clk
reset
data_in
write_en
data_out
read_en
dut.even_wen
dut.odd_wen
dut.even_full
dut.even_empty
dut.odd_full
dut.odd_empty
dut.even_ren
dut.odd_ren
dut.arbiter_inst.expect_even
```

## Bug Fixed During Verification

The original FIFO registered its read output on the same edge that the arbiter
sampled it. As a result, the arbiter received the previous FIFO value. The FIFO
also calculated its flags using one next pointer and one old pointer, causing
one-cycle occupancy errors. The corrected FIFO exposes the current head value
combinationally and calculates both flags using the next read and write
pointers. More detail is provided in `REPORT_SECTIONS.md`.

## Submission Notes

Submit the RTL, testbench, Makefile, README, report sections, and the annotated
waveform images. Do not submit simulator-generated files or directories such
as:

```text
csrc/
simv
simv.daidir/
novas.fsdb
ucli.key
*.log
verdiLog/
```

