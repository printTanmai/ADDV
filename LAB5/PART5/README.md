# Lab 5 Part 5: MIPS ISS and RTL Trace Comparison

## Objective

This setup verifies the five-stage pipelined MIPS processor by running the
same program independently on an existing instruction set simulator (ISS) and
on the SystemVerilog RTL. Both runs produce an architectural retirement trace.
A Python script compares the traces line by line and reports the first mismatch.

The ISS is not called from SystemVerilog. The ISS run, RTL run, and comparison
are separate steps connected by the Makefile.

## Existing ISS

The supplied `ISS/Mips_Simulator.py` from the recommended Python
MIPS-Simulator repository is used because it includes a MIPS assembly
translator, architectural register and memory state, and execution support for
the instructions required by this lab. Its original `LICENSE` is preserved.

The actual filename is `Mips_Simulator.py`. Linux filenames are case-sensitive,
even though the vendor README shows a different capitalization.

The adapter in `scripts/run_iss.py` imports and reuses the existing ISS. It adds
only the compatibility and instrumentation needed for comparison with the RTL:

- standard `base register + sign-extended offset` addressing for `LW` and `SW`;
- 32-bit result wrapping and a hardwired `$zero` register;
- normalization of the ISS text address to the RTL PC base of zero;
- conversion of the ISS binary output into hexadecimal for RTL `$readmemh`;
- generation of a deterministic architectural retirement trace.

These changes are an adapter around the existing ISS, not a newly designed ISS.

## Directory Structure

```text
PART5/
├── ISS/                 Existing MIPS ISS, README, and license
├── RTL/                 Pipelined MIPS RTL
├── TESTBENCH/           Trace-generating SystemVerilog testbench
├── programs/            Three assembly test programs
├── scripts/             ISS adapter and trace comparator
├── traces/              Generated ISS and RTL traces
├── Makefile             Automated compile, run, and comparison flow
├── .gitignore           Excludes generated tool files
└── env.cshrc            ASU VCS and Verdi environment
```

## Verification Programs

Each program contains at least ten static instructions and finishes with
`sw $zero, 252($zero)`. The store to address `0xFC` is the common completion
marker for both the ISS and RTL.

| Program | Main scenarios |
| --- | --- |
| `alu.asm` | Dependent `ADD` and `AND` instructions exercising EX/MEM and MEM/WB forwarding |
| `memory.asm` | `SW`, `LW`, and immediate consumers exercising load-use stalls |
| `branch.asm` | Taken and not-taken `BEQ` instructions exercising wrong-path flushing |

`ADDI` is used only to create deterministic input values. It is already
supported by both the supplied RTL and ISS.

## RTL and Testbench Updates

The processor carries verification metadata alongside every instruction:

```text
valid_D, instr_D, pc_D
valid_E, instr_E, pc_E
valid_M, instr_M, pc_M
valid_W, instr_W, pc_W
```

The store enable and store data are also propagated into writeback. This lets
the testbench create one trace line per valid retired instruction. Logging at
writeback is important because fetch-stage instructions may be repeated during
stalls or discarded after a taken branch.

The testbench accepts these plusargs:

| Plusarg | Purpose |
| --- | --- |
| `+MEMFILE=<file>` | Select the hexadecimal instruction-memory file |
| `+TRACE=<file>` | Select the RTL retirement-trace file |
| `+FSDB=<file>` | Select the waveform database filename |
| `+TIMEOUT=<cycles>` | Set the simulation timeout |

## Trace Format

Both models emit the same format:

```text
PC=00000000 INSTR=20080005 REGWRITE=1 RD=8 REGDATA=00000005 MEMWRITE=0 MEMADDR=00000000 MEMDATA=00000000
```

The trace contains architectural information only. Cycle numbers are omitted
because the ISS is functional rather than cycle-accurate. Pipeline stalls may
change timing without changing architectural correctness.

## Running on Apporto

Run all commands from `LAB5/PART5`:

```bash
cd ~/ADDV/ADDV/LAB5/PART5
source env.cshrc
```

Compile the RTL:

```bash
make compile
```

Run one program and compare its traces:

```bash
make run_alu
make run_memory
make run_branch
```

Run the complete regression:

```bash
make clean
make regress
```

Expected final messages are similar to:

```text
PASS: ISS and RTL traces match for 12 retired instructions.
All three ISS-to-RTL comparisons passed.
```

Open a waveform in Verdi:

```bash
make waves CASE=alu
make waves CASE=memory
make waves CASE=branch
```

## Generated Files

```text
build/<case>.bin
build/<case>.hex
build/<case>.fsdb
traces/<case>_iss.trace
traces/<case>_rtl.trace
logs/iss_<case>.log
logs/rtl_<case>.log
logs/compare_<case>.log
```

Use `make clean` to remove generated files. Do not include `build/`, `logs/`,
FSDB databases, `__MACOSX/`, or `._*` files in the final submission ZIP.
