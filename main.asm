.data:
month_sum: .word 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365
weekday_short: .asciiz "Sat\0\0\0Sun\0\0\0Mon\0\0\0Tues\0\0Wed\0\0\0Thurs\0Fri\0\0\0"

.text:
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
	# get first digit of a0
	lb $v0, 0($a0)
	addiu $v0, $v0, -48
	sll $t0, $v0, 2
	addu $t0, $t0, $v0
	addu $v0, $t0, $t0
	# get second digit of a0
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
	# get forth and fifth digit of a0
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
	# get seventh and eighth digit of a0
	jal Day
	sll $t0, $v0, 2
	addu $t0, $t0, $v0
	addu $v0, $t0, $t0
	sll $t0, $v0, 2
	addu $t0, $t0, $v0
	addu $s0, $t0, $t0
	lw $a0, 4($sp)
	addiu $a0, $a0, 8
	# get ninth and tenth digit of a0
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
	# t0 = Year
	or $t0, $0, $v0
	# t2 = t0 % 400
	ori $t1, $0, 400
	div $t0, $t1
	mfhi $t2
	beq $t2, $0, LeapYear_True
	# t2 = t0 % 100
	ori $t1, $0, 100
	div $t0, $t1
	mfhi $t2
	beq $t2, $0, LeapYear_False
	# t2 = t0 % 4
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

j EndGetTime
GetTime:	
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a1, 4($sp)
	jal DateIndex
	lw $a0, 4($sp)
	sw $v0, 4($sp)
	jal DateIndex
	lw $t0, 4($sp)
	sub $v0, $v0, $t0
        # if v0 < 0 v0 = -v0
        slt $t0, $v0, $0
        beq $t0, $0, GetTime_DontNeg
        sub $v0, $0, $v0
GetTime_DontNeg:
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
EndGetTime:

j EndWeekDay
WeekDay:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal DateIndex
	# $v0 = ($v0 + 1) % 7
        addiu $v0, $v0, 1
	ori $t0, $zero, 7
	div $v0, $t0
	mfhi $v0
        # v0 *= 6
        sll $t1, $v0, 1
        addu $v0, $t1, $v0
        sll $v0, $v0, 1
        # v0 = weekday_short + v0
        la $t0, weekday_short
        addu $v0, $v0, $t0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
EndWeekDay:

j EndDateIndex
DateIndex:
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $a0, 12($sp)
    jal Month
    # s1 = 2 < month
    ori $t0, $0, 2
    slt $s1, $t0, $v0
    # s0 = month_sum[month-1]
    addiu $v0, $v0, -1
    sll $v0, $v0, 2
    la $t0, month_sum
    addu $v0, $v0, $t0
    lw $s0, 0($v0)
    # s1 = s1 & is_leap_year
    lw $a0, 12($sp)
    jal LeapYear
    and $s1, $s1, $v0
    # if s1 -> s0 += 1
    beq $s1, $0, DayIndex_DontAdd
    addiu $s0, $s0, 1
DayIndex_DontAdd:
    # v0 = year - 1
    lw $a0, 12($sp)
    jal Year
    addiu $v0, $v0, -1
    # s0 += v0 * 365
    ori $t1, $0, 365
    mult $v0, $t1
    mflo $t0
    addu $s0, $s0, $t0
    # s0 += v0 / 400
    ori $t1, $0, 400
    div $v0, $t1
    mflo $t0
    addu $s0, $s0, $t0
    # s0 -= v0 / 100
    ori $t1, $0, 100
    div $v0, $t1
    mflo $t0
    subu $s0, $s0, $t0
    # s0 += v0 / 4
    srl $t0, $v0, 2
    addu $s0, $s0, $t0
    # v0 = s0 + day
    lw $a0, 12($sp)
    jal Day
    addu $v0, $s0, $v0
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 16
    jr $ra
EndDateIndex:


j EndMain
Main:
addiu $sp, $sp, -32
sw $ra, 0($sp)
jal Malloc
or $a0, $0, $v0
ori $a1, $0, 256
ori $v0, $0, 8
syscall
jal WeekDay
or $a0, $0, $v0
ori $v0, $0, 4
syscall
lw $ra, 0($sp)
addiu $sp, $sp, 32
EndMain:
