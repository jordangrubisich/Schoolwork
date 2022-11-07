
	.data
ARRAY_A:
	.word	21, 210, 49, 4
ARRAY_B:
	.word	21, -314159, 0x1000, 0x7fffffff, 3, 1, 4, 1, 5, 9, 2
ARRAY_Z:
	.space	28
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
		
	
	.text  
main:	
	la $a0, ARRAY_A
	addi $a1, $zero, 4
	jal dump_array
	
	la $a0, ARRAY_B
	addi $a1, $zero, 11
	jal dump_array
	
	la $a0, ARRAY_Z
	lw $t0, 0($a0)
	addi $t0, $t0, 1
	sw $t0, 0($a0)
	addi $a1, $zero, 9
	jal dump_array
		
	addi $v0, $zero, 10
	syscall

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	
dump_array:

	addi $sp, $sp, -28	#store all used registers on the stack
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $v0, 8($sp)
	sw $ra, 4($sp)


	add $s0, $zero, $a0 	#copy address of array into $s0
	add $s1, $zero, $a1 	#copy number of array elements into $s1 (loop counter)
	la $s2, SPACE 		#load address of space character into $s2
	
loop:
	lw $a0, ($s0)		#load value at address $s0 into $a0 (integer to be printed)
	addi $v0, $zero, 1	#add integer print syscall value into $v0
	syscall
	
	beq $s1, 1, fin		#if loop counter is 1, skip adding a space (last value has been printed)
	
	addi $s1,$s1, -1	#decrement loop counter
	addi $s0, $s0, 4	#move address to point to next array value
	la $a0, SPACE		#add space string address into $a0 (string to be printed)
	addi $v0, $zero, 4	#add string print syscall value into $v0
	syscall
	j loop
	
fin:				#all number in integer array have been printed, newline character must be added

	la $a0, NEWLINE		#add newline string address into $a0 (string to be printed)
	addi $v0, $zero, 4	#add string print syscall value into $v0
	syscall
	
	lw $a0, 28($sp)		#restore all register values saved to stack
	lw $a1, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s2, 12($sp)
	lw $v0, 8($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 28
	
	jr $ra			#procedure end
	
	
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
