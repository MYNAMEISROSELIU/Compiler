main:
	li $t3, 1
	move $t0 , $t3
	move $s0 , $t0
	li $t3, 2
	move $t0 , $t3
	move $s1 , $t0
WHILE1:
	move $t3 , $s0
	li $t4, 5
	sle $t5,$t3,$t4
	beq $t5,0,WHILE1End
	move $t3 , $s0
	move $t0, $t3
	li $v0,1
	move $a0,$t0
	syscall
	move $t3 , $s0
	li $t4, 1
	move $t0,$t3
	move $t1,$t4
	add $t3,$t0,$t1
	move $t0 ,$t3
	move $s0 ,$t0
	jal WHILE1
WHILE1End:
BLOCK_End0:
IF1:
	move $t3 , $s0
	li $t4, 5
	seq $t6,$t3,$t4
	beq $t6,0,ELSE1
	jal BLOCK_End1
	jal ELSE_End1
ELSE1:
	move $t3 , $s0
	move $t0, $t3
	li $v0,1
	move $a0,$t0
	syscall
ELSE_End1:
BLOCK_End1:
	move $t3 , $s0
	move $t4 , $s1
	move $t0,$t3
	move $t1,$t4
	add $t3,$t0,$t1
	move $t0, $t3
	li $v0,1
	move $a0,$t0
	syscall
BLOCK_End2:
