#
# Fibonacci para o subset de RISC-V implementado no trabalho final de CI1210.
# Versão real - Otimizada e para rodar na CPU simulada
#
# O objetivo do programa é alocar um vetor de 40 inteiros de 32 bits no endereço
# 0, então chamar uma função que coloque números de fibonacci nele. A assinatura
# da função de fibonacci é fib(int *v, int tam, int e1, int e2).
#
# Para facilitar a verificação, após a chamada da função, o programa carrega os
# números do vetor um a um para um registrador.
#
# Esse código tem somente texto, não usa pseudo-instruções e utiliza a instrução
# especial "halt", implementada como o opcode 0b0000000.
#
	.text
	add a0, zero, zero	# copia o endereço do vetor (0) para ao
	addi a1, zero, 20	# copia o tamanho do vetor para a1
	addi a2, zero, 1	# copia os últimos argumentos
	addi a3, zero, 1
	jal ra, fib

	addi t0, zero, 80	# salva o endereço logo após o final do vetor
	add t1, zero, zero	# começa loop no endereço zero
print:	beq t1, t0, exit
	lw t2, 0(t1)	# load e store para debuggar o vetor
	sw t2, 0(t1)
	addi t1, t1, 1
	jal zero, print

exit:	halt

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
