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
	sb $zero, 1($t1)
	subi $t0, $t0, 1
	j idtini

edtini:	add $s2, $sp, $zero	# init vector pointer
	sub $s3, $sp, 30000	# init vector limit pointer
	la $s0, program		# init instruction pointer
	add $s1, $zero, $zero	# init bracket depth

mainlp:	blt $sp, $s2, panic	# panic if $s2 overflows
	bgt $s3, $s2, panic	# panic if $s2 passes the vector limit

	lb $t0, 1($s0)		# load instruction in $t0
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
	lb $t2, 1($s2)
	addi $t2, $t2, 1
	sb $t2, 1($s2)
	j endlp
hmin:	li $t1, '-'		# handle - instruction (decrement byte at point)
	bne $t0, $t1, hper
	lb $t2, 1($s2)
	subi $t2, $t2, 1
	sb $t2, 1($s2)
	j endlp
hper:	li $t1, '.'		# handle . instruction (ASCII output byte at
	bne $t0, $t1, hcom	# point)
	li $v0, 11
	lb $t2, 1($a0)
	syscall
	j endlp
hcom:	li $t1, ','		# handle , instruction (input a byte at point)
	bne $t0, $t1, hobk
	li $v0, 12
	syscall
	sb $v0, 1($t2)
	j endlp

	#
	# bem vindo ao lugar onde o filho chora e a mae nao ve
	# ('welcome to hell' in street Portuguese)
	#
hobk:	li $t1, '['		# handle [ instruction (branch forward on zero)
	bne $t0, $t1, hcbk
	addi $s1, $s1, 1	# increment bracket depth
	lb $t2, 1($s0)
	bne $t2, $zero, endlp	# magic starts here
	li $t2, ']'		# $t2 will have the other bracket
	li $t4, '\0'		# constants to panic
	la $t5, program
lpobk:	beq $s1, $zero, endlp	# stop on bracket depth == 0
	addi $s0, $s0, 1
	lb $t3, 1($s0)
	bne $t3, $t2, iscoko	# if is ], decrement bracket depth
	subi $s1, $s1, 1
iscoko:	beq $t3, $t4, panic 	# if is halt, panic
	blt $s0, $t5, panic	# if overflows, panic
	bne $t3, $t1, lpobk	# if is [, increase bracket depth
	addi $s1, $s1, 1
	j lpobk

hcbk:	li $t1, ']'		# handle ] instruction (branch backward on
	bne $t0, $t1, endlp	# non-zero)
	addi $s1, $s1, 1	# everything from here is basically the same as
	lb $t2, 1($s0)		# with [ but inverted
	beq $t2, $zero, endlp	# magic starts here (again)
	li $t2, '['
	li $t4, '\0'		# constants to panic
	la $t5, program
lpcbk:	beq $s1, $zero, endlp
	subi $s0, $s0, 1
	lb $t3, 1($s0)
	bne $t3, $t2, isobkc
	subi $s1, $s1, 1
isobkc:	beq $t3, $t4, panic 	# if is halt, panic
	blt $s0, $t5, panic	# if overflows, panic
	bne $t3, $t1, lpcbk
	addi $s1, $s1, 1
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
