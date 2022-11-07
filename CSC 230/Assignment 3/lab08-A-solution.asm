# This program, when completed, should allow the user to enter text using
# the MMIO simulator tool.  When the user presses the enter key, we will 
# display the number of uppercase letters and lowercase letters entered
# on the standard output, and then will exit.
	
	
			
.data
# our strings
S1:			.asciiz "You entered "
S2:			.asciiz " uppercase letters and "
S3:			.asciiz " lowercase letters.\n"
# our variables
UPPERCASE_COUNT:  	.word 0        	# the four global variables for our state..word 0
LOWERCASE_COUNT:        .word 0
LAST_KEYBOARD_EVENT:    .byte 0   	# should contain the ascii value of the last entered character
CHARACTER_ENTERED:      .byte 0    	# 1 = a character has been entered
	           			# 0 = no character has been entered
	
.text
	  
main:
	# Must enable the keyboard device (i.e., in the "MMIO" simulator) to
	# generate interrupts. 0xffff0000 is the location in kernel memory
	# mapped to the control register of the keybaord.
	
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)
	
process_character_loop:
	# check to see if a character has been entered.
	lbu $s0, CHARACTER_ENTERED
	beq $s0, $zero, process_character_loop
	
	# if so, $s1 shall be the character's ascii value
	
	# check for enter key - if so, we'll quit
	lbu $s1, LAST_KEYBOARD_EVENT
	beq $s1, '\n', display_and_quit
	
	# otherwise, check to see if it's uppercase.  If so, increment our uppercase count.
	
	bgt $s1, 'Z', not_uppercase
	blt $s1, 'A', not_uppercase
	lw $s2, UPPERCASE_COUNT
	addi, $s2, $s2, 1
	sw $s2, UPPERCASE_COUNT
	b finished_processing_character

	
not_uppercase:
	# it wasn't uppercase.  check if it's lowercase, and increment lowercase count if it was.

	blt $s1, 'a', not_lowercase
	bgt $s1, 'z', not_lowercase
	lw $s2, LOWERCASE_COUNT
	addi, $s2, $s2, 1
	sw $s2, LOWERCASE_COUNT
	b finished_processing_character
	
not_lowercase:	
	
finished_processing_character:
	
	# set our 'character pending' flag back to zero and repeat.
	sb $zero, CHARACTER_ENTERED
	beq $zero, $zero, process_character_loop



display_and_quit:
	la $a0, S1                #print "You entered "
	addi $v0, $zero, 4
	syscall	
	
	lw $a0, UPPERCASE_COUNT   # print the count of uppercase letters
	addi $v0, $zero, 1
	syscall
	
	la $a0, S2                # print " uppercase letters and "
	addi $v0, $zero, 4
	syscall	

	lw $a0, LOWERCASE_COUNT   # print the count of lowercase letters
	addi $v0, $zero, 1
	syscall
	
	la $a0, S3                # print " lowercase letters."
	addi $v0, $zero, 4
	syscall	
	
	addi $v0, $zero, 10       # quit
	syscall

	.kdata
	
	# No data in the kernel-data section (at present)

	.ktext 0x80000180	# Required address in kernel space for exception dispatch
__kernel_entry:
	mfc0 $k0, $13		# $13 is the "cause" register in Coproc0
	andi $k1, $k0, 0x7c	# bits 2 to 6 are the ExcCode field (0 for interrupts)
	srl  $k1, $k1, 2	# shift ExcCode bits for easier comparison
	beq $zero, $k1, __is_interrupt
	
__is_exception:
	# Something of a placeholder...
	# ... just in case we can't escape the need for handling some exceptions.
	beq $zero, $zero, __exit_exception
	
__is_interrupt:
	andi $k1, $k0, 0x0100	# examine bit 8
	bne $k1, $zero, __is_keyboard_interrupt	 # if bit 8 set, then we have a keyboard interrupt.
	
	beq $zero, $zero, __exit_exception	# otherwise, we return exit kernel
	
__is_keyboard_interrupt:
	# grab the ascii value from where it's mapped into memory, then store it to our variable.
	lb $k0, 0xffff0004
	sb $k0, LAST_KEYBOARD_EVENT
	
	# set our flag variable to one to let the main program know there's a key press to handle.
	addi $k0, $zero, 1
	sb $k0, CHARACTER_ENTERED
	
	beq $zero, $zero, __exit_exception	# Kept here in case we add more handlers.
	
	
__exit_exception:
	eret
	
