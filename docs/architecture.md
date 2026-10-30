# Architecture

The processor is a multi-cycle 16-bit Simple RISC Machine derived from the
original `../lab7` implementation.

```text
memory <-> CPU controller <-> A/B/C datapath <-> register file
                  |                 |
                  PC             ALU + shifter
```

The controller fetches an instruction, decodes it, and sequences register
reads, execution, memory access, and writeback across multiple clock cycles.
The datapath retains the original clocked A, B, C, and status registers. The
unified memory contains both instructions and data and is word addressed.

Key parameters:

- Data and instruction width: 16 bits
- Registers: eight (`R0` through `R7`)
- Program counter: 8 bits
- Memory: 256 words
- Flags: zero (`Z`), negative (`N`), overflow (`V`)
- Link register: `R7`
