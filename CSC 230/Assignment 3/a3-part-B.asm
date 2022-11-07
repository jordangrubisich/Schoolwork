	.data
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
KEYBOARD_COUNTS:
	.space  128
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
	
	
	.eqv 	LETTER_a 97
	.eqv	LETTER_b 98
	.eqv	LETTER_c 99
	.eqv 	LETTER_D 100
	.eqv 	LETTER_space 32
	
	
	.text  
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

# below code adapted from lab08-A-solution.asm
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


	la $s0, 0xffff0000 # load address for MMIO Simulator receiver
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02 #enable keyboard interrupts
	sb $s1, 0($s0)
	
	
check_for_event:
	la $s0, KEYBOARD_EVENT_PENDING #loop infinitely 
	lw $s1, 0($s0) 			# checking for keyboard event pending 
	beq $s1, $zero, check_for_event #if no event pending continue looping, if event pending exit loop to handle event
	
	lw $s1, KEYBOARD_EVENT		#load the value of the key pressed
	beq $s1, 32, print_output	#if that key press was a space, branch to print_output
	
	beq $s1, 97, is_a		#branch to corresponding instructions if keypress was a,b,c or d
	beq $s1, 98, is_b
	beq $s1, 99, is_c
	beq $s1, 100, is_d
	
	beq $zero, $zero, done_processing #if key pressed was not any of a,b,c,d or space, branch to done_processing
	
is_a:
	la $s2, KEYBOARD_COUNTS 	# load address of keyboard counts into $s2
	lw $s3, ($s2)			# load 'a' count into $s3
	addi $s3, $s3, 1		# increment 'a' count
	sw $s3, ($s2)			# store new count back into memory
	
	beq $zero, $zero, done_processing #branch to done_processing
	
is_b:
	la $s2, KEYBOARD_COUNTS 	# load address of keyboard counts into $s2
	lw $s3, 4($s2)			# load 'b' count into $s3
	addi $s3, $s3, 1		# increment 'b' count
	sw $s3, 4($s2)			# store new count back into memory
	
	beq $zero, $zero, done_processing #branch to done_processing

is_c:
	la $s2, KEYBOARD_COUNTS 	# load address of keyboard counts into $s2
	lw $s3, 8($s2)			# load 'c' count into $s3
	addi $s3, $s3, 1		# increment 'c' count
	sw $s3, 8($s2)			# store new count back into memory
	
	beq $zero, $zero, done_processing #branch to done_processing
	
is_d:
	la $s2, KEYBOARD_COUNTS 	# load address of keyboard counts into $s2
	lw $s3, 12($s2)			# load 'd' count into $s3
	addi $s3, $s3, 1		# increment 'd' count
	sw $s3, 12($s2)			# store new count back into memory
	
	beq $zero, $zero, done_processing #branch to done_processing

done_processing:
	la $s0, KEYBOARD_EVENT_PENDING #retrieve address of keyboard event pending from memory
	sw $zero, ($s0)			#set value to zero
	beq $zero, $zero, check_for_event #return to infinite loop
	

print_output:
	la $t0, KEYBOARD_COUNTS #load address of keyboard counts into $t0
	lw $a0, ($t0)		 #load value of 'a' count into $a0
	addi $v0, $zero, 1	 #set v0 to 1 (integer print) 
	syscall			 #print 'a' count stored in $a0
	
	la $a0, SPACE		# load address of space string into $a0
	addi $v0, $zero, 4	# set $v0 to 4 (string print)
	syscall			# print space string
	
	la $t0, KEYBOARD_COUNTS #load address of keyboard counts into $t0
	addi $t0, $t0, 4	 # increment $t0 to point at 'b' count
	lw $a0, ($t0)		 # load 'b' count into $a0
	addi $v0, $zero, 1	 # set $v0 to 1
	syscall			 # print 'b' count stored in $a0
	
	la $a0, SPACE		# load address of space string into $a0
	addi $v0, $zero, 4	# set $v0 to 4 (string print)
	syscall			# print space string
	
	la $t0, KEYBOARD_COUNTS #load address of keyboard counts into $t0
	addi $t0, $t0, 8	 # increment $t0 to point at 'c' count
	lw $a0, ($t0)		 # load 'c' count into $a0
	addi $v0, $zero, 1	 # set $v0 to 1
	syscall			 # print 'c' count stored in $a0
	
	la $a0, SPACE		# load address of space string into $a0
	addi $v0, $zero, 4	# set $v0 to 4 (string print)
	syscall			# print space string
	
	la $t0, KEYBOARD_COUNTS #load address of keyboard counts into $t0
	addi $t0, $t0, 12	 # increment $t0 to point at 'd' count
	lw $a0, ($t0)		 # load 'd' count into $a0
	addi $v0, $zero, 1	 # set $v0 to 1
	syscall			 # print 'd' count stored in $a0
	
	la $a0, NEWLINE 	# load address of space string into $a0
	addi $v0, $zero, 4	# set $v0 to 4 (string print)
	syscall			# print space string
	
	
	beq $zero, $zero, done_processing #branch to done_processing
	
	
	
	.kdata

	.ktext 0x80000180 #address in kernal space for exception dispatch
__kernel_entry:
	mfc0 $k0, $13 			#$13 is the 'cause' register in Coproc
	andi $k1, $k0, 0x7c 		#mask bits 2 to 6 for ExcCode field
	srl $k1, $k1, 2 		#shift bits right 2 places for easter comparison
	beq $zero, $k1, __is_interrupt	#if 0, is interrupt
	
__is_interrupt:
	andi $k1, $k0, 0x0100 				#look at bit 8
	bne $k1, $zero, __is_keyboard_interrupt 	#if it is set then is keyboard interrupt
	beq $zero, $zero, __exit_exception 		#if not exit interrupt handler

__is_keyboard_interrupt:
	
	lw  $k0, 0xffff0004 	#load the value of key pressed into $k0
	sw $k0, KEYBOARD_EVENT #store the key value into memory at KEYBOARD_EVENT
	
	addi $k0, $zero, 1 		#set $k0 to 1
	sw $k0, KEYBOARD_EVENT_PENDING	#store that 1 into KEYBOARD_EVENT_PENDING memory, signaling an event needs to be handled
	
	beq $zero, $zero, __exit_exception #branch to exit
			
__exit_exception:
	eret #exit handler
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

	
