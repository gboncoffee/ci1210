add a0 zero zero
addi a1 zero 20
addi a2 zero 1
addi a3 zero 1
jal ra fib
addi t0 zero 80
add t1 zero zero
print: beq t1 t0 exit
lw t2 t1 0
sw t2 t1 0
addi t1 t1 1
jal zero print
exit: halt
fib: sw a2 a0 0
sw a3 a0 4
addi a0 a0 8
slli t0 a1 2
add t0 t0 a0
loop: blt t0 a0 ret
add t1 a2 a3
sw t1 a0 0
add a2 a3 zero
add a3 t1 zero
addi a0 a0 4
jal zero loop
ret: jalr zero ra 0
