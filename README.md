# DE1-SoC 16-Bit RISC CPU

A custom 16-bit, multi-cycle RISC processor implemented in SystemVerilog for
the Intel DE1-SoC FPGA development board. The project covers the complete path
from instruction fetch and decoding through execution, memory access, and
writeback, with self-checking simulations and example assembly programs.

The current design is a working stored-program processor with a custom
instruction set. It is intentionally compact enough to understand at the
register-transfer level while still demonstrating the core architecture of a
general-purpose CPU.

## Current capabilities

- 16-bit instructions and datapath
- Eight 16-bit general-purpose registers (`R0` through `R7`)
- 8-bit program counter
- Unified 256 x 16-bit instruction and data memory
- Multi-cycle fetch, decode, execute, memory, and writeback control
- Clocked A, B, C, and status registers
- Zero (`Z`), negative (`N`), and overflow (`V`) condition flags
- Signed immediate and displacement handling
- Register, immediate, and shifted-register operations
- PC-relative and register-indirect control flow
- Function calls using `R7` as the link register
- Halt detection and FPGA-visible execution state
- Self-checking integration simulations
- Quartus project for the DE1-SoC Cyclone V FPGA

## Instruction set

| Category | Instructions |
|---|---|
| Data movement | `MOV` immediate and register |
| Arithmetic | `ADD`, `CMP` |
| Logic | `AND`, `MVN` |
| Shifts | `LSL #1`, `LSR #1`, `ASR #1` |
| Memory | `LDR`, `STR` with signed displacement |
| Branches | `B`, `BEQ`, `BNE`, `BLT`, `BLE` |
| Functions | `BL`, `BX`, `BLX` |
| Control | `NOP`, `HALT` |

Additional encoding details are documented in [docs/isa.md](docs/isa.md).

## Architecture

```text
                     +-------------------+
                     | Multi-cycle       |
                     | CPU controller    |
                     | PC + instruction  |
                     | register          |
                     +---------+---------+
                               |
             control signals   |   status flags
                               v
  +----------+      +-----------------------+      +----------+
  | Unified  |<---->| A/B/C staged datapath |<---->| Register |
  | memory   |      | ALU + operand shifter |      | file     |
  +----------+      +-----------------------+      +----------+
```

Each instruction is completed over several clock cycles. The controller
selects registers, captures operands in the A and B registers, performs the
operation, optionally accesses memory, and writes the result back. This keeps
the hardware small and makes each stage observable during simulation.

See [docs/architecture.md](docs/architecture.md) for more detail.

## Repository structure

```text
rtl/
  core/                CPU, datapath, ALU, shifter and register file
  memory/              unified instruction/data memory
  system/              reusable CPU and memory integration
  board/               DE1-SoC wrapper and seven-segment display logic
verification/
  unit/                focused module and instruction tests
  integration/         complete-program system tests
software/
  assembly/            human-readable example programs
  images/              assembled memory initialization files
docs/                   architecture and instruction-set documentation
scripts/                simulation and compatibility-check commands
simple_risc.qpf/.qsf    Quartus project configuration
```

Generated ModelSim and Quartus files are excluded through `.gitignore`.

## Verification

The integration testbench runs two programs concurrently:

1. A load/store program that reads `0xABCD` from memory, writes it to another
   address, and verifies the affected registers and memory.
2. A conditional-branch loop that exercises `MOV`, `ADD`, `CMP`, and a
   backwards `BLT` until the expected result is reached.

The current simulations compile with zero ModelSim errors or warnings and
finish with a self-checking `PASS` result.

### Run the simulation

From the repository root:

```powershell
./scripts/run-tests.ps1
```

The script uses Icarus Verilog when available. On Windows, it can also detect
the ModelSim installation bundled with Intel FPGA Lite 18.1.

## FPGA usage

Open `simple_risc.qpf` in Quartus. The project targets the Cyclone V device on
the DE1-SoC. Import the appropriate DE1-SoC pin assignments before performing
a complete board build.

The current board wrapper exposes:

- `KEY0`: manual CPU clock
- `KEY1`: reset while pressed
- `LEDR[9]`: processor halted
- `LEDR[8]`: memory write active
- `LEDR[7:0]`: current memory address
- `HEX3..HEX0`: most recent execution result
- `HEX5`: `N`, `V`, and `Z` flags

## Development roadmap

The following phases are intentionally scoped for incremental development.

### Phase 1: Verification and documentation

- Add self-checking unit tests for the ALU, shifter, and register file
- Add one instruction-level test for every supported opcode
- Test negative values, signed overflow, branch boundaries, and disabled writes
- Add example programs such as Fibonacci, array sum, and a countdown loop
- Complete binary field diagrams and encoding examples in the ISA reference

### Phase 2: Memory-mapped board I/O

- Reserve addresses for LEDs, switches, push buttons, and seven-segment output
- Route `LDR` and `STR` transactions to either RAM or the selected peripheral
- Add simulation models for peripheral reads and writes
- Write an assembly demo that reads switches and displays a calculated result

Proposed memory map:

| Address | Device |
|---|---|
| `0xF0` | Red LEDs |
| `0xF1` | Slide switches |
| `0xF2` | Push buttons |
| `0xF3` | Seven-segment output |

### Phase 3: On-board debugging controls

- Add run, pause, reset, and single-step operation
- Add a selectable divided clock for continuous execution
- Display the PC, instruction, result, flags, or selected register on the HEX
  displays
- Make internal CPU state easier to observe during hardware demonstrations

### Phase 4: Final integration and demonstration

- Run the full regression suite
- Complete the Quartus board build and hardware validation
- Document switch, button, LED, and display behavior
- Create a demonstration program using memory-mapped input and output
- Add waveform captures and an updated architecture diagram

## Project goal

The planned final result is a complete 16-bit FPGA system-on-chip that executes
assembly programs from memory, performs arithmetic and control flow, interacts
with DE1-SoC peripherals through memory-mapped I/O, and supports convenient
on-board debugging.
