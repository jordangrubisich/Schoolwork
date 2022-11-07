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
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
BOX_ROW:
	.word	0x0
BOX_COLUMN:
	.word	0x0

	.eqv LETTER_a 97
	.eqv LETTER_d 100
	.eqv LETTER_w 119
	.eqv LETTER_x 120
	.eqv BOX_COLOUR 0x0099ff33
	
	.globl main
	
	.text	
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

.data
    .eqv BOX_COLOUR_BLACK 0x00000000
.text


	la $s0, 0xffff0000 # load address for MMIO Simulator receiver
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02 #enable keyboard interrupts
	sb $s1, 0($s0)
	
	addi $a0, $zero, 0		# draw starting box with left corner at (0,0)
	addi $a1, $zero, 0
	addi $a2, $zero, BOX_COLOUR
	
	jal draw_bitmap_box
	
check_for_event:
	la $s0, KEYBOARD_EVENT_PENDING		# loop infinitely while checking if keyboard event pending
	lw $s1, 0($s0)
	beq $s1, $zero, check_for_event	# if event pending, break loop to handle event
	
	lw $s1, KEYBOARD_EVENT		# load the value of the key pressed into $s1
	
	beq $s1, 97, is_a		# branch to corresponding instructions based on whether key pressed was a,d,w or x
	beq $s1, 100, is_d
	beq $s1, 119, is_w
	beq $s1, 120, is_x
	
	beq $zero, $zero, done_processing #if key pressed was not a,d,w or x branch to done_processing
	
is_a:
	la $t6, BOX_ROW		#
	lw $a0, ($t6)		# retrieve current box position from memory
	la $t7, BOX_COLUMN	#
	lw $a1, ($t7)		#
	addi $a2, $zero, BOX_COLOUR_BLACK #set color to black
	
	jal draw_bitmap_box #draw over current box with black (effectively removing it)
	
	addi $a2, $zero, BOX_COLOUR #set color to green
	addi $a1, $a1, -1 #adjust col position one space to the left
	
	jal draw_bitmap_box #re-draw the box in green
	
	sw $a0, ($t6) 	#store updated row position
	sw $a1, ($t7)	#store updated col position
	
	beq $zero, $zero, done_processing #branch to done_processing
	
is_d:
	la $t6, BOX_ROW		#
	lw $a0, ($t6)		#retrieve current box position from memory
	la $t7, BOX_COLUMN	#	
	lw $a1, ($t7)		#
	addi $a2, $zero, BOX_COLOUR_BLACK #set color to black
	
	jal draw_bitmap_box #draw over current box with black (effectively removing it)
	
	addi $a2, $zero, BOX_COLOUR 	#set colur to green
	addi $a1, $a1, 1		#adjust col position one space to the right
	
	jal draw_bitmap_box # re-draw the box in green
	
	sw $a0, ($t6)	# store updated row position
	sw $a1, ($t7)	# store updated col position
	
	beq $zero, $zero, done_processing #branch to done_procressing
	

is_w:		

	la $t6, BOX_ROW		#
	lw $a0, ($t6)		#retrieve current box position from memory
	la $t7, BOX_COLUMN	#	
	lw $a1, ($t7)		#
	addi $a2, $zero, BOX_COLOUR_BLACK #set color to black
	
	jal draw_bitmap_box #draw over current box with black (effectively removing it)
	
	addi $a2, $zero, BOX_COLOUR 	#set color to green
	addi $a0, $a0, -1 		#adjust row position one space upwards
	
	jal draw_bitmap_box #re-draw box in green
	
	sw $a0, ($t6)	# store updated row position
	sw $a1, ($t7)	# store updated col position
	
	beq $zero, $zero, done_processing #branch to done_prcessing
	
is_x:
	la $t6, BOX_ROW		#
	lw $a0, ($t6)		#retrieve current box position from memory
	la $t7, BOX_COLUMN	#	
	lw $a1, ($t7)		#
	addi $a2, $zero, BOX_COLOUR_BLACK #set color to black
	
	jal draw_bitmap_box #draw over current box with black (effectively removing it)
	
	addi $a2, $zero, BOX_COLOUR 	#set color to green
	addi $a0, $a0, 1 		#adjust row position one space downward
	
	jal draw_bitmap_box #re-draw box in green
	
	sw $a0, ($t6)	# store updated row position
	sw $a1, ($t7)	# store updated col position

	beq $zero, $zero, done_processing #branch to done_processing

done_processing:
	la $s0, KEYBOARD_EVENT_PENDING # Set keyboard event 
	sw $zero, ($s0)			#
	beq $zero, $zero, check_for_event # branch back to infinite loop
	
	
	


	addi $v0, $zero, BOX_COLOUR_BLACK 	#control flow should never ever ever reach here
	syscall					#syscall 0 will throw an error



# Draws a 4x4 pixel box in the "Bitmap Display" tool
# $a0: row of box's upper-left corner
# $a1: column of box's upper-left corner
# $a2: colour of box

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
# You can copy-and-paste some of your code from part (c)
# to provide the procedure body.
#
	jr $ra


	.kdata

	.ktext 0x80000180
#
# You can copy-and-paste some of your code from part (a)
# to provide elements of the interrupt handler.
#

# below code adapted from lab08-A-solution.asm
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

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


.data

# Any additional .text area "variables" that you need can
# be added in this spot. The assembler will ensure that whatever
# directives appear here will be placed in memory following the
# data items at the top of this file.

	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE


.eqv BOX_COLOUR_WHITE 0x00FFFFFF
	
