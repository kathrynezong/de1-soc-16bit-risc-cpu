# CPU UVM verification

This directory contains the UVM 1.2 verification environment for the CPU.

Current status:

- UVM package compiles from the library bundled with Intel FPGA Lite 18.1
- `cpu_smoke_test` runs through UVM phasing
- The test finishes with zero UVM errors and zero UVM fatals
- DPI is disabled because the Starter Edition does not provide the required
  UVM DPI library

Run the smoke test from the repository root:

```powershell
./scripts/run-uvm-tests.ps1
```

## Simulator limitation

ModelSim Intel FPGA Starter Edition supports enough UVM functionality for
components, phasing, analysis ports, and deterministic transactions. Its
compiler reports that constrained randomization, functional coverage, and
assertions are Questa-only features in this edition. Use Questa for the full
planned constrained-random and coverage environment.

## Next milestone

Create `interfaces/cpu_memory_if.sv`, connect it to a direct CPU instance in
`uvm_top.sv`, and place the virtual interface in `uvm_config_db`. The following
milestone will add a deterministic memory driver and passive monitor.
