.data:
	month_sum: .word 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365
	weekday_short: .asciiz "Sat\0\0\0Sun\0\0\0Mon\0\0\0Tues\0\0Wed\0\0\0Thurs\0Fri\0\0\0"
	month_short: .asciiz "Jan\0Feb\0Mar\0Apr\0May\0Jun\0Jul\0Aug\0Sep\0Oct\0Nov\0Dec\0"
	input_day: .asciiz "Nhap ngay: "
	input_month: .asciiz "Nhap thang: "
	input_year: .asciiz "Nhap nam: "
	input_error: .asciiz "Nhap sai, nhap lai: "
	menu: .asciiz "------Ban hay chon 1 trong cac thao tac duoi day------\n1. Xuat chuoi TIME theo dinh dang DD/MM/YYYY\n2. Chuyen doi chuoi TIME thanh mot trong cac dinh dang sau:\n\tA. MM/DD/YYYY\n\tB. Month DD, YYYY\n\t\C. DD Month, YYYY\n3. Cho biet ngay vua nhap la thu may trong tuan\n4. Kiem tra xem nam trong chuoi time co phai la nam nhuan khong\n5. Cho biet khoang thoi gian giua chuoi TIME_1 va TIME_2\n6. Cho biet 2 nam nhuan gan nhat voi nam trong chuoi TIME\n"
	input_choice: .asciiz "Lua chon cua ban: "
	result: .asciiz "Ket qua: "
	input_time1: .asciiz "Nhap chuoi TIME_1: "
	input_time2: .asciiz "Nhap chuoi TIME_2: "

.text:
	j Main


j EndMalloc
Malloc:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	ori $a0, $0, 256
	ori $v0, $0, 9
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
EndMalloc:

# StrCpy source: $a0, des $a1, len: $a2
j EndStrCpy
StrCpy:
	addi $a2, $a2, 1
	or $t0, $zero, $zero
	StrCpy_While:
		slt $t1, $t0, $a2
		beq $t1, $zero, StrCpy_EndWhile
		lb $t1, 0($a0)
		sb $t1, 0($a1)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $t0, $t0, 1
		j StrCpy_While
	StrCpy_EndWhile:
	jr $ra
EndStrCpy:

j EndConvert
Convert:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $a1, 12($sp)
	or $s0, $0, $a0
	jal Malloc
	or $s1, $0, $v0

	lw $a1, 12($sp)
	# if $a1 = 'A'
	ori $t0, $zero, 65
	beq $a1, $t0, Convert_TypeA
	# if $a1 = 'B'
	ori $t0, $zero, 66
	beq $a1, $t0, Convert_TypeB
	# if $a1 = 'C'
	ori $t0, $zero, 67
	beq $a1, $t0, Convert_TypeC
Convert_TypeA:
	# DD/MM/YYYY
	or $a0, $zero, $s0
	or $a1, $zero, $s1
	ori $a2, $zero, 10
	jal StrCpy

	lb $t0, 3($s0)
	sb $t0, 0($s1)
	lb $t0, 4($s0)
	sb $t0, 1($s1)
	lb $t0, 0($s0)
	sb $t0, 3($s1)
	lb $t0, 1($s0)
	sb $t0, 4($s1)

	j Convert_Return
Convert_TypeB:
	#Mth DD, YYYY
	or $a0, $0, $s0
	jal Month
	# t0 = (MM - 1) * 4
	addi $v0, $v0, -1
	sll $t0, $v0, 2
	la $a0, month_short
	add $a0, $a0, $t0
	or $a1, $zero, $s1
	ori $a2, $zero, 3
	jal StrCpy

	lb $t0, 0($s0)
	sb $t0, 4($s1)
	lb $t0, 1($s0)
	sb $t0, 5($s1)

	ori $t0, $zero, 44
	sb $t0, 6($s1)
	ori $t0, $zero, 32
	sb $t0, 3($s1)
	sb $t0, 7($s1)

	addi $a0, $s0, 6
	addi $a1, $s1, 8
	ori $a2, $zero, 4
	jal StrCpy
	j Convert_Return
Convert_TypeC:
	#DD Mth, YYYY
	lb $t0, 0($s0)
	sb $t0, 0($s1)
	lb $t0, 1($s0)
	sb $t0, 1($s1) 
	ori $t0, $zero, 32
	sb $t0, 2($s1)

	or $a0, $0, $s0
	jal Month
	# t0 = (MM - 1) * 4
	addi $v0, $v0, -1
	sll $t0, $v0, 2
	la $a0, month_short
	add $a0, $a0, $t0
	addi $a1, $s1, 3
	addi $a2, $zero, 3
	jal StrCpy

	ori $t0, $zero, 44
	sb $t0, 6($s1)
	ori $t0, $zero, 32
	sb $t0, 7($s1)

	addi $a0, $s0, 6
	addi $a1, $s1, 8
	ori $a2, $zero, 4
	jal StrCpy
Convert_Return:
	or $a0, $0, $s1
	or $a1, $0, $s0
	ori $a2, $0, 256
	jal StrCpy
	or $v0, $0, $s0
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra
EndConvert:


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


j EndDate
Date:
	addiu $t0, $a3, 9
	ori $t1, $0, 0
	or $t2, $0, $a2
	ori $t4, $0, 10
Date_InitLoop:
	ori $t3, $0, 5
Date_Loop:
	beq $t3, $0, Date_EndLoop
	div $t2, $t4
	mflo $t2
	mfhi $t5
	addiu $t5, $t5, 48
	sb $t5, 0($t0)
	addiu $t0, $t0, -1
	addiu $t3, $t3, -1
	j Date_Loop
Date_EndLoop:
	bne $t1, $0, Date_Return
	ori $t1, $0, 1000
	mult $a0, $t1
	mflo $t2
	addu $t2, $t2, $a1
	j Date_InitLoop
Date_Return:
	sb $0, 10($a3)
	ori $t0, $0, 47
	sb $t0, 2($a3)
	sb $t0, 5($a3)
	or $v0, $0, $a3
	jr $ra
EndDate:


j EndScanInt
ScanInt:
	ori $v0, $0, 5
	syscall
	ori $v1, $0, 0
	jr $ra
EndScanInt:


j EndScanStr
ScanStr:
	ori $a1, $0, 256
	ori $v0, $0, 8
	syscall
	or $v0, $0, $a0
	ori $v1, $0, 0
	jr $ra
EndScanStr:


j EndMain
Main:
	addiu $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)

	jal Malloc
	sw $v0, 16($sp)

	ori $v0, $0, 4
	la $a0, input_day
	syscall
Main_LoopDay:
		jal ScanInt
		or $s0, $0, $v0
		beq $v1, $0, Main_EndLoopDay
		ori $v0, $0, 4
		la $a0, input_error
		syscall
		j Main_LoopDay
Main_EndLoopDay:

	ori $v0, $0, 4
	la $a0, input_month
	syscall
Main_LoopMonth:
		jal ScanInt
		or $s1, $0, $v0
		beq $v1, $0, Main_EndLoopMonth
		ori $v0, $0, 4
		la $a0, input_error
		syscall
		j Main_LoopDay
Main_EndLoopMonth:

	ori $v0, $0, 4
	la $a0, input_year
	syscall
Main_LoopYear:
		jal ScanInt
		or $s2, $0, $v0
		beq $v1, $0, Main_EndLoopYear
		ori $v0, $0, 4
		la $a0, input_error
		syscall
		j Main_LoopYear
Main_EndLoopYear:

	or $a0, $0, $s0
	or $a1, $0, $s1
	or $a2, $0, $s2
	lw $a3, 16($sp)
	jal Date

	ori $v0, $0, 4
	la $a0, menu
	syscall

	ori $v0, $0, 4
	la $a0, input_choice
	syscall
Main_LoopChoice:
		jal ScanInt
		or $s0, $0, $v0
		slt $t0, $s0, $0
		or $t0, $t0, $v1
		ori $t1, $0, 6
		slt $t1, $t1, $s0
		or $t0, $t0, $t1
		beq $t0, $0, Main_EndLoopChoice
		ori $v0, $0, 4
		la $a0, input_error
		syscall
		j Main_LoopChoice
Main_EndLoopChoice:

	addiu $s0, $s0, 1
	sll $s0, $s0, 2
	jal Main_Tmp
Main_Tmp:
	addu $t0, $ra, $s0
	jr $t0
	j Main_C1
	j Main_C2
	j Main_C3
	j Main_C4
	j Main_C5
	j Main_C6
Main_C1:
	ori $v0, $0, 4
	la $a0, result
	syscall
	lw $a0, 16($sp)
	syscall
	j Main_EndSwitch
Main_C2:
Main_C3:
	lw $a0, 16($sp)
	jal WeekDay
	or $t0, $0, $v0
	ori $v0, $0, 4
	la $a0, result
	syscall
	or $a0, $0, $t0
	syscall
	j Main_EndSwitch
Main_C4:
Main_C5:
Main_C6:
Main_EndSwitch:

	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addiu $sp, $sp, 32
EndMain:
