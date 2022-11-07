# This program, when completed, will prompt the user for
# x and y co-ordinates, and values for red, green and blue.
# it will then use the set_pixel procedure in bitmap-routines.asm
# to set the pixel to the desired colour, and then repeat.

# Entering -1 for the row number should end the program.
		
# This program requires the bitmap display to be set to the following settings:
# Unit width in pixels: 32
# Unit height in pixels: 32
# Display width in pixels: 512
# Display height in pixels: 512
# Base address for display: 0x10010000 (static data)
	
.include "bitmap-routines.asm"					
													
.data
# our strings
S1:			.asciiz "Enter the row number (0-15):"
S2:			.asciiz "Enter the column number (0-15):"
S3:			.asciiz "Enter the red value (0-255):"
S4:                     .asciiz "Enter the green value (0-255):"
S5:                     .asciiz "Enter the blue value (0-255):"

	
.text
	  
main:

input_loop:
	la $a0, S1                # Get the row number
	addi $v0, $zero, 4
	syscall	
	addi $v0, $zero, 5
	syscall
	add $s0, $zero, $v0      
	
	beq $s0, -1, done        # see if we should quit
	
	la $a0, S2               # Get the column number
	addi $v0, $zero, 4
	syscall	
	addi $v0, $zero, 5
	syscall
	add $s1, $zero, $v0      
	
	la $a0, S3                # Get the red value
	addi $v0, $zero, 4
	syscall	
	addi $v0, $zero, 5
	syscall
	add $s2, $zero, $v0      
	
	la $a0, S4                # Get the green value
	addi $v0, $zero, 4
	syscall	
	addi $v0, $zero, 5
	syscall
	add $s3, $zero, $v0       
	
	la $a0, S5                # Get the blue value
	addi $v0, $zero, 4
	syscall	
	addi $v0, $zero, 5
	syscall
	add $s4, $zero, $v0      
	
	# $s0 now has the row number
	# $s1 now has the column number
	# $s2 now has the red value
	# $s3 now has the green value
	# $s4 now has the blue value
	
	# set_pixel is expecting the row number in $a0 and the column number in $a1
	
	add $a0, $zero, $s0
	add $a1, $zero, $s1
	
	# set_pixel is also expecting the colour to be provided as a 24-bit value rgb value,
	# in a single register ($a2).  We currently have it stored as three 8-bit values, in 3
	# separate registers.  We need to pack the bits into $a2 like this:
	# 0000 0000 RRRR RRRR GGGG GGGG BBBB BBBB
	
	sll $s2, $s2, 16
	sll $s3, $s3, 8
	add $a2, $zero, $s2
	add $a2, $a2, $s3
	add $a2, $a2, $s4
	
	# we're done.  Let set_pixel take over.
	
	jal set_pixel
	
	beqz $zero, input_loop
	
done:
	addi $v0, $zero, 10
	syscall





