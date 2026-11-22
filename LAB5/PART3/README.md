# Lab 5 Part 3: UVM Functional Coverage

## Purpose and Scope

This part observes the existing five-stage MIPS processor and measures which
instruction scenarios actually execute. Stimulus is generated with plain
SystemVerilog classes. UVM supplies the monitor, analysis connection,
subscriber, environment, and test hierarchy. There is no UVM driver or sequencer
because the generated program is loaded directly into instruction memory.

The functional coverage model is deliberately limited to the lab scope:

- instructions: `ADD`, `AND`, `LW`, `SW`, and `BEQ`;
- general-purpose registers: `$1`, `$2`, `$3`, and `$4`;
- normal data-memory byte addresses: `0`, `4`, `8`, and `12`;
- dependency gaps: one, two, three, or four intervening executed instructions;
- forward branch offsets: one, two, three, or four instruction words.

`ADDI` is used for register initialization only. Address `0xFC` is a special
simulation-completion address. Setup ADDIs and the completion store are not
counted toward the five-instruction functional coverage model. The four real
SW instructions that initialize the selected data words are observed normally.

## Files and Architecture

| File | Responsibility |
| --- | --- |
| `RTL/*.sv` | Existing non-SRAM processor and memories; do not compile the SRAM wrapper |
| `TESTBENCH/mips_fetch_if.sv` | Passive interface containing fetch, pipeline-control, and EX observation signals |
| `TESTBENCH/mips_part3_pkg.sv` | Instruction transaction, UVM monitor, environment, and test definitions |
| `TESTBENCH/instruction_generator.svh` | Constrained-random instruction sequence generator and closure templates |
| `TESTBENCH/mips_monitor.svh` | Fetch monitor, stall/flush qualification, and analysis port |
| `TESTBENCH/mips_coverage.svh` | `uvm_subscriber` and functional coverage model |
| `TESTBENCH/testbench.sv` | Clock/reset, program generation/loading, interface wiring, and completion detection |
| `Makefile` | Compile, simulate, merge coverage, and open Verdi |
| `env.cshrc` | ASU VCS/Verdi environment for csh/tcsh |

Instruction-memory fetch signals are captured by the UVM monitor, sent through
its analysis port to the subscriber's analysis implementation, and sampled into
functional covergroups.

The monitor observes accepted fetches and tracks them through a passive shadow
of ID and EX. It honors stalls and flushes. A transaction is published after the
instruction reaches EX, when its actual effective address and BEQ outcome are
available. This avoids counting the same stalled fetch repeatedly or crediting
wrong-path instructions that the processor flushes. These are execution-based
functional coverage samples, not an architectural retirement checker or an ISS.

## Coverage Model

The collector samples:

1. All five instruction kinds.
2. Individual ALU source and destination register fields.
3. Load/store register fields and effective memory addresses.
4. BEQ source registers, offsets, taken/not-taken outcomes, and offset/outcome
   combinations.
5. Ordered pairs of adjacent executed instructions.
6. Register read-after-write dependencies, including ADD-to-AND dependencies
   with register/gap combinations.
7. Store-to-load dependencies with address/gap combinations.

For dependency coverage, a gap of one means one executed instruction appears
between the producer and consumer. It does not mean one clock cycle, and an
immediately adjacent dependent pair has gap zero rather than gap one. Pipeline
stall cycles do not increase the instruction gap. Intervening writes that
replace the producer's value prevent stale dependency matches.

Each covergroup reports its observed percentage at the end of a run. The merged
VCS/Verdi database is the authoritative cumulative coverage result. No fixed
percentage is assumed in advance.

## Program Generation

Every program starts by initializing the four registers and four memory
locations, then includes either randomized initial stimulus or a selected
coverage-closure template. Programs remain within the existing 64-word
instruction memory. Branch targets remain inside the generated program.

Closure templates are selected using `+MODE=closure +CASE=<number>`:

| Cases | Intended coverage |
| --- | --- |
| `0` through `24` | All 25 ordered pairs of the five instruction kinds |
| `25` through `40` | ADD-to-AND register/gap combinations |
| `41` through `56` | SW-to-LW address/gap combinations |
| `57` through `64` | Four branch offsets with both outcomes |
| `65` through `68` | Register-field sweeps |

These templates guide stimulus toward holes while preserving actual pin-based
sampling. They do not directly mark coverage bins as hit. Random register,
operand, and gap choices are controlled by VCS `+ntb_random_seed`.

## Simulation Completion

The final instruction is:

```asm
sw $zero, 252($zero)
```

The testbench observes a store with byte address `0x000000FC` and data zero.
This is the trick-box completion event. Its terminal message provides evidence
that the generated program reached its end. UVM objections are then released
so UVM report phases and coverage database writing can finish normally. A cycle
timeout prevents a hung run from being accepted as successful.

## Run on Apporto

Run these commands from `LAB5/PART3`. In the csh/tcsh shell used on Apporto:

```bash
cd ~/ADDV/ADDV/LAB5/PART3
source env.cshrc
make compile
```

VCS compiles with `-ntb_opts uvm`. Covergroups collect functional coverage;
Part 4 code-coverage flags are intentionally not enabled here.

### 1. First Run and Initial Screenshot

```bash
make initial SEED=1
make coverage_initial
```

In Verdi's coverage view, expand the UVM coverage collector and show its
functional covergroups and bins. Capture the initial coverage screenshot before
running closure. Preserve it in the report. Also capture the terminal's
trick-box completion message as required by the end-of-simulation instructions.

The initial database is `coverage/initial.vdb`. Re-running the initial target
can add test data to this same database, so do not do so before capturing the
first-run result. `make clean` removes generated databases if a completely new
experiment is needed.

### 2. Coverage-Closure Runs

```bash
make closure
make merge
make coverage_final
```

The default closure regression executes all 69 templates using seed 1. Inspect
the merged functional bins in Verdi. If any required bins remain uncovered,
investigate their stimulus requirements before extending the run set. Additional
seeds can be run and merged:

```bash
make closure SEEDS="2 3 4"
make merge
make coverage_final
```

Run one closure template during debugging:

```bash
make sim MODE=closure CASE=25 SEED=2 LOG_TRANSACTIONS=1
```

Each closure run has its own `coverage/closure_c<case>_s<seed>.vdb` directory.
The merge target uses `urg` to merge the initial and closure databases into
`coverage/merged.vdb`, excluding the merged output itself from the input list.
The HTML report is written under `reports/merged/`.

### 3. Optional Waveform Debugging

```bash
make waves WAVE_RUN=initial
make waves WAVE_RUN=closure_c25_s1
make waves WAVE_RUN=selected
```

Waveforms help debug sampling and branch/stall behavior, but Part 3's explicitly
requested screenshots are the initial and final functional coverage reports.

## Plusargs

| Plusarg | Purpose |
| --- | --- |
| `+MODE=initial` or `+MODE=closure` | Select randomized initial stimulus or a closure template |
| `+CASE=<number>` | Select closure template |
| `+ntb_random_seed=<number>` | Set the VCS random seed |
| `+PROGRAM_FILE=<path>` | Save/load the generated program hex file |
| `+FSDB=<path>` | Select waveform filename |
| `+LOG_TRANSACTIONS=1` | Enable detailed monitor transaction messages |
| `+TIMEOUT=<cycles>` | Limit execution cycles |

The Makefile checks for UVM errors and fatals as well as shell failures. A
simulation reaching its completion marker proves completion, not that the
entire functional coverage model has reached 100 percent. Verify the actual
merged coverage report before claiming coverage closure.

## Part 3 Report and ZIP Checklist

- Describe the monitor and copy the relevant `uvm_monitor`,
  `uvm_analysis_port`, sampling, and `write` connection snippets.
- Describe the coverage model and copy representative covergroup/bin/cross
  snippets from `mips_coverage.svh`.
- Include the initial first-run Verdi functional coverage screenshot.
- Include the final best merged Verdi functional coverage screenshot and state
  the measured result, seeds, and template set used.
- Document the trick-box address, final instruction, testbench detection code,
  and terminal completion message.
- Include all design and testbench source files, Makefile, and this README in
  the code ZIP. Do not include generated simulator or coverage databases.
- Include the required partner-contribution summary in the overall lab report.

Generated files live under `build/`, `logs/`, `coverage/`, and `reports/` and are
ignored by Git. `make clean` removes those generated products while preserving
the RTL, testbench, and documentation.
