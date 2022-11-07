.text


main:	



# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	## Test code that calls procedure for part A
	# jal save_our_souls

	## morse_flash test for part B
	 # addi $a0, $zero, 0x42   # dot dot dash dot
	 # jal morse_flash
	
	## morse_flash test for part B
	 # addi $a0, $zero, 0x37   # dash dash dash
	 # jal morse_flash
		
	## morse_flash test for part B
	 # addi $a0, $zero, 0x32  	# dot dash dot
	 # jal morse_flash
			
	## morse_flash test for part B
	 # addi $a0, $zero, 0x11   # dash
	 # jal morse_flash	
	
	## flash_message test for part C
	 # la $a0, test_buffer
	 # jal flash_message
	
	# letter_to_code test for part D
	# the letter 'P' is properly encoded as 0x46.
	 # addi $a0, $zero, 'P'
	 # jal letter_to_code
	
	# letter_to_code test for part D
	# the letter 'A' is properly encoded as 0x21
	# addi $a0, $zero, 'A'
	# jal letter_to_code
	
	# letter_to_code test for part D
	# the space' is properly encoded as 0xff
	# addi $a0, $zero, ' '
	# jal letter_to_code
	
	# encode_message test for part E
	# The outcome of the procedure is here
	# immediately used by flash_message
	 la $a0, message02
	 la $a1, buffer01
	 jal encode_message
	 la $a0, buffer01
	 jal flash_message
	
	
	# Proper exit from the program.
	addi $v0, $zero, 10
	syscall
	
	
###########
# PROCEDURE
save_our_souls:

	addi $sp, $sp, -4 #saving $ra to the stack
	sw $ra, 4($sp)

	jal seven_segment_on #Calling individual seven segment procedures to manually flash SOS
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	
	lw $ra, 4($sp) #Restoring $ra from the stack
	addi $sp, $sp, 4
	
	jr $ra


# PROCEDURE
morse_flash:

	addi $sp, $sp, -24 #saving registers to stack
	sw $a0, 4($sp)
	sw $t3, 8($sp)
	sw $t4, 12($sp)
	sw $t5, 16($sp)
	sw $t6, 20($sp)
	sw $ra, 24($sp)
	
	beq $a0, 0xff, three_long #check for special '0xff' call delay_long x3 if true

	andi $t3, $a0, 0xf0 #isolating leftmost 4 bits into $t3
	srl $t3, $t3, 4 #$t3 is loop counter
	
	addiu $t6, $0, 0x4 #setting $t6 to 4
	subu $t6, $t6, $t3 #setting $t6 to 4 - $t3
	
	andi $t4, $a0, 0x0f #isolating rightmost 4 bits into $t4 which determine dot or dash
	sllv $t4, $t4, $t6 # Shift $t4 bits left by the length of the sequence
	
mf_loop:
	beqz $t3, mf_fin #continue loop if $t3 is greater than 0
		
	andi $t5, $t4, 0x8 #isolating left most bit of $t4 into $t5
	bne  $t5,0x8, short #if leftmost bit is 0, branch to short flash
	beq $t5,0x8, long #if leftmost bit it 1, branch to long flash

short:
	jal seven_segment_on #display a short flash (dot)
	jal delay_short
	jal seven_segment_off
	jal delay_long
	
	sll $t4, $t4, 1 #shift bits of $t4 right by 1
	subiu $t3, $t3, 1 #decrement loop counter
	
	j mf_loop #return to loop
long:
	jal seven_segment_on #display a long long flash (dash) 
	jal delay_long
	jal seven_segment_off
	jal delay_long
	
	sll $t4, $t4, 1 #shift bits of $t4 right by 1
	subiu $t3, $t3, 1 #decrement loop counter
	
	j mf_loop #return to loop
	
three_long:
	jal delay_long # delay_long x3
	jal delay_long
	jal delay_long
	j mf_fin #jump to end of function
	
mf_fin:
	
	lw $a0, 4($sp)
	lw $t3, 8($sp)
	lw $t4, 12($sp)
	lw $t5, 16($sp)
	lw $t6, 20($sp)
	lw $ra, 24($sp) #restore registers saved on the stack
	addi $sp, $sp, 24
	
	jr $ra

###########
# PROCEDURE
flash_message:
	
	addi $sp, $sp, -12 #saving registers to stack
	sw $a0, 4($sp)
	sw $t5, 8($sp)
	sw $ra, 12($sp)
	
	addu $t5, $a0, $0 #copy address in $a0 to $t5
	
fm_loop:
	lbu $a0,($t5) # load byte stored at address of $t5 into $a
	beqz, $a0, fm_fin # check to see if loaded byte is 0, jump to function end if so, continue if not.
	jal morse_flash # call morse_flash procedure with currently loaded byte
	
	addiu $t5, $t5, 1 #increment address to the memory loacation of the next byte
	
	j fm_loop  # continue loop
	
fm_fin:
	
	lw $a0, 4($sp)
	lw $t5, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 12 #returning registers from stack
	
	jr $ra 
	
	
###########
# PROCEDURE
letter_to_code:
	
	addi $sp, $sp, -24 #saving registers to stack
	sw $a0, 4($sp)
	sw $t3, 8($sp)
	sw $t4, 12($sp)
	sw $t5, 16($sp)
	sw $t6, 20($sp)
	sw $ra, 24($sp)
	
	
	la $t3, codes #load memory address of "codes" dataset into $t3
	addiu $t5, $0, 0 #$t5 is the sequence length
	addiu $t6, $0, 0 #$t6 is the sequence of dots and dashes
	
	beq $a0, ' ',space #check if argument passed is " " (space character) if so, return value 0xFF
	j find_loop #if not, begin the loop.
	
space:
	add $v0, $0, 0xFF #set value of $v0 to 0xff
	
	
	lw $a0, 4($sp)
	lw $t3, 8($sp)
	lw $t4, 12($sp)
	lw $t5, 16($sp)
	lw $t6, 20($sp)
	lw $ra, 24($sp) #restore registers saved on the stack
	addi $sp, $sp, 24
	
	jr $ra

find_loop:
	lb $t4, ($t3) #load "codes" dataset element
	beq $t4, $a0, build_loop # If passed parameter in $a0 is equal to the first byte in the dataset entry, jump to inner loop
	addiu $t3, $t3, 8 #increment address to next element in "codes" dataset
	j find_loop # interate loop
	
build_loop:
	addiu $t3, $t3, 1 #increment through the matching element of the "codes" dataset
	lb $t4, ($t3) #load byte at memory address (will be '-','.' or '0')
	beq $t4, $0, ltc_fin # If loaded byte is 0, jump to end of function
	beq $t4, '-', add_dash # If loaded byte is '-', jump to add_dash subroutine
	beq $t4, '.', add_dot # If loaded byte is '.', jump to add_dot subroutine
	
add_dash:
	sll $t6, $t6, 1 #shift the bits of the sequence register left
	addiu $t5, $t5, 1 # Increment the sequence length register
	addiu $t6, $t6, 1 # Assign a 1 to the rightmost bit of the sequence register (which represents a dash)
	j build_loop #return to loop
	
add_dot:
	addiu $t5, $t5, 1 #Increment the sequence length register
	sll $t6, $t6, 1 #Shift the sequence register bits left by one, effectively assigning a 0 to the rightmost bit.
	j build_loop # return to loop
	
ltc_fin:	
	sll $t5, $t5, 4 #shift bits of sequence length left by 4
	addu $v0, $t5, $t6 # Combine sequence length and sequence contents regusters into $v0
			
	
	lw $a0, 4($sp)
	lw $t3, 8($sp)
	lw $t4, 12($sp)
	lw $t5, 16($sp)
	lw $t6, 20($sp)
	lw $ra, 24($sp) #restore registers saved on the stack
	addi $sp, $sp, 24
	
	jr $ra	


###########
# PROCEDURE
encode_message:
	addi $sp, $sp, -24 #saving registers to stack
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $ra, 24($sp)
	
	addu $t3, $a0, $0 #Copy address passed in $a0 to $t3
	
em_loop:
	lb $a0, ($t3) #load value at address stored in $t3 into $a0
	beqz $a0, em_fin #if value is zero then jump to end of function
	
	jal letter_to_code # Call letter_to_code function, passing value stored at $a0
	
	sb $v0, ($a1) #store the value returned from letter_to_code into memory address of buffer
	addiu $t3, $t3, 1 #increment address value of byte to be read from "message"
	addiu $a1, $a1, 1 #increment buffer address value to store converted byte
	
	j em_loop #continue loop
	
em_fin:

	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 24 #restore registers saved on the stack

	jr $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

#############################################
# DO NOT MODIFY ANY OF THE CODE / LINES BELOW

###########
# PROCEDURE
seven_segment_on:
	la $t1, 0xffff0010     # location of bits for right digit
	addi $t2, $zero, 0xff  # All bits in byte are set, turning on all segments
	sb $t2, 0($t1)         # "Make it so!"
	jr $31


###########
# PROCEDURE
seven_segment_off:
	la $t1, 0xffff0010	# location of bits for right digit
	sb $zero, 0($t1)	# All bits in byte are unset, turning off all segments
	jr $31			# "Make it so!"
	

###########
# PROCEDURE
delay_long:
	add $sp, $sp, -4	# Reserve 
	sw $a0, 0($sp)
	addi $a0, $zero, 600
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31

	
###########
# PROCEDURE			
delay_short:
	add $sp, $sp, -4
	sw $a0, 0($sp)
	addi $a0, $zero, 200
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31




#############
# DATA MEMORY
.data
codes:
	.byte 'A', '.', '-', 0, 0, 0, 0, 0
	.byte 'B', '-', '.', '.', '.', 0, 0, 0
	.byte 'C', '-', '.', '-', '.', 0, 0, 0
	.byte 'D', '-', '.', '.', 0, 0, 0, 0
	.byte 'E', '.', 0, 0, 0, 0, 0, 0
	.byte 'F', '.', '.', '-', '.', 0, 0, 0
	.byte 'G', '-', '-', '.', 0, 0, 0, 0
	.byte 'H', '.', '.', '.', '.', 0, 0, 0
	.byte 'I', '.', '.', 0, 0, 0, 0, 0
	.byte 'J', '.', '-', '-', '-', 0, 0, 0
	.byte 'K', '-', '.', '-', 0, 0, 0, 0
	.byte 'L', '.', '-', '.', '.', 0, 0, 0
	.byte 'M', '-', '-', 0, 0, 0, 0, 0
	.byte 'N', '-', '.', 0, 0, 0, 0, 0
	.byte 'O', '-', '-', '-', 0, 0, 0, 0
	.byte 'P', '.', '-', '-', '.', 0, 0, 0
	.byte 'Q', '-', '-', '.', '-', 0, 0, 0
	.byte 'R', '.', '-', '.', 0, 0, 0, 0
	.byte 'S', '.', '.', '.', 0, 0, 0, 0
	.byte 'T', '-', 0, 0, 0, 0, 0, 0
	.byte 'U', '.', '.', '-', 0, 0, 0, 0
	.byte 'V', '.', '.', '.', '-', 0, 0, 0
	.byte 'W', '.', '-', '-', 0, 0, 0, 0
	.byte 'X', '-', '.', '.', '-', 0, 0, 0
	.byte 'Y', '-', '.', '-', '-', 0, 0, 0
	.byte 'Z', '-', '-', '.', '.', 0, 0, 0
	
message01:	.asciiz "A A A"
message02:	.asciiz "SOS"
message03:	.asciiz "WATERLOO"
message04:	.asciiz "DANCING QUEEN"
message05:	.asciiz "CHIQUITITA"
message06:	.asciiz "THE WINNER TAKES IT ALL"
message07:	.asciiz "MAMMA MIA"
message08:	.asciiz "TAKE A CHANCE ON ME"
message09:	.asciiz "KNOWING ME KNOWING YOU"
message10:	.asciiz "FERNANDO"

buffer01:	.space 128
buffer02:	.space 128
test_buffer:	.byte 0x30 0x37 0x30 0x00    # This is SOS
