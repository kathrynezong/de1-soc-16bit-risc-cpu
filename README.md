# Simple RISC CPU

This is a standalone continuation of the implementation in `../lab7` (the
folder literally named `lab7`, not the GitHub Classroom starter). It retains
that design's single-read register file, clocked A/B/C datapath, instruction
format, and multi-cycle approach, then completes the stored-program portion
that was still empty in `lab7/ram.sv` and `lab7/lab7_top.sv`. The source
`lab7` folder is unchanged.

## How this extends the original work

- `lab7/REGFILE.sv` became `rtl/core/regfile.sv`; named `R0`-`R7` registers and
  the single read port are retained, with deterministic reset added.
- `lab7/datapath.sv` became `rtl/core/datapath.sv`; its A, B, C, status, `vsel`,
  `asel`, and `bsel` organization is retained.
- `lab7/state_machine.sv`, `instruc_dec.sv`, and `cpu.sv` are extended in
  `rtl/core/cpu.sv` with autonomous fetch, a PC, memory cycles, and branch states.
- The shifter behavior and four ALU operations are retained; signed overflow
  and status handling are corrected.
- The empty RAM and top level are completed as `memory.sv` and `lab7_top.sv`.

## What is implemented

- 16-bit data path and eight 16-bit registers (`R0`-`R7`)
- 8-bit program counter and 256 x 16-bit unified instruction/data memory
- `ADD`, `AND`, `CMP`, `MVN`, register/immediate `MOV`
- `LSL #1`, `LSR #1`, and `ASR #1` operand shifts
- `LDR` and `STR` with signed 5-bit displacement
- `B`, `BEQ`, `BNE`, `BLT`, `BLE`, `BL`, `BX`, and `BLX`
- `NOP`, `HALT`, and `Z/N/V` condition flags
- Lab-style DE1-SoC wrapper and a self-checking system simulation

Your instruction encoding matches the `sas` assembler under
`../lab-7-l1a-kathrynezong/assembler`. `R7` is the link register for `BL` and
`BLX`, and memory remains word addressed.

## Project layout

```text
rtl/
  core/                CPU, datapath, ALU, shifter and register file
  memory/              unified memory
  system/              reusable CPU + memory top
  board/               DE1-SoC wrapper and display logic
verification/
  unit/                focused module/instruction tests
  integration/         complete-program system tests
software/
  assembly/            human-readable assembly sources
  images/              assembled binary memory images
docs/                   architecture and ISA documentation
scripts/                simulation and compatibility-check commands
simple_risc.qpf/.qsf    Quartus project configuration
```

## Run the simulation

From this directory:

```powershell
./scripts/run-tests.ps1
```

The script uses Icarus Verilog when it is on `PATH`; otherwise it detects the
ModelSim bundled with Intel FPGA Lite 18.1 at its standard Windows location.

The test runs two programs. The first is the short load/store program referenced
by the Lab 7 checker: it loads `16'hABCD` from address 5 into `R1`, stores it at
address 6, and halts. The second exercises `ADD`, `CMP`, and a backwards `BLT`
loop. The test checks registers, memory, and termination; a passing run prints
`PASS`.

Run the checker from your actual `../lab7` folder with:

```powershell
./scripts/run-lab7-check.ps1
```

The current result is `INTERFACE OK` with zero ModelSim compile errors or
warnings.

## Use the supplied assembler

Assemble a source file with `sas` from the Lab 7 folder, then copy its binary
text output into `software/images/`. Change the `INIT_FILE` parameter in your system
or testbench to select the image. Each line is one 16-bit binary word.

## FPGA notes

Open `simple_risc.qpf` in Quartus. The included settings select the DE1-SoC's
Cyclone V and source files, but deliberately do not duplicate the board pin
map. Import the known-good pin assignments from
`../lab-7-l1a-kathrynezong/DE1_SoC.qsf` before compiling.

- `KEY0`: step clock
- `KEY1`: reset while pressed
- `LEDR[9]`: halted
- `LEDR[8]`: memory write active
- `LEDR[7:0]`: current memory address
- `HEX3..HEX0`: most recent execution result
- `HEX5`: `N`, `V`, and `Z` flags

## Lab-to-project map

Lab 3 introduces clocked RTL and board I/O. Lab 5 contributes the register
file, shifter, ALU, and datapath concepts. Lab 6 adds instruction decoding and
the multi-cycle controller. Lab 7 makes the CPU a usable stored-program
machine by adding PC-relative control flow, load/store instructions, memory,
and an assembler. This project uses that full progression rather than treating
Lab 6 as an isolated design.
