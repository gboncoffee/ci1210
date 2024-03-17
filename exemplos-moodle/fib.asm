;;
;; Fibonacci - RISC-V 32 IM
;; Para ser executado no egg
;;
;; As funções de conversão de número/texto só funcionam para unsigned.
;;
	;; Inicializa a stack na última posição da memória.
	addi sp, zero, -1

	;; Diz para o usuário escrever um número de dois dígitos.
	addi a7, zero, 3
	addi a0, zero, msg
	addi a1, zero, 34
	ecall

	;; Faz a call para ler dois caracteres do teclado.
	addi a7, zero, 2
	addi a0, zero, buf
	addi a1, zero, 2
	ecall

	;; Chama 'ascii2num' para converter o texto lido em um numero.
	addi a0, zero, buf
	addi a1, zero, 2
	jal ra, ascii2num

	;; Chama 'fib'. O retorno de 'ascii2num' esta em a0, então não
	;; precisamos carregar ele.
	jal ra, fib

	;; Chama 'num2ascii' para converter o numero para texto ascii.
	addi a1, a0, 0
	addi a0, zero, buf
	jal ra, num2ascii

	;; Faz a call para escrever o número.
	addi a7, zero, 3
	addi a1, a0, 0
	addi a0, zero, buf
	ecall

	;; Para a execução do programa.
	ebreak

;; Recebe um número n em a0 e retorna o n-ésimo número da sequência de
;; Fibonacci, também em a0.
;;
;; t0 - n-ésimo número da sequência
;; t1 - termo anterior
;; t2 - tmp
;; t3 - iterador
fib:
	;; Retorna 0 imediatamente se o argumento for 0.
	addi t0, zero, 0
	beq a0, zero, fib_ret

	;; Retorna 1 imediatamente se o argumento for < 3.
	addi t0, zero, 1
	addi t2, zero, 3
	blt a0, t2, fib_ret

	addi t1, zero, 1
	addi t3, zero, 2
fib_loop:
	beq t3, a0, fib_ret
	add t2, t0, t1
	addi t1, t0, 0
	addi t0, t2, 0

	;; Atualiza iterador
	addi t3, t3, 1
	jal zero, fib_loop

fib_ret:
	addi a0, t0, 0
	jalr zero, ra, 0

;; Essa função converte texto em número. Ela recebe um buffer em a0 com o texto
;; e um inteiro em a1 com o tamanho do texto. Retorna o número em a0.
;;
;; t0 - iterador (para quando = a1)
;; t1 - número acumulado
;; t2 - endereço lido (aumenta de 1 em 1)
;; t3 - salva o valor lido da memória
;; t4 - constante 10 (para multiplicar)
ascii2num:
	addi t0, zero, 0
	addi t1, zero, 0
	addi t2, a0, 0
	addi t4, zero, 10

ascii2num_loop:
	beq t0, a1, ascii2num_ret
	lb t3, t2, 0
	;; Mágica com ascii
	addi t3, t3, -0x30
	mul t1, t1, t4
	add t1, t1, t3

	;; atualiza váriaveis
	addi t2, t2, 1
	addi t0, t0, 1
	jal zero, ascii2num_loop

ascii2num_ret:
	addi a0, t1, 0
	jalr zero, ra, 0

;; Essa função converte um número em texto. Ela recebe um buffer em a0 para onde
;; escrever, e o número para ser convertido em a1. Retorna o tamanho do texto em
;; a0.
;;
;; t0 - numero durante conversão (o loop para quando t0 = 0)
;; t1 - tamanho do texto (acumulador)
;; t2 - caracter convertido
;; t3 - endereço de escrita
;; t4 - constante 10 (para operações de módulo)
num2ascii:
	addi t0, a1, 0
	addi t1, zero, 0
	addi t3, a0, 0
	addi t4, zero, 10

	;; Caso o número seja 0, escreve 0 e retorna imediatamente.
	bne a1, zero, num2ascii_loop
	addi t2, zero, 0x30
	sb t3, t2, 0
	addi a0, zero, 1
	jalr zero, ra, 0

num2ascii_loop:
	beq t0, zero, num2ascii_ret
	remu t2, t0, t4
	;; Mágica com ascii
	addi t2, t2, 0x30
	sw t3, t2, 0
	
	;; Atualiza váriaveis
	divu t0, t0, t4
	addi t3, t3, 1
	addi t1, t1, 1
	jal zero, num2ascii_loop

num2ascii_ret:
	;; O número foi escrito ao contrário na memória, agora invertemos ele
	;; novamente com a função reverte_vetor. Precisamos salvar o valor de t1
	;; na stack pois será retornado. O endereço do buffer já está em a0,
	;; passamos o tamanho em a1. Também precisamos salvar o ra.
	addi sp, sp, -8
	sw sp, t1, 4
	sw sp, ra, 0

	addi a1, t1, 0
	jal ra, reverte_vetor

	;; Recupera os valores salvos na stack e retorna.
	lw a0, sp, 4
	lw ra, sp, 0
	addi sp, sp, 8
	jalr zero, ra, 0

;; Essa função recebe um buffer em a0 e um tamanho em a1. Ela inverte os bytes
;; na memória. I.e., o vetor [1, 2, 3] vira [3, 2, 1].
;;
;; t0 - indíce do início
;; t1 - indíce do final
;; t2 - valor do início
;; t3 - valor do final
reverte_vetor:
	addi t0, a0, 0
	add t1, a0, a1
	addi t1, t1, -1

rev_loop:
	bge t0, t1, rev_ret
	lb t2, t0, 0
	lb t3, t1, 0
	sb t0, t3, 0
	sb t1, t2, 0
	addi t0, t0, 1
	addi t1, t1, -1
	jal zero, rev_loop

rev_ret:
	jalr zero, ra, 0

msg:
#Insira um numero de dois digitos: 

;; buf aponta para o fim do código, ou seja, região da memória que podemos usar
;; a vontade
buf:
