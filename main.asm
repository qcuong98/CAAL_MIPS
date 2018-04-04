j Main


j EndMalloc
Malloc:
ori $a0, $0, 256
ori $v0, $0, 9
syscall
jr $ra
EndMalloc:


j EndDay
Day:
lb $v0, 0($a0)
addiu $v0, $v0, -48
sll $t0, $v0, 2
addu $t0, $t0, $v0
addu $v0, $t0, $t0
lb $t0, 1($a0)
addiu $t0, $t0, -48
addu $v0, $v0, $t0
jr $ra
EndDay:


j EndMonth
Month:
addiu $sp, $sp, -4
sw $ra, 0($sp)
addiu $a0, $a0, 3
jal Day
lw $ra, 0($sp)
addiu $sp, $sp, 4
jr $ra
EndMonth:


j EndYear
Year:
addiu $sp, $sp, -12
sw $ra, 0($sp)
sw $a0, 4($sp)
sw $s0, 8($sp)
addiu $a0, $a0, 6
jal Day
sll $t0, $v0, 2
addu $t0, $t0, $v0
addu $v0, $t0, $t0
sll $t0, $v0, 2
addu $t0, $t0, $v0
addu $s0, $t0, $t0
lw $a0, 4($sp)
addiu $a0, $a0, 8
jal Day
add $v0, $s0, $v0
lw $s0, 8($sp)
lw $ra, 0($sp)
addiu $sp, $sp, 12
jr $ra
EndYear:


j EndLeapYear
LeapYear:
addiu $sp, $sp, -4
sw $ra, 0($sp)
jal Year
or $t0, $0, $v0
ori $t1, $0, 400
div $t0, $t1
mfhi $t2
beq $t2, $0, LeapYear_True
ori $t1, $0, 100
div $t0, $t1
mfhi $t2
beq $t2, $0, LeapYear_False
andi $t2, $t0, 3
bne $t2, $0, LeapYear_False
j LeapYear_True
LeapYear_False:
lw $ra, 0($sp)
addiu $sp, $sp, 4
ori $v0, $0, 0
jr $ra
LeapYear_True:
lw $ra, 0($sp)
addiu $sp, $sp, 4
ori $v0, $0, 1
jr $ra
EndLeapYear:


j EndMain
Main:
EndMain:
