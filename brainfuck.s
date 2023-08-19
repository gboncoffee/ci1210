	# brainfuck interpreter in MIPS Assembly
	# $s0 is the instruction pointer
	# $s1 is the bracket depth
	# $s2 is the data pointer
	# $s3 is the data limit pointer
	# stack grows to the bottom so <> are inverted

	.data
program:	.asciiz "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
panicmsg:	.asciiz "machine panic"

	.text
main:	addi $t0, $zero, 30000	# init vector of 30000 bytes with 0s
idtini:	blt $t0, $zero, edtini
	sub $t1, $sp, $t0
	sb $zero, 0($t1)
	subi $t0, $t0, 1
	j idtini

edtini:	add $s2, $sp, $zero	# init vector pointer
	sub $s3, $sp, 30000	# init vector limit pointer
	la $s0, program		# init instruction pointer
	add $s1, $zero, $zero	# init bracket depth

mainlp:	blt $sp, $s2, panic	# panic if $s2 overflows
	bgt $s3, $s2, panic	# panic if $s2 passes the vector limit

	lbu $t0, 0($s0)		# load instruction in $t0
	li $t1, '\0'		# stop if it is the halt pseudo-instruction '\0'
	beq $t0, $t1, halt

	li $t1, '>'		# handle > instruction (increment vector
	bne $t0, $t1, hgti	# pointer)
	subi $s2, $s2, 1
	j endlp
hgti:	li $t1, '<'		# handle < instruction (decrement vector
	bne $t0, $t1, hpls	# pointer)
	addi $s2, $s2, 1
	j endlp
hpls:	li $t1, '+'		# handle + instruction (increment byte at point)
	bne $t0, $t1, hmin
	lbu $t2, 0($s2)
	addi $t2, $t2, 1
	sb $t2, 0($s2)
	j endlp
hmin:	li $t1, '-'		# handle - instruction (decrement byte at point)
	bne $t0, $t1, hper
	lbu $t2, 0($s2)
	subi $t2, $t2, 1
	sb $t2, 0($s2)
	j endlp
hper:	li $t1, '.'		# handle . instruction (ASCII output byte at
	bne $t0, $t1, hcom	# point)
	li $v0, 11
	lbu $a0, 0($s2)
	syscall
	j endlp
hcom:	li $t1, ','		# handle , instruction (input a byte at point)
	bne $t0, $t1, hobk
	li $v0, 12
	syscall
	sb $v0, 0($s2)
	j endlp

	#
	# bem vindo ao lugar onde o filho chora e a mae nao ve
	# ('welcome to hell' in street Portuguese)
	#
hobk:	li $t1, '['		# handle [ instruction (branch forward on zero)
	bne $t0, $t1, hcbk
	lbu $t2, 0($s2)		# condition
	bne $t2, $zero, endlp
	li $t2, ']'		# load constants
	li $t4, '\0'
lpobk:	lbu $t3, 0($s0)
	bne $t3, $t1, isocbk	# handle new [
	addi $s1, $s1, 1
isocbk:	bne $t3, $t2, zeroo
	subi $s1, $s1, 1
zeroo:	beq $s1, $zero, endlp
	beq $t3, $t4, panic 	# only needs to test the halt panic here
	addi $s0, $s0, 1
	j lpobk

hcbk:	li $t1, ']'		# handle ] instruction (branch backward on
	bne $t0, $t1, endlp	# non-zero)
	lbu $t2, 0($s2)		# condition
	beq $t2, $zero, endlp
	li $t2, '['		# load constants
	li $t4, '\0'
lpcbk:	lbu $t3, 0($s0)
	bne $t3, $t1, iscobk	# handle new ]
	addi $s1, $s1, 1
iscobk:	bne $t3, $t2, zeroc
	subi $s1, $s1, 1
zeroc:	beq $s1, $zero, endlp
	addi $t5, $s0, 0	# only needs to test underflow here
	subi $s0, $s0, 1
	la $t6, program
	blt $s0, $t6, panic	# access memory before program starts
	blt $t5, $s0, panic	# true integer underflow
	j lpcbk

endlp:	addi $s0, $s0, 1	# increment instruction pointer and loop
	j mainlp

halt:	li $v0, 10
	syscall

panic:	li $v0, 4
	la $a0, panicmsg
	syscall
	li $v0, 17
	li $a0, 1
	syscall
