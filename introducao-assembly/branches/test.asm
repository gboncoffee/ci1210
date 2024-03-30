	addi t0, zero, 0
	addi t2, zero, 3
for:
	bge t0, t2, fora_for
	addi t0, t0, 1
	jal zero, for
fora_for:
	ebreak
