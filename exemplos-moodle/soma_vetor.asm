;;
;; Soma vetor - RISC-V 32 IM
;; Para ser executado no egg
;; Veja no debugger a execução do programa
;;

;; t0 = endereço
;; t1 = tamanho
;; t2 = iterador
;; t3 = resultado
;; t4 = valor da memória
;; t5 = endereço atual

	addi t0, zero, vetor
	addi t3, zero, 0

;; for (i = 0; i < 5; i++)
	addi t1, zero, 5
	addi t2, zero, 0
for:
	bge t2, t1, fora_for
	;; t4 = t0[t2]
	slli t5, t2, 2
	add t5, t5, t0
	lw t4, t5, 0
	;; t3 += t4
	add t3, t3, t4

	;; i++
	addi t2, t2, 1
	jal zero, for
fora_for:
	ebreak

vetor:
#%01%00%00%00
#%02%00%00%00
#%03%00%00%00
#%04%00%00%00
#%05%00%00%00
