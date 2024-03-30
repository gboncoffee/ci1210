; Fatorial recursivo.

	addi sp, zero, -1
	addi a0, zero, 3
	jal ra, fatorial
	ebreak

; int fatorial(int n)	
fatorial:
	bne a0, zero, else
	addi a0, zero, 1
	jalr zero, ra, 0
else:
	addi sp, sp, -8
	sw sp, a0, 4
	sw sp, ra, 0

	addi a0, a0, -1
	jal ra, fatorial

	addi sp, sp, 8
	lw ra, sp, -8
	lw t0, sp, -4

	mul a0, a0, t0
	jalr zero, ra, 0
