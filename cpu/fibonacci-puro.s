#
# Fibonacci para o subset de RISC-V implementado no trabalho final de CI1210.
# Versão não otimizada - comportamento exato do código em C
#
# O objetivo do programa é alocar um vetor de 40 inteiros de 32 bits na stack,
# então chamar uma função que coloque números de fibonacci nele. A assinatura
# da função de fibonacci é fib(int *v, int tam, int e1, int e2).
#
# Como a stack cresce para baixo, para facilitar, vamos escrever os números no
# vetor na direção contrária da stack, ou seja, do menor para o maior endereço.
#
# Quando esse programa for implementado para a cpu de um subset de RISC-V
# implementada no Digital, a seção .data será ignorada (o programa será
# somente uma sequência de instruções) e a syscall de exit do RARS será
# substituída pela instrução especial de halt. Além disso, o endereço do vetor
# será substituído pela posição 0 da memória.
#
# A implementação não utiliza pseudo-instruções do assembler do RARS
# para ser mais claramente transcrita manualmente para a sequência binária.
#
	.data
	.globl main

	.text
main:	addi sp, sp, -80	# aloca um vetor estático na stack

	add a0, sp, zero	# copia o endereço do vetor para ao
	addi a1, zero, 20	# copia o tamanho do vetor para a1
	addi a2, zero, 1	# copia os últimos argumentos
	addi a3, zero, 1
	jal ra, fib

	addi a7, zero, 93	# exit call com código 0
	addi a0, zero, 8
	ecall

# fib :: v (a0) -> tam (a1) -> e1 (a2) -> e2 (a3) -> ()
# i        -> t0
# v[i - 1] -> t1
# v[i - 2] -> t2
# &v[i]    -> t3
# t1 + t2  -> t4
fib:	sw a2, 0(a0)
	sw a3, 4(a0)

	addi t0, zero, 2	# i = 2
loop:	bge t0, a1, ret		# sai em i >= tam

	addi t1, t0, -1		# t1 = v[i - 1]
	slli t1, t1, 2
	add t1, t1, a0
	lw t1, 0(t1)

	addi t2, t0, -2		# t2 = v[i - 2]
	slli t2, t2, 2
	add t2, t2, a0
	lw t2, 0(t2)

	add t4, t1, t2		# t4 = v[i - 1] + v[i - 2]

	slli t3, t0, 2		# v[i] = t4
	add t3, t3, a0
	sw t4, 0(t3)

	addi t0, t0, 1		# i++
	jal zero, loop

ret: 	jalr zero, 0(ra)
