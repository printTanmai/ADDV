# PART 2 — Randomized MIPS Instruction Generator and Pipeline Test

This directory contains a five-stage pipelined MIPS processor and a UVM-based constrained-random instruction generator. The generator is the primary test stimulus: it constructs a legal program with intentional data dependencies and branch sequences, converts each instruction to 32-bit machine code, writes a hexadecimal memory image, and loads it into the simulation's instruction RAM.

The generated program is designed to exercise:

- Register setup with `addi`
- `add`-to-`and` data forwarding
- `sw`-to-`lw` load data dependencies
- Pipeline stalls caused by load-use hazards
- Taken and not-taken `beq` control flow
- Random register, memory, and R-type instructions
- A final store used as a simulation stop marker

## Directory contents

- [`TESTBENCH/instruction_generator.sv`](TESTBENCH/instruction_generator.sv) — constrained-random instruction transaction and complete program sequence generator.
- [`TESTBENCH/testbench.sv`](TESTBENCH/testbench.sv) — clock/reset control, generator invocation, instruction-memory loading, store monitoring, and timeout/stop logic.
- [`RTL/`](RTL/) — five-stage processor, pipeline registers, datapath, controller, and hazard unit.
- [`sim/Makefile`](sim/Makefile) — VCS build and simulation targets.
- [`sim/generated_program.hex`](sim/generated_program.hex) — most recently generated instruction-memory image.

## Instruction generator overview

The package `mips_instruction_pkg` contains two main classes:

| Class | Responsibility |
| --- | --- |
| `instruction` | Represents one instruction, constrains its fields, and produces a 32-bit machine word. |
| `instruction_sequence` | Randomizes sequence-level parameters and assembles the complete instruction list. |

The testbench constructs `instruction_sequence`, seeds it with `SEED`, calls `generate_program()`, writes `instruction_words` to `generated_program.hex`, and loads that file into the DUT instruction RAM.

## Supported instruction set

The generator supports only the encodings listed below. Opcode and function constants are defined in [`instruction_generator.sv`](TESTBENCH/instruction_generator.sv).

| Format | Instruction | Encoding fields |
| --- | --- | --- |
| R-type | `add` | `opcode=000000`, `funct=100000` |
| R-type | `and` | `opcode=000000`, `funct=100100` |
| I-type | `addi` | `opcode=001000` |
| I-type | `lw` | `opcode=100011` |
| I-type | `sw` | `opcode=101011` |
| I-type | `beq` | `opcode=000100` |

The RTL controller contains additional decode support for `sub`, `or`, `slt`, and `j`, but the generator does **not** create those instructions in the current program. Therefore, the generated-program test is not general coverage of every supported controller instruction.

### R-type fields

For an `add` or `and` instruction, the generator constrains:

- `shamt == 0`
- `rs` and `rt` in registers 1–10
- `rd` in registers 5–10

Its machine word is:

```text
{ opcode[31:26], rs[25:21], rt[20:16], rd[15:11], shamt[10:6], funct[5:0] }
```

### I-type fields

For `addi`, `lw`, `sw`, and `beq`, the machine word is:

```text
{ opcode[31:26], rs[25:21], rt[20:16], immediate[15:0] }
```

Field constraints vary by instruction:

| Instruction | Constraints |
| --- | --- |
| `addi` | Base register is `$0`; destination is 1–10; immediate is 1–31. |
| `lw` | Base register is `$0`; destination is 5–10; offset is 0, 4, or 8 bytes. |
| `sw` | Base register is `$0`; source is 1–10; offset is a word-aligned value from 0 through 248. |
| `beq` | Both operands come from registers 1–10; branch offset is -16 through 16. |

## Constrained-random sequence

`generate_program()` creates the sequence in the following order:

### 1. Register initialization

Registers 1–10 are initialized with:

```text
addi $r, $0, (r * 3) + 1
```

For example, register 1 receives 4 and register 2 receives 7. This creates deterministic values for branch comparison while still using a seed-randomized surrounding sequence.

### 2. Initial memory setup

The generator writes two known values:

- `sw $1, 0($0)` — stores register 1 at address 0x00
- `sw $2, 4($0)` — stores register 2 at address 0x04

### 3. `add` → `and` data dependency

The generator explicitly creates:

```text
add $5, $1, $2
and $6, $5, $1
```

This places a producer-consumer relationship in registers 5 and 6. The second instruction needs the result from register 5 while it is still moving through the pipeline.

The sequence-level random variable `add_gap` selects 0–3 gap instructions between the pair. Gap instructions are constrained so they do not create a destination in register 5:

- R-type gap instructions cannot write `$5`.
- Load gap instructions cannot target `$5`.
- Stores and loads are otherwise randomized.

### 4. `sw` → `lw` dependency

The generator stores register 5 at address 0x08, then inserts 0–3 randomized gap instructions, and finally loads address 0x08 into register 7:

```text
sw $5, 8($0)
lw $7, 8($0)
```

The `pair_gap` variable controls the number of gap instructions. Memory-gap instructions avoid `sw` offsets of 8, preventing the gap sequence from overwriting the location used by the load-use test.

### 5. Branch instructions

The generator creates one taken branch and one not-taken branch:

```text
beq $1, $1, 1   # taken
beq $1, $2, 1   # not taken
```

Immediately after each branch, it inserts two random instructions. Random instructions can be `add`, `and`, `lw`, or `sw`. This gives the pipeline opportunities to flush younger instructions after the taken branch and to continue normally after the not-taken branch.

### 6. Random tail

The sequence-level variable `random_count` is randomized to 6–10. Each random tail instruction is an independently randomized R-type, load, or store instruction.

Although the instruction transaction supports `addi` and `beq`, `append_random()` limits random instructions to:

- R-type `add` or `and`
- `lw`
- `sw`

This keeps the random tail focused on forwarding, memory, and control-pipeline interactions.

### 7. Stop marker

The final instruction is:

```text
sw $0, 252($0)
```

It writes zero to data address 0xFC. The testbench treats this store as the program completion marker.

## Sequence random variables

| Variable | Random range | Effect |
| --- | --- | --- |
| `add_gap` | 0–3 | Instructions between the `add` and `and` dependency pair. |
| `pair_gap` | 0–3 | Instructions between the store and load dependency pair. |
| `random_count` | 6–10 | Number of instructions in the randomized tail. |

The seed independently initializes UVM random state. The testbench first calls `generator.srandom(seed)`, then calls `generate_program()`. The same seed should reproduce the same sequence.

## Constraints and code generation

`instruction::to_machine_code()` converts each randomized field combination into a 32-bit word:

- R-type instructions use `{opcode, rs, rt, rd, shamt, funct}`.
- I-type instructions use `{opcode, rs, rt, immediate}`.

The generator returns failure if randomization or constrained sequence construction fails. It also rejects programs larger than 64 instructions, which prevents an instruction image larger than the 64-word instruction RAM.

The output file is `$writememh` formatted hexadecimal memory data. The testbench reloads it with `$readmemh("generated_program.hex", dut.imem_inst.RAM)` before deasserting reset.

## Running with a seed

Run the simulation from `LAB5/PART2/sim`:

```sh
cd LAB5/PART2/sim
make compile_and_sim SEED=42
```

Or compile and run separately:

```sh
make compile
make sim SEED=42
```

If `SEED` is omitted, the Makefile and testbench both default to seed 1. The seed can also be passed directly to an existing executable:

```sh
./simv +SEED=42
```

## Testbench behavior

[`TESTBENCH/testbench.sv`](TESTBENCH/testbench.sv):

1. Initializes clock and reset.
2. Reads `+SEED`; the default is 1.
3. Constructs and seeds the instruction generator.
4. Generates the sequence and writes `generated_program.hex`.
5. Loads the hexadecimal words into instruction RAM.
6. Holds reset for two clock edges, then releases reset.
7. Monitors stores on the negative clock edge.
8. Stops immediately when address 0xFC receives value zero.
9. Reports a fatal error if the stop marker contains another value.
10. Times out after 500 positive clock edges if the marker is never reached.

The testbench creates a VCD file, `mips.vcd`, and prints each observed store and the final stop-marker event.

## Simulation completion limits

This environment is a generator-driven functional test, not an independent architectural scoreboard:

- It verifies sequence generation and successful completion.
- It validates the stop-marker address and value.
- It does not independently calculate the expected final register file or data memory state.
- Its timeout is a maximum simulation length, not a program correctness oracle.

Use the generated `generated_program.hex` and the VCD waveform together to verify individual forwarding, stalling, and branch-execution behavior.

## Useful Make targets

| Target | Action |
| --- | --- |
| `compile` | Compile the processor and testbench into `simv`. |
| `sim SEED=n` | Compile and run with the specified seed. |
| `compile_and_sim SEED=n` | Compile and run in one VCS invocation. |
| `waves_verdi` | Open `mips.vcd` in Verdi. |
| `sim_verdi` | Compile, run, and open the waveform. |
| `clean` | Remove build products, waveforms, logs, and executables. |

The Makefile expects the ASU Synopsys VCS installation configured in [`sim/Makefile`](sim/Makefile). UVM 1.2 support is enabled with `-ntb_opts uvm-1.2`.

## Important implementation notes

- Register 0 reads as zero from the register-file read ports.
- Software writes to register 0 should be avoided even though the internal register-file storage is not explicitly protected by the RTL.
- The instruction RAM and data RAM are each modeled as 64 32-bit words.
- Instruction addresses and data addresses are word-indexed with the address `[7:2]` field.
- Taken branches are resolved in the execute stage and flush younger decode/execute instructions.
- Load-use dependencies stall the front of the pipeline and insert a bubble at ID/EX.
- Forwarded operands originate from the memory or writeback pipeline stages.
