; Count R1 from zero to three using a backwards conditional branch.
MOV R0, #3
MOV R1, #0
MOV R2, #1
loop:
ADD R1, R1, R2
CMP R1, R0
BLT loop
HALT
