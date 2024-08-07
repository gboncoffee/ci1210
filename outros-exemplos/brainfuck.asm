;;
;; Brainfuck for RISC-V 32 IM
;; (to run on EGG, https://github.com/gboncoffee/egg)
;;
;; This is a non-optimized version. It follows all the conventions even where
;; we do know how to make it faster. A great exercise is to optimize this code.
;; I know it's possible to create such a machine without using the memory at
;; all, for example - because I already did!
;;
;; Optimizing by ditching code conventions shows how hand-written Assembly still
;; has it's place in the industry in 2024. A great example of real-world usage
;; of optimized hand-written Assembly code is FFmpeg (https://ffmpeg.org/).
;;
;; Have fun and don't forget the Joy of Computing!
;;
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

	;; Ensures the program buffer is zeroed.
	addi t0, zero, program
	addi t1, t0, 1024
ensure_zero_loop:
	blt t1, t0, read_program
	sb t0, zero, 0
	addi t0, t0, 1
	jal zero, ensure_zero_loop

read_program:
	;; Reads the program.
	addi a7, zero, 2
	addi a0, zero, program
	addi a1, zero, 1024
	ecall

	;; Inits the machine.
	jal ra, brainfuck

	;; Compares the return. If no branch taken, it'll jump directly to
	;; exit_program.
	addi t0, zero, 1
	beq t0, a0, panic_jmp_mismatch_up
	addi t0, t0, 1
	beq t0, a0, panic_jmp_mismatch_down
	addi t0, t0, 1
	beq t0, a0, panic_stack_overflow_down
	addi t0, t0, 1
	beq t0, a0, panic_stack_overflow_up
	addi t0, t0, 1
	beq t0, a0, panic_unknown_instruction

	jal zero, exit_program

panic_jmp_mismatch_up:
	addi a0, zero, panic_jmp_mismatch_up_msg
	addi a1, zero, 28
	jal zero, panic
panic_jmp_mismatch_down:
	addi a0, zero, panic_jmp_mismatch_down_msg
	addi a1, zero, 28
	jal zero, panic
panic_stack_overflow_up:
	addi a0, zero, panic_stack_overflow_up_msg
	addi a1, zero, 25
	jal zero, panic
panic_stack_overflow_down:
	addi a0, zero, panic_stack_overflow_down_msg
	addi a1, zero, 27
	jal zero, panic
panic_unknown_instruction
	addi a0, zero, panic_unknown_instruction_msg
	addi a1, zero, 27

panic:
	addi a7, zero, 3
	ecall
exit_program:
	ebreak

;; Returns:
;; - 0 if success (step in 0).
;; - 1 if [] mismatch up.
;; - 2 if [] mistmatch down.
;; - 3 if stack overflow down.
;; - 4 if stack overflow up (reaches the program stack).
;; - 5 if unknown instruction.
;; s0 = PC
;; s1 = DP
;; s2 = constant with the start program address.
;; s3 = constant with the bottom of the stack.
;;
;; stack:
;; [ra, s0, s1, s2, s3]
brainfuck:
	;; Alloc stack and save everything.
	addi sp, sp, -20	; 5 * 4
	sw sp, ra, 16
	sw sp, s0, 12
	sw sp, s1, 8
	sw sp, s2, 4
	sw sp, s3, 0

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
	beq t0, zero, brainfuck_clean_ret
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
	;; Check if [ (0x5b)
	addi t1, zero, 0x5b
	beq t0, t1, brainfuck_pc_left_call
	;; Check if ] (0x5d)
	addi t1, zero, 0x5d
	beq t0, t1, brainfuck_pc_right_call

	;; Unknown instruction reached.
	addi a0, zero, 5
	jal zero, brainfuck_ret

brainfuck_dp_left:
	addi s1, s1, 1
	bge s1, sp, brainfuck_dp_left_error
	jal zero, brainfuck_clean_loop

brainfuck_dp_right:
	addi s1, s1, -1
	blt s1, s3, brainfuck_dp_right_error
	jal zero, brainfuck_clean_loop

brainfuck_inc:
	lb t0, s1, 0
	addi t0, t0, 1
	sb s1, t0, 0
	jal zero, brainfuck_clean_loop

brainfuck_dec:
	lb t0, s1, 0
	addi t0, t0, -1
	sb s1, t0, 0
	jal zero, brainfuck_clean_loop

brainfuck_out:
	addi a7, zero, 3
	addi a0, s1, 0
	addi a1, zero, 1
	ecall
	jal zero, brainfuck_clean_loop

brainfuck_in:
	addi a7, zero, 2
	addi a0, s1, 0
	addi a1, zero, 1
	ecall
	jal zero, brainfuck_clean_loop

brainfuck_pc_left_call:
	;; If the byte at the current cell is NONZERO, DON'T jump.
	lb t0, s1, 0
	bne t0, zero, brainfuck_clean_loop
	;; Else perform the jump via the brainfuck_pc_left function.
	addi a0, s0, 0
	addi a1, s2, 0
	addi a2, zero, 0
	jal ra, brainfuck_pc_left
	;; Update PC and loop if no error, else returns.
	addi s0, a1, 0
	beq a0, zero, brainfuck_main_loop
	addi a0, zero, 2
	jal zero, brainfuck_ret

brainfuck_pc_right_call:
	;; If the byte at the current cell is ZERO, DON'T jump.
	lb t0, s1, 0
	beq t0, zero, brainfuck_clean_loop
	;; Else perform the jump via the brainfuck_pc_right function.
	addi a0, s0, 0
	addi a1, zero, 0
	jal ra, brainfuck_pc_right
	;; Update PC and loop if no error, else returns.
	addi s0, a1, 0
	beq a0, zero, brainfuck_main_loop
	addi a0, zero, 1
	jal zero, brainfuck_ret

brainfuck_clean_loop:
	addi s0, s0, 1
	jal zero, brainfuck_main_loop

brainfuck_dp_right_error:
	addi a0, zero, 3
	jal zero, brainfuck_ret
brainfuck_dp_left_error:
	addi a0, zero, 4
	jal zero, brainfuck_ret
brainfuck_clean_ret:
	addi a0, zero, 0
brainfuck_ret:
	lw ra, sp, 16
	lw s0, sp, 12
	lw s1, sp, 8
	lw s2, sp, 4
	lw s3, sp, 0
	addi sp, sp, 20
	jalr zero, ra, 0

;; Receives:
;; a0 <- pc
;; a1 <- program base
;; a2 <- current bracket depth
;; Returns:
;; - 0 if success
;; - 1 if mismatch (down)
;; - The new PC in a1
brainfuck_pc_left:
	addi a0, a0, -1
	;; If smashing the program base, returns error.
	blt a0, a1, brainfuck_pc_left_error
	;; If a2 is -1, we reached the point, so returns.
	addi t0, zero, -1
	beq a2, t0, brainfuck_pc_left_clean_ret
	;; Compares the instruction byte.
	lb t0, a0, 0
	;; If ] (0x5d).
	addi t1, zero, 0x5d
	beq t0, t1, brainfuck_pc_left_dec_recurse
	;; If [ (0x5b).
	addi t1, zero, 0x5b
	beq t0, t1, brainfuck_pc_left_inc_recurse
	;; Else, just recurses.
	jal zero, brainfuck_pc_left
brainfuck_pc_left_dec_recurse:
	addi a2, a2, -1
	jal zero, brainfuck_pc_left
brainfuck_pc_left_inc_recurse:
	addi a2, a2, 1
	jal zero, brainfuck_pc_left
brainfuck_pc_left_error:
	addi a0, zero, 1
	jalr zero, ra, 0
brainfuck_pc_left_clean_ret:
	addi a1, a0, 0
	addi a0, zero, 0
	jalr zero, ra, 0

;; Receives:
;; a0 <- pc
;; a1 <- current bracket depth
;; Returns:
;; - 0 if success
;; - 1 if mismatch (up)
;; - The new PC in a1
brainfuck_pc_right:
	addi a0, a0, 1
	addi t0, zero, -1
	;; If a1 is -1, we reached the point, so returns.
	beq a1, t0, brainfuck_pc_right_clean_ret
	;; Compares the instruction byte.
	lb t0, a0, 0
	;; If [ (0x5b).
	addi t1, zero, 0x5b
	beq t0, t1, brainfuck_pc_right_dec_recurse
	;; If ] (0x5d).
	addi t1, zero, 0x5d
	beq t0, t1, brainfuck_pc_right_inc_recurse
	;; If 0, we're smashing the program limit.
	beq t0, zero, brainfuck_pc_right_error
	;; Else, just recurses.
	jal zero, brainfuck_pc_right
brainfuck_pc_right_dec_recurse:
	addi a1, a1, -1
	jal zero, brainfuck_pc_right
brainfuck_pc_right_inc_recurse:
	addi a1, a1, 1
	jal zero, brainfuck_pc_right
brainfuck_pc_right_error:
	addi a0, a0, 1
	jalr zero, ra, 0
brainfuck_pc_right_clean_ret:
	addi a1, a0, 0
	addi a0, zero, 0
	jalr zero, ra, 0

panic_jmp_mismatch_up_msg: #ERROR: [ without matching ]%0a
panic_jmp_mismatch_down_msg: #ERROR: ] without matching [%0a
panic_stack_overflow_up_msg: #ERROR: stack overflow up%0a
panic_stack_overflow_down_msg: #ERROR: stack overflow down%0a
panic_unknown_instruction_msg: #ERROR: unknown instruction%0a

program:
