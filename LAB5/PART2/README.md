# PART 2 — Five-Stage Pipelined MIPS Processor

PART 2 contains a 32-bit, in-order MIPS-style processor implemented in SystemVerilog. The active design is a classic five-stage pipeline (IF, ID, EX, MEM, WB) with register forwarding, load-use stalling, and branch flushing. Its testbench builds a constrained-random instruction program, loads it into instruction memory, and runs the processor until it observes a designated stop-marker store.

## Contents

- [`RTL/`](RTL/) — processor, pipeline registers, control and hazard logic.
- [`TESTBENCH/`](TESTBENCH/) — constrained-random instruction generator and simulation testbench.
- [`sim/`](sim/) — VCS Makefile, simulator setup, and generated simulation artifacts.

## Design overview

The active simulation top is `top` in [`RTL/top.sv`](RTL/top.sv). It connects the `mips` processor to separate instruction and data memories, each modeled as 64 words of 32 bits. Instruction fetch indexes memory with `pc[7:2]`; data memory indexes with address bits `[7:2]`, so the modeled address range is 0x00–0xFC in four-byte word steps. The testbench initializes instruction memory before releasing reset. Data memory is not initialized globally; values should be written before they are loaded.

The processor pipeline is:

| Stage | Main work |
| --- | --- |
| IF | Fetch instruction and calculate `PC + 4`; select sequential or redirected PC. |
| ID | Decode instruction, read registers, sign-extend the immediate, and generate controls. |
| EX | Perform ALU operation, calculate effective addresses and branch decisions, and select destination register. |
| MEM | Read or write data memory. |
| WB | Select ALU or memory result and write the register file. |

Pipeline registers carry data and control between stages. The register file writes on the falling clock edge, while pipeline registers and data memory use the rising edge. Reset is asynchronous for the pipeline state elements.

### Hazard handling

- **Data forwarding:** EX operands can be forwarded from MEM or WB. A matching MEM-stage result takes priority over a WB-stage result.
- **Load-use stall:** when an EX-stage load destination matches either source-register field of the ID-stage instruction, the front of the pipeline stalls and the ID/EX register is cleared to insert a bubble.
- **Control flow:** `beq` is resolved in EX. A taken branch flushes younger instructions from decode and execute. `j` is decoded by the controller and has a fetch-stage target path, but the constrained-random program does not generate jumps.

These mechanisms are implemented primarily in [`RTL/hazard_unit.sv`](RTL/hazard_unit.sv) and [`RTL/datapath.sv`](RTL/datapath.sv).

## Implemented instruction operations

The controller/ALU decode logic in [`RTL/controller.sv`](RTL/controller.sv) and [`RTL/datapath.sv`](RTL/datapath.sv) includes:

| Instruction | Operation |
| --- | --- |
| `add`, `sub` | Register-register addition and subtraction. |
| `and`, `or`, `slt` | Register-register bitwise AND/OR and signedness-unspecified less-than comparison (the RTL compares the 32-bit operands as unsigned vectors). |
| `addi` | Register plus sign-extended immediate. |
| `lw`, `sw` | Word load and store using base-plus-immediate effective addresses. |
| `beq` | Branch when the selected operands compare equal. |
| `j` | Jump to the instruction-encoded target. |

The generated test program intentionally uses a smaller subset: setup `addi` instructions; R-type `add` and `and`; `lw`/`sw`; and taken and not-taken `beq` instructions. Its randomized R-type instructions are limited to `add` and `and`. Thus, controller decode support for `sub`, `or`, `slt`, and `j` should not be mistaken for coverage of those instructions in the current generated-program test.

The register-file read port returns zero for register 0. The RTL does not suppress writes to the internal register-file entry for register 0, so software/test programs should not target register 0 as a destination.

## Testbench and generated program

[`TESTBENCH/instruction_generator.sv`](TESTBENCH/instruction_generator.sv) defines the instruction encodings and constrained-random sequence. Each generated program includes:

1. Register initialization for registers 1–10.
2. Initial stores and an `add`-to-`and` dependency with a randomized gap.
3. A store/load dependency using data-memory address 0x08, with randomized gap instructions that avoid overwriting that location.
4. A taken and a not-taken branch, with additional instructions to exercise the flush path.
5. A bounded number of additional randomized R-type, load, and store instructions.
6. A final `sw $0, 252($0)` stop marker.

The testbench uses the `SEED` plusarg (default 1) to seed the sequence, writes the generated words to `generated_program.hex`, loads that file into the DUT instruction RAM, and releases reset. It prints observed stores and finishes when a store to address 0xFC carries zero. It fails if the marker data is incorrect or if the marker is not seen within 500 clock cycles. This is a simulation-completion check, not a full architectural scoreboard: it does not independently compare every register and memory result against a reference model.

## Running the simulation

The supplied Makefile targets Synopsys VCS and UVM 1.2. Run commands from `PART2/sim` so its relative source paths and output locations resolve correctly:

```sh
cd PART2/sim
make compile
make sim SEED=42
```

`make sim` compiles and then runs `simv`; the seed is optional and defaults to 1. To compile and run in one VCS invocation instead:

```sh
make compile_and_sim SEED=42
```

Useful targets:

| Target | Action |
| --- | --- |
| `compile` | Compile the active RTL and testbench into `simv`. |
| `sim` | Compile, then run `simv` with `+SEED=$(SEED)`. |
| `compile_and_sim` | Compile and run through VCS in one invocation. |
| `waves_verdi` | Open the existing `mips.vcd` waveform in Verdi. |
| `sim_verdi` | Run the compile-and-sim flow, then open the waveform. |
| `clean` | Remove simulator build directories, executable, waveform files, and logs. |

The Makefile points to an ASU-hosted VCS installation and uses `-ntb_opts uvm-1.2`; running elsewhere requires a compatible VCS/UVM installation and license, and may require overriding the `VCS` or `VERDI` Make variables. [`sim/env.cshrc`](sim/env.cshrc) provides the lab's C-shell environment setup; it uses `setenv` and is intended for `csh`/`tcsh`, not Bash. The generated `generated_program.hex`, `mips.vcd`, and logs are written in the simulation working directory. `make clean` does not remove `generated_program.hex`.

## RTL file guide

| File | Purpose |
| --- | --- |
| [`RTL/top.sv`](RTL/top.sv) | Active top-level, processor wrapper, and behavioral instruction/data memories. |
| [`RTL/controller.sv`](RTL/controller.sv) | Main opcode decoder and ALU function decoder. |
| [`RTL/datapath.sv`](RTL/datapath.sv) | Five-stage datapath, register file, ALU, and datapath helpers. |
| [`RTL/hazard_unit.sv`](RTL/hazard_unit.sv) | Forwarding selection, load-use stall, and flush control. |
| [`RTL/pipe_if_id.sv`](RTL/pipe_if_id.sv) | Fetch/decode pipeline register with enable and clear. |
| [`RTL/pipe_id_ex.sv`](RTL/pipe_id_ex.sv) | Decode/execute pipeline register with clear. |
| [`RTL/pipe_ex_mem.sv`](RTL/pipe_ex_mem.sv) | Execute/memory pipeline register. |
| [`RTL/pipe_mem_wb.sv`](RTL/pipe_mem_wb.sv) | Memory/writeback pipeline register. |
| [`RTL/flopenc.sv`](RTL/flopenc.sv) | Enabled, resettable register used for the PC. |
| [`RTL/mux3.sv`](RTL/mux3.sv) | Three-way forwarding mux. |
| [`TESTBENCH/testbench.sv`](TESTBENCH/testbench.sv) | Clock/reset, program loading, stop-marker check, timeout, and VCD dump. |
| [`TESTBENCH/instruction_generator.sv`](TESTBENCH/instruction_generator.sv) | Constrained-random instruction and sequence generation. |

## Separate SRAM variant

[`RTL/top_with_sram.sv`](RTL/top_with_sram.sv) is not included in the active simulation Makefile. It defines modules also named `top`, `mips`, `imem`, and `dmem`, and instantiates an external `SRAM_32x64_1rw` model. Do not compile it together with `top.sv`; treat it as a separate integration variant requiring its own compatible RTL and SRAM model. Likewise, [`RTL/memfile.dat`](RTL/memfile.dat) is a hand-written example program and is not loaded by the current testbench, which uses the generated hex file instead.
