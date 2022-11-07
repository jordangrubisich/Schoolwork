# This code assumes the use of the "Bitmap Display" tool.
#
# Tool settings must be:
#   Unit Width in Pixels: 32
#   Unit Height in Pixels: 32
#   Display Width in Pixels: 512
#   Display Height in Pixels: 512
#   Based Address for display: 0x10010000 (static data)
#
# In effect, this produces a bitmap display of 16x16 pixels.


	.include "bitmap-routines.asm"

	.data
TELL_TALE:
	.word 0x12345678 0x9abcdef0	# Helps us visually detect where our part starts in .data section
	
	.globl main
	.text	
main:
	addi $a0, $zero, 0
	addi $a1, $zero, 0
	addi $a2, $zero, 0x00ff0000
	jal draw_bitmap_box
	
	addi $a0, $zero, 11
	addi $a1, $zero, 6
	addi $a2, $zero, 0x00ffff00
	jal draw_bitmap_box
	
	addi $a0, $zero, 8
	addi $a1, $zero, 8
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	
	addi $a0, $zero, 2
	addi $a1, $zero, 3
	addi $a2, $zero, 0x00000000
	jal draw_bitmap_box

	addi $v0, $zero, 10
	syscall
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


# Draws a 4x4 pixel box in the "Bitmap Display" tool
# $a0: row of box's upper-left corner
# $a1: column of box's upper-left corner
# $a2: colour of box

#$s3, row loop counter
#$s4, col loop counter

draw_bitmap_box:
	addi $sp, $sp, -20 	# Allocate stack space
	sw $ra, 20($sp)		# Store all used registers on the stack
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $a0, 8($sp)
	sw $a1, 4($sp)
	
	addi $s3, $zero, 4 	#initialize row loop counter to 4

row_loop:
	addi $s4, $zero, 4 	# initialize / reset col loop counter to 4
	j col_loop		# prints 4 pixels to the right starting on current line 
row_mid:
	addi $a1, $a1, -4	# return the column pointer back to original position
	addi $s3, $s3, -1	# decrement row loop counter
	addi $a0, $a0, 1	# move row pointer to next row
	bnez $s3,row_loop	# check if row loop counter has reached 0
	j fin

col_loop:
	jal set_pixel		# set pixel with current color register and current row / col pointers
	addi $a1, $a1, 1	# move pointer right by 1 space
	addi $s4, $s4, -1	# Decrement col loop counter
	bnez $s4, col_loop	# check if col loop counter is zero
	j row_mid		# return back to middle of row loop

fin:
	
	lw $ra, 20($sp)		# Return saved values from the stack
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $a0, 8($sp)
	lw $a1, 4($sp)
	addi $sp, $sp, 20	# deallocate stack space
	
	jr $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
