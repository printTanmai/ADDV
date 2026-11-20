#!/usr/bin/env python3
"""Compare normalized architectural traces from the ISS and RTL."""

import argparse
import difflib
from pathlib import Path


def read_trace(path):
    lines = []

    with Path(path).open("r", encoding="utf-8") as trace_file:
        for line in trace_file:
            line = line.strip()
            if line and not line.startswith("#"):
                lines.append(line)

    return lines


def main():
    parser = argparse.ArgumentParser(
        description="Compare ISS and RTL architectural retirement traces."
    )
    parser.add_argument("iss_trace", help="Trace produced by the MIPS ISS")
    parser.add_argument("rtl_trace", help="Trace produced by RTL simulation")
    args = parser.parse_args()

    iss_lines = read_trace(args.iss_trace)
    rtl_lines = read_trace(args.rtl_trace)

    if iss_lines == rtl_lines:
        print(
            "PASS: ISS and RTL traces match for {} retired instructions.".format(
                len(iss_lines)
            )
        )
        return 0

    print("FAIL: ISS and RTL traces do not match.")

    maximum_length = max(len(iss_lines), len(rtl_lines))
    for index in range(maximum_length):
        iss_line = iss_lines[index] if index < len(iss_lines) else "<missing>"
        rtl_line = rtl_lines[index] if index < len(rtl_lines) else "<missing>"

        if iss_line != rtl_line:
            print("First mismatch at retired instruction {}:".format(index + 1))
            print("  ISS: {}".format(iss_line))
            print("  RTL: {}".format(rtl_line))
            break

    print("\nComplete trace difference:")
    for line in difflib.unified_diff(
        iss_lines,
        rtl_lines,
        fromfile=args.iss_trace,
        tofile=args.rtl_trace,
        lineterm="",
    ):
        print(line)

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
