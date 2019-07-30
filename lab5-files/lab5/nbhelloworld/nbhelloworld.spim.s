#
#  CSE 141L Example Application
#  Prints "Hello World" to the serial interface at 0xffff0000
#  Avoids most MIPS instructions and all branches.
#  Will not work with SPIM because this does not check for buffer overflows on the serial interface (only the first character will print in SPIM)
#
#
#  Change Log:
#	1/18/2012 - Adrian Caulfield - Initial Implementation
#
#
#

.text


	__start:
	addi	$10,$0,0x4000
	sub	$20,$0,$10
	sub	$20,$20,$10		# $20 should now contain 0xffffc000
	sub	$20,$20,$10		# $20 should now contain 0xffff8000
	sub	$20,$20,$10		# $20 should now contain 0xffff0000
	
	addi	$10,$0,0x48		# $10 is now 'H'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x65		# 'e'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x6C		# 'l'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x6C		# 'l'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x6F		# 'o'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x20		# ' '
	sw	$10,12($20)		# write word

	addi	$10,$0,0x57		# 'W'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x6F		# 'o'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x72		# 'r'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x6C		# 'l'
	sw	$10,12($20)		# write word

	addi	$10,$0,0x64		# 'd'
	sw	$10,12($20)		# write word

	
