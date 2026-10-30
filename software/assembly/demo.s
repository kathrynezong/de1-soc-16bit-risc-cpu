; Load 0xABCD from address 5, store it at address 6, then halt.
MOV R0, #5
LDR R1, [R0]
MOV R2, #6
STR R1, [R2]
HALT
.word 0xABCD
.word 0
