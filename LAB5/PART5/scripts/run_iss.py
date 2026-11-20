#!/usr/bin/env python3
"""Run the supplied MIPS ISS and create RTL-compatible program and trace files.

This is an adapter around ISS/Mips_Simulator.py, not a replacement ISS.  The
provided assembler and processor are reused.  The adapter supplies the small
compatibility changes needed for comparison with this RTL: standard LW/SW
effective addresses, 32-bit values, a hardwired register zero, normalized PC
values, and a deterministic architectural retirement trace.
"""

import argparse
import importlib.util
import sys
from pathlib import Path


MASK32 = 0xFFFFFFFF
TEXT_BASE = 0x00400000
DATA_BASE = 0x10010000
HALT_ADDRESS = 0x000000FC

OP_RTYPE = 0x00
OP_BEQ = 0x04
OP_ADDI = 0x08
OP_LW = 0x23
OP_SW = 0x2B

FUNCT_ADD = 0x20
FUNCT_AND = 0x24
SUPPORTED_RTYPE_FUNCTS = {FUNCT_ADD, FUNCT_AND}


def parse_args():
    script_dir = Path(__file__).resolve().parent
    part5_dir = script_dir.parent

    parser = argparse.ArgumentParser(
        description="Run the supplied MIPS ISS and generate comparison files."
    )
    parser.add_argument(
        "--iss",
        type=Path,
        default=part5_dir / "ISS" / "Mips_Simulator.py",
        help="Path to the supplied MIPS ISS source",
    )
    parser.add_argument("--asm", type=Path, required=True)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--hex", dest="hex_file", type=Path, required=True)
    parser.add_argument("--trace", type=Path, required=True)
    parser.add_argument("--max-instructions", type=int, default=1000)
    return parser.parse_args()


def load_iss_module(iss_path):
    if not iss_path.is_file():
        raise FileNotFoundError("ISS source does not exist: {}".format(iss_path))

    spec = importlib.util.spec_from_file_location("provided_mips_iss", str(iss_path))
    if spec is None or spec.loader is None:
        raise ImportError("Could not load ISS source: {}".format(iss_path))

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def reset_iss_globals(iss):
    """Clear module-level assembler state before running each program."""
    iss.memory_map.clear()
    iss.memory.clear()
    iss.label_map.clear()
    iss.current_data_address = DATA_BASE
    iss.current_instruction_address = TEXT_BASE


def make_compatible_processor_class(iss):
    class RTLCompatibleProcessor(iss.MIPSProcessor):
        """Reuse the supplied processor with RTL-compatible LW/SW addressing."""

        def execute_i_type(self, opcode, rs, rt, immediate):
            if opcode == "100011":
                # RTL effective address = base register + sign-extended offset.
                address = (self.registers[rs] + immediate) & MASK32
                value = self.memory.get(address, 0)

                if isinstance(value, str):
                    raise RuntimeError(
                        "LW attempted to read instruction memory at 0x{:08x}".format(
                            address
                        )
                    )

                self.registers[rt] = int(value) & MASK32

            elif opcode == "101011":
                address = (self.registers[rs] + immediate) & MASK32
                self.memory[address] = self.registers[rt] & MASK32

            else:
                # ADDI and BEQ use the execution behavior from the supplied ISS.
                super(RTLCompatibleProcessor, self).execute_i_type(
                    opcode, rs, rt, immediate
                )

    return RTLCompatibleProcessor


def read_binary_instructions(binary_file):
    instructions = []

    with binary_file.open("r", encoding="utf-8") as handle:
        for line_number, raw_line in enumerate(handle, start=1):
            instruction = raw_line.strip()

            if not instruction:
                continue

            if len(instruction) != 32 or any(bit not in "01" for bit in instruction):
                raise ValueError(
                    "{}:{}: expected one 32-bit binary instruction".format(
                        binary_file, line_number
                    )
                )

            instructions.append(instruction)

    if not instructions:
        raise ValueError("No instructions were generated from {}".format(binary_file))

    return instructions


def write_hex_file(binary_instructions, hex_file):
    hex_file.parent.mkdir(parents=True, exist_ok=True)

    with hex_file.open("w", encoding="utf-8") as handle:
        for instruction in binary_instructions:
            handle.write("{:08x}\n".format(int(instruction, 2)))


def decode_fields(instruction_word):
    return {
        "opcode": (instruction_word >> 26) & 0x3F,
        "rs": (instruction_word >> 21) & 0x1F,
        "rt": (instruction_word >> 16) & 0x1F,
        "rd": (instruction_word >> 11) & 0x1F,
        "funct": instruction_word & 0x3F,
    }


def validate_supported_instruction(pc, instruction_word, fields):
    opcode = fields["opcode"]

    if opcode == OP_RTYPE:
        if fields["funct"] not in SUPPORTED_RTYPE_FUNCTS:
            raise RuntimeError(
                "Unsupported R-type instruction at PC 0x{:08x}: 0x{:08x}".format(
                    pc, instruction_word
                )
            )
        return

    if opcode not in {OP_ADDI, OP_LW, OP_SW, OP_BEQ}:
        raise RuntimeError(
            "Unsupported instruction at PC 0x{:08x}: 0x{:08x}".format(
                pc, instruction_word
            )
        )


def normalize_processor_state(processor):
    """Match the RTL's 32-bit datapath and hardwired register zero."""
    processor.pc &= MASK32

    for register_number in range(1, 32):
        processor.registers[register_number] &= MASK32

    processor.registers[0] = 0

    for address, value in list(processor.memory.items()):
        if isinstance(value, int):
            processor.memory[address] = value & MASK32


def format_trace_line(
    normalized_pc,
    instruction_word,
    regwrite,
    destination_register,
    register_data,
    memwrite,
    memory_address,
    memory_data,
):
    return (
        "PC={:08x} INSTR={:08x} REGWRITE={} RD={} REGDATA={:08x} "
        "MEMWRITE={} MEMADDR={:08x} MEMDATA={:08x}"
    ).format(
        normalized_pc,
        instruction_word,
        int(regwrite),
        destination_register,
        register_data & MASK32,
        int(memwrite),
        memory_address & MASK32,
        memory_data & MASK32,
    )


def execute_program(processor, binary_instructions, trace_file, max_instructions):
    valid_instruction_addresses = {
        TEXT_BASE + (4 * index) for index in range(len(binary_instructions))
    }

    retired_count = 0
    halt_seen = False
    trace_file.parent.mkdir(parents=True, exist_ok=True)

    with trace_file.open("w", encoding="utf-8") as trace_handle:
        while processor.pc in valid_instruction_addresses:
            if retired_count >= max_instructions:
                raise RuntimeError(
                    "ISS exceeded the {}-instruction limit".format(max_instructions)
                )

            pc_before = processor.pc
            instruction_bits = processor.memory[pc_before]

            if not isinstance(instruction_bits, str):
                raise RuntimeError(
                    "Expected an instruction at PC 0x{:08x}".format(pc_before)
                )

            instruction_word = int(instruction_bits, 2)
            fields = decode_fields(instruction_word)
            validate_supported_instruction(pc_before, instruction_word, fields)

            opcode = fields["opcode"]
            rs = fields["rs"]
            rt = fields["rt"]
            rd = fields["rd"]

            regwrite = False
            destination_register = 0
            memwrite = False
            memory_address = 0
            memory_data = 0

            if opcode == OP_RTYPE:
                destination_register = rd
                regwrite = rd != 0
            elif opcode in {OP_ADDI, OP_LW}:
                destination_register = rt
                regwrite = rt != 0
            elif opcode == OP_SW:
                immediate = processor.sign_extend(instruction_bits[16:])
                memory_address = (
                    processor.registers[rs] + immediate
                ) & MASK32
                memory_data = processor.registers[rt] & MASK32
                memwrite = True

            # The supplied processor expects PC+4 before instruction execution.
            processor.pc = (processor.pc + 4) & MASK32
            processor.execute_instruction(instruction_bits)
            normalize_processor_state(processor)

            register_data = (
                processor.registers[destination_register] if regwrite else 0
            )
            normalized_pc = (pc_before - TEXT_BASE) & MASK32

            trace_handle.write(
                format_trace_line(
                    normalized_pc,
                    instruction_word,
                    regwrite,
                    destination_register if regwrite else 0,
                    register_data,
                    memwrite,
                    memory_address if memwrite else 0,
                    memory_data if memwrite else 0,
                )
                + "\n"
            )

            retired_count += 1

            if memwrite and memory_address == HALT_ADDRESS:
                halt_seen = True
                break

    if not halt_seen:
        raise RuntimeError(
            "Program ended without the halt marker: sw $zero, 252($zero)"
        )

    return retired_count


def main():
    args = parse_args()

    args.asm = args.asm.resolve()
    args.binary = args.binary.resolve()
    args.hex_file = args.hex_file.resolve()
    args.trace = args.trace.resolve()
    args.iss = args.iss.resolve()

    if not args.asm.is_file():
        raise FileNotFoundError("Assembly program does not exist: {}".format(args.asm))

    args.binary.parent.mkdir(parents=True, exist_ok=True)
    args.hex_file.parent.mkdir(parents=True, exist_ok=True)
    args.trace.parent.mkdir(parents=True, exist_ok=True)

    iss = load_iss_module(args.iss)
    reset_iss_globals(iss)

    # Assemble with the supplied existing ISS.
    iss.translate_mips_to_binary(str(args.asm), str(args.binary))
    binary_instructions = read_binary_instructions(args.binary)
    write_hex_file(binary_instructions, args.hex_file)

    CompatibleProcessor = make_compatible_processor_class(iss)

    # Keep instructions at the ISS text base so low RTL data addresses do not
    # overlap instruction entries in the ISS's shared memory dictionary.
    processor = CompatibleProcessor(
        memory_map=dict(iss.memory_map),
        memory=dict(iss.memory),
        label_map=dict(iss.label_map),
        current_data_address=iss.current_data_address,
        current_instruction_address=TEXT_BASE,
    )
    processor.load_instructions(str(args.binary))

    retired_count = execute_program(
        processor,
        binary_instructions,
        args.trace,
        args.max_instructions,
    )

    print("[ISS] Program: {}".format(args.asm))
    print("[ISS] Instructions assembled: {}".format(len(binary_instructions)))
    print("[ISS] Instructions retired: {}".format(retired_count))
    print("[ISS] RTL hex file: {}".format(args.hex_file))
    print("[ISS] Trace file: {}".format(args.trace))
    print("[ISS] PASS")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        print("[ISS] ERROR: {}".format(error), file=sys.stderr)
        sys.exit(1)
