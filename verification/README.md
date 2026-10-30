# Verification

Keep tests separate from synthesizable RTL.

- `unit/`: focused tests for one module, such as the ALU, shifter, register
  file, or instruction behavior.
- `integration/`: tests that run complete programs through the CPU and memory.
- `cpu_uvm/`: reusable UVM environment, tests, scoreboard, and coverage.

Each testbench should be self-checking: report a failure with `$fatal` and end
with a clear `PASS` message. Phase 1 should add unit tests for every ALU and
shift operation, followed by instruction-level tests for every opcode.

Run the UVM smoke test from the repository root with:

```powershell
./scripts/run-uvm-tests.ps1
```
