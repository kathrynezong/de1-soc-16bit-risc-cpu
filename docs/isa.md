# Instruction-set reference

The encoding matches the `sas` assembler supplied with Lab 7.

| Group | Instructions | Effect |
|---|---|---|
| Data movement | `MOV` | Immediate or shifted-register move |
| Arithmetic | `ADD`, `CMP` | Addition and flag-setting comparison |
| Logic | `AND`, `MVN` | Bitwise AND and inverted move |
| Memory | `LDR`, `STR` | Load/store with signed 5-bit displacement |
| Branch | `B`, `BEQ`, `BNE`, `BLT`, `BLE` | PC-relative control flow |
| Function | `BL`, `BX`, `BLX` | Link and register-indirect control flow |
| Control | `NOP`, `HALT` | No operation and processor halt |

Shifted register operands support no shift, `LSL #1`, `LSR #1`, and `ASR #1`.
`CMP` updates `Z`, `N`, and `V`; conditional branches consume those flags.

During Phase 1, expand this document with the exact 16-bit field diagrams and
one binary-encoding example for every instruction format.
