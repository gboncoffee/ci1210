;; Brainfuck for RISC-V 32 IM
;; (to run on EGG)
;;
;; Copyright (C) 2024  Gabriel de Brito
;; 
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;; 
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.
;; 

	addi sp, zero, 0

	;; Reads the program.
	addi a7, zero, 2
	addi a0, zero, program
	addi a1, zero, 1024
	ecall

	;; Inits the machine.
	jal ra, brainfuck

	;; Compares the return.
	addi t0, zero, 1
	bne t0, 

	ebreak

;; Returns:
;; - 0 if success (step in 0).
;; - 1 if [] mismatch up.
;; - 2 if [] mistmatch down.
;; - 3 if stack overflow down.
;; - 4 if stack overflow up (reaches the program stack).
;; s0 = PC
;; s1 = DP
;; s2 = constant with the start program address.
;; s3 = constant with the bottom of the stack.
brainfuck:
	addi s0, zero, program
	addi s2, s0, 0

	;; Brainfuck stack goes right after the program and grows upwards.
	addi s1, zero, program
	addi s1, s1, 1
	addi s3, s1, 0

	;; Main machine loop.
brainfuck_main_loop:
	lb t0, s0, 0
	
	;; Check if 0 (quit).
	beq t0, zero, brainfuck_ret
	;; Check if < (0x3c)
	addi t1, zero, 0x3c
	beq t0, t1, brainfuck_dp_left
	;; Check if > (0x3e)
	addi t1, zero, 0x3e
	beq t0, t1, brainfuck_dp_right
	;; Check if + (0x2b)
	addi t1, zero, 0x2b
	beq t0, t1, brainfuck_inc
	;; Check if - (0x2d)
	addi t1, zero, 0x2d
	beq t0, t1, brainfuck_dec
	;; Check if . (0x2e)
	addi t1, zero, 0x2e
	beq t0, t1, brainfuck_out
	;; Check if , (0x2c)
	addi t1, zero, 0x2c
	beq t0, t1, brainfuck_in

brainfuck_dp_left:
	addi s1, s1, 1
	bge s1, sp, brainfuck_dp_left_ret
	addi s0, s0, 1
	jal zero, brainfuck_main_loop
brainfuck_dp_left_ret:
	addi a0, zero, 4
	jalr zero, ra, 0

brainfuck_dp_right:
	addi s1, s1, -1
	blt s1, s3, brainfuck_dp_right_ret
	addi s0, s0, 1
	jal zero, brainfuck_main_loop
brainfuck_dp_right_ret:
	addi a0, zero, 3
	jalr zero, ra, 0

brainfuck_inc:
	lb t0, s1, 0
	addi t0, t0, 1
	sb s1, t0, 0
	addi s0, s0, 1
	jal zero, brainfuck_main_loop

brainfuck_dec:
	lb t0, s1, 0
	addi t0, t0, -1
	sb s1, t0, 0
	addi s0, s0, 1
	jal zero, brainfuck_main_loop

brainfuck_out:
	addi a7, zero, 3
	addi a0, s1, 0
	addi a1, zero, 1
	ecall
	jal zero, brainfuck_main_loop

brainfuck_in:
	addi a7, zero, 2
	addi a0, s1, 0
	addi a1, zero, 1
	ecall
	jal zero, brainfuck_main_loop

brainfuck_ret:
	addi a0, zero, 0
	jalr zero, ra, 0

program:
