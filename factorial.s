	.data
	.globl main

	.text
main:	li $a0, 5	# call to fact with 5
	jal fact

	add $a0, $v0, $zero	# integer print syscall with the return from
	li $v0, 1		# fact
	syscall

	li $v0, 10	# exit syscall
	syscall

fact:	li $v0, 1 	# init acumulator with 1
	li $t1, 1	# end loop when $a0 < 1
inil:	blt $a0, $t1, endl
	mul $v0, $a0, $v0
	subi $a0, $a0, 1
	j inil
endl:	jr $ra
