	.file	1 "fib.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 3
	.text
	.align	2
	.globl	print
	.set	nomips16
	.ent	print
	.type	print, @function
print:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	sw	$4,24($fp)
	j	$L2
	nop

$L3:
	lw	$2,24($fp)
	nop
	lb	$2,0($2)
	nop
	move	$4,$2
	jal	SendByte
	nop

	lw	$2,24($fp)
	nop
	addiu	$2,$2,1
	sw	$2,24($fp)
$L2:
	lw	$2,24($fp)
	nop
	lb	$2,0($2)
	nop
	bne	$2,$0,$L3
	nop

	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	print
	.size	print, .-print
	.align	2
	.globl	fib
	.set	nomips16
	.ent	fib
	.type	fib, @function
fib:
	.frame	$fp,80,$31		# vars= 56, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-80
	sw	$31,76($sp)
	sw	$fp,72($sp)
	move	$fp,$sp
	sw	$4,80($fp)
	sw	$0,32($fp)
	li	$2,1			# 0x1
	sw	$2,28($fp)
	lw	$2,80($fp)
	nop
	sw	$2,20($fp)
	j	$L6
	nop

$L7:
	addiu	$2,$fp,36
	lw	$4,32($fp)
	move	$5,$2
	li	$6,10			# 0xa
	jal	int_to_string
	nop

	move	$4,$2
	jal	print
	nop

	lw	$3,32($fp)
	lw	$2,28($fp)
	nop
	addu	$2,$3,$2
	sw	$2,24($fp)
	lw	$2,28($fp)
	nop
	sw	$2,32($fp)
	lw	$2,24($fp)
	nop
	sw	$2,28($fp)
	lw	$2,20($fp)
	nop
	addiu	$2,$2,-1
	sw	$2,20($fp)
$L6:
	lw	$2,20($fp)
	nop
	bgtz	$2,$L7
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,76($sp)
	lw	$fp,72($sp)
	addiu	$sp,$sp,80
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	fib
	.size	fib, .-fib
	.rdata
	.align	2
$LC0:
	.ascii	"S\012\000"
	.align	2
$LC1:
	.ascii	"E\012\000"
	.text
	.align	2
	.globl	main
	.set	nomips16
	.ent	main
	.type	main, @function
main:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	lui	$2,%hi($LC0)
	addiu	$4,$2,%lo($LC0)
	jal	print
	nop

	li	$4,10			# 0xa
	jal	fib
	nop

	lui	$2,%hi($LC1)
	addiu	$4,$2,%lo($LC1)
	jal	print
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (crosstool-NG 1.13.2) 4.4.6"
