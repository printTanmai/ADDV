# Lab 5 Part 4: RTL Code Coverage

## Purpose

Part 4 measures the RTL exercised by instruction streams, rather than the
user-defined functional bins measured in Part 3. It reuses the corrected Part 3
generator, UVM monitor/subscriber/environment/test, and processor. No processor
functionality is changed to improve a coverage score.

The code-coverage build enables these metrics at compilation and simulation:

```text
-cm line+tgl+cond+fsm
```

| Metric | Meaning |
| --- | --- |
| Line | Executable RTL statements exercised |
| Toggle | Instrumented bits making zero-to-one and one-to-zero transitions |
| Condition | Boolean condition cases exercised under the tool's instrumentation |
| FSM | Tool-extracted state-machine states and transitions exercised |

`cm_hier.cfg` selects the complete DUT subtree:

```text
+tree MIPS_Testbench.dut
```

The `-cm_hier cm_hier.cfg` option keeps testbench and UVM library implementation
code out of the RTL code-coverage denominator. It does not remove selected
processor blocks or unexercised DUT paths. The existing functional covergroups
may still appear under Verdi's Groups tab, but those are not the Part 4 results.

## Files

| File or directory | Purpose |
| --- | --- |
| `RTL/` | Existing non-SRAM MIPS processor, pipeline registers, and memories |
| `TESTBENCH/` | Reused Part 3 stimulus, observation, and UVM completion flow |
| `Makefile` | Instrumented compilation, runs, merge, reports, and Verdi launch |
| `cm_hier.cfg` | DUT-only code-coverage selection |
| `env.cshrc` | ASU VCS/Verdi environment for csh/tcsh |

The package is still named `mips_part3_pkg` because its classes are reused
unchanged. This does not mix the coverage databases from the two lab parts.
All generated Part 4 files are local to `LAB5/PART4`.

## 1. Initial Run and Screenshot

Run from the separate Part 4 directory on Apporto:

```bash
cd ~/ADDV/ADDV/LAB5/PART4
source env.cshrc
make initial SEED=1
make coverage_initial
```

Part 4 requires a fresh instrumented compilation and simulation. Do not copy
Part 3 coverage databases into Part 4; the previous functional-only compilation
cannot supply missing line, toggle, condition, or FSM measurements.

In Verdi, select **Hierarchy** or **Modules**, not Groups. Select or expand
`MIPS_Testbench.dut` and show the code-coverage scores for line, toggle,
condition, and FSM. Keep the database name `initial.vdb` visible. Save this
first-run screenshot before running additional sequences.

Do not run `make clean` in Part 3. Do not run it in Part 4 after the initial run
if you want to retain the initial database for comparison and merging.

The test ends with `sw $zero,252($zero)`. The testbench detects the data-memory
store to byte address `0xFC` with zero data and releases the UVM objection. A
timeout catches a stream that never reaches the completion marker.

## 2. Multiple Runs, Merge, and Final Screenshot

After saving the initial screenshot:

```bash
make closure SEEDS="1 2 3"
make merge
make coverage_final
```

There are 69 stimulus templates per seed. Three seeds therefore run 207
separate simulations, each with its own database. Repeated VCS startup banners
are expected. The changing `Running closure_c<case>_s<seed>` messages show
progress.

The merge target combines the initial and additional databases with URG. The
merged database is `coverage/merged.vdb`; it is not included as an input to its
own merge. Open it in Verdi and save the final code-coverage screenshot using
the same DUT scope and metrics as the initial screenshot.

Optional report commands:

```bash
make report_initial
make report_final
```

Inspect the actual reports before recording percentages. This source package
does not assert a measured code-coverage result in advance.

## 3. Inspecting Uncovered RTL

Use Verdi's uncovered filter and source/detail panes to identify specific
uncovered statements, conditions, and signal bits. For the report, discuss at
most three concrete findings supported by these results. Do not claim an item
was uncovered solely because it appears in the possibilities below.

The allowed stimulus remains limited to `ADD`, `AND`, `LW`, `SW`, and `BEQ`,
four selected registers, four normal data addresses, and positive branch
offsets. `ADDI` initializes the four registers. Therefore 100 percent code
coverage is not guaranteed, even though Part 3's defined functional model can
reach 100 percent.

Possible explanation categories to verify against the actual report are:

1. **RTL outside the allowed instruction subset.** The decoder and ALU also
   implement paths for `J`, `SUB`, `OR`, and `SLT`. A SUB datapath operation used
   internally by BEQ may execute, but that does not exercise decoding an R-type
   SUB instruction. Identify the exact unexercised source lines.
2. **Restricted values and addressing.** Small positive setup values, registers
   `$1` through `$4`, addresses `0`, `4`, `8`, and `12`, and short programs may
   leave high-order operand/address bits, some register-address bits, or
   sign-extension cases untoggled. Report the particular bits or conditions
   shown as uncovered instead of assuming all high bits are unreachable.
3. **Defensive or invalid-input paths.** Default decoder/ALU/multiplexer cases
   for unsupported encodings or unknown control values may not execute under
   valid constrained stimulus. Such paths should not be forced with invalid
   instructions merely to raise the coverage percentage.

Do not modify the RTL or exclude legitimate DUT logic merely to obtain 100
percent. Explain justified holes under the required verification scope.

### FSM Reporting

This processor's controller is combinational decode logic; pipeline registers
are not automatically an FSM. FSM instrumentation is enabled, but the tool may
report no extracted state machines and show FSM as N/A. Confirm the actual
extraction result in the compile log and coverage report. N/A is not a measured
100 percent FSM score and is not automatically a verification failure.

## Useful Commands

```bash
make help
make compile
make sim MODE=closure CASE=25 SEED=2 LOG_TRANSACTIONS=1
make waves WAVE_RUN=initial
```

`make clean` removes generated Part 4 build products, logs, databases, and
reports. It does not change the source files or another lab part.

## Deliverables

- Initial Verdi **code coverage** screenshot from the first instruction stream.
- Final Verdi **code coverage** screenshot from the merged runs.
- Report explanation of at most three actual uncovered items and their causes.

Include the Part 4 Makefile, hierarchy configuration, RTL, testbench, and this
README in the overall code submission. Exclude generated `build/`, `logs/`,
`coverage/`, `reports/`, simulator products, waveform databases, and macOS
metadata from the source ZIP.
