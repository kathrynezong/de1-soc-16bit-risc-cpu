# CPU UVM environment

This directory will contain the reusable verification environment:

- `memory_agent/`: active memory driver plus passive bus monitor
- `cpu_scoreboard/`: architectural-state prediction and comparisons
- `cpu_coverage/`: instruction, flag, register, and branch coverage

The smoke test intentionally does not instantiate these components yet. Its
only purpose is to prove that UVM compiles and runs in the selected simulator.
