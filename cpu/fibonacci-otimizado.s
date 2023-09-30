#
# Fibonacci para o subset de RISC-V implementado no trabalho final de CI1210.
# Versão otimizada - comportamento difere do código em C
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
fib:	sw a2, 0(a0)		# na função operamos com as variáveis em ax
	sw a3, 4(a0)		# pois não há chamada de outras funções
	addi a0, a0, 8

	slli t0, a1, 2	# multiplica o tamanho do vetor por 4
	add t0, t0, a0	# salva o endereço final do vetor em t0

loop:	blt t0, a0, ret	# sai se passar do fim do vetor
	add t1, a2, a3	# aproveita ax como cache
	sw t1, 0(a0)		# v[i] = v[i - 1] + v[i - 2]
	add a2, a3, zero
	add a3, t1, zero
	addi a0, a0, 4	# aumenta o endereço em uma palavra
	jal zero, loop

ret: 	jalr zero, 0(ra)
