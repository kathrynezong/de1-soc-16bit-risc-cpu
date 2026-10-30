# Unit-test checklist

Add these testbenches during Phase 1:

- `alu_tb.sv`: ADD, subtraction/CMP, AND, MVN, Z/N/V and overflow boundaries
- `shifter_tb.sv`: no shift, LSL, LSR and ASR with positive/negative values
- `regfile_tb.sv`: reset, every register, read-after-write and disabled writes
- `cpu_instruction_tb.sv`: one self-checking case for every instruction

Keep reusable instruction encodings or helper tasks in this directory rather
than duplicating them across integration tests.
