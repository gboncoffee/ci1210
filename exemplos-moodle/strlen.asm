	addi sp, zero, 0

	;; Lê input.
	addi a7, zero, 2
	addi a0, zero, buffer
	addi a1, zero, 1024
	ecall

	;; Vê o tamanho real do input.
	addi s0, a0, 0
	jal ra, strlen
	addi a1, a0, 0
	addi a0, s0, 0

	;; Escreve de novo na tela.
	addi a7, zero, 3
	ecall

	ebreak

strlen:
	addi t0, zero, 0
strlen_loop:
	lb t1, a0, 0
	beq t1, zero, strlen_ret
	addi t0, t0, 1
	addi a0, a0, 1
	jal zero, strlen_loop
strlen_ret:
	addi a0, t0, 0
	jalr zero, ra, 0

buffer:
