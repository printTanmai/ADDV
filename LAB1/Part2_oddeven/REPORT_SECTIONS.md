# Part II Report Sections

## 2. FIFO Size Determination

The design receives 80 data items during every 100 clock cycles. Based on the
given assumption, each group of 80 items contains 40 even values and 40 odd
values, although they may arrive in any order. The output must alternate
between even and odd values, so the arbiter cannot read from the same FIFO
twice in a row.

The worst case occurs when all 40 values of one parity arrive before the other
parity becomes available. For example, after reset the arbiter expects an even
value. If the first 40 inputs are odd, none of those odd values can be removed
until an even value arrives and is read. Therefore, the odd FIFO must be able
to store all 40 odd values. The same situation can occur for the even FIFO
depending on the current arbiter state and the input ordering. For this reason,
both FIFOs were assigned a depth of 40.

The depth-setting test case sends 40 odd values followed by 40 even values. In
this case, the odd FIFO reaches a peak occupancy of 40 and asserts its full
flag. A second case sends alternating even and odd values to test normal
balanced operation.

## 4. Bug Encountered and Solution

One issue I encountered was that the output data and FIFO status flags were
delayed by one clock cycle. The FIFO originally registered its output on the
same clock edge that the read arbiter sampled it. Since both blocks used
nonblocking assignments, the arbiter received the previous FIFO value instead
of the current value. The full and empty flags were also calculated using one
next pointer and one old pointer, which caused the flags to disagree with the
actual FIFO occupancy.

I found the issue through the repeated data-mismatch and empty-flag errors
reported by the self-checking testbench. I corrected the FIFO by making its
current head value available through a continuous assignment. I also changed
the flag equations to compare the next read pointer with the next write
pointer. These changes allow the arbiter to capture the correct value and keep
the FIFO flags synchronized with the number of stored items.

