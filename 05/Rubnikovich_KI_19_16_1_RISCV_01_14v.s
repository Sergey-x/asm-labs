.eqv CALL_PRINT_INT 		1
.eqv CALL_PRINT_STRING 		4
.eqv CALL_READ_INT 		5
.eqv CALL_EXIT 			10

.eqv FOUR			4
.eqv ITERATIONS 		10


.data
a:  			
	.word 0 		
x: 			
	.word 0 		
y1:
	.word 0
y2:
	.word 0
y:
	.word 0

inpAStr:
	.asciz "Insert a = "
inpXStr:
	.asciz "Insert x = "
newLine:
	.asciz "\n"	
xFmtStr:
	.asciz "x = "
y1FmtStr:
	.asciz "y1 = "
y2FmtStr:
	.asciz "y2 = "
yFmtStr:
	.asciz "y = "
newLine2:
	.asciz "\n\n"


.text
main:
	### Считываем a
	la a0, inpAStr
        li a7, CALL_PRINT_STRING
        ecall
        
	li a7, CALL_READ_INT
	ecall
	sw a0, a, a2 
	
	### Считываем x
	la a0, inpXStr
        li a7, CALL_PRINT_STRING
        ecall
        
	li a7, CALL_READ_INT
	ecall
	sw a0, x, a2
	
	
	#### Основной цикл
	li t1, ITERATIONS
MainLoop:
	#### Сразу выведем x
	la a0, xFmtStr
        li a7, CALL_PRINT_STRING
        ecall
        
	lw a0, x
        li a7, CALL_PRINT_INT
        ecall
	
	la a0, newLine
        li a7, CALL_PRINT_STRING
        ecall
        # ----------------------
	
	#### start y1 ========================
	lw t2, x
	li t3, FOUR
	ble t2, t3, xLessEqualThanFour
	
	lw t3, a
	sub t2, t2, t3		# y1 = x - a
	j y1Pass
	xLessEqualThanFour:
		mul t2, t2, t3  # y1 = x - a
	
	y1Pass:
	sw t2, y1, a2
	# end y1 ==============================
	
		
	#### Выведем y1
	la a0, y1FmtStr
        li a7, CALL_PRINT_STRING
        ecall
        
	lw a0, y1
        li a7, CALL_PRINT_INT
        ecall
	
	la a0, newLine
        li a7, CALL_PRINT_STRING
        ecall
        # ----------------------
        
	#### start y2 ========================
	# проверяем на четность
	lw t2, x
	li t3, 2
	rem t2, t2, t3
	beqz t2, xEven
	
	li t2, 7		# y2 = 7
	j y2Pass
	xEven:
		lw t2, x
		li t3, 2
		div t2, t2, t3  # y2 = x/2
		lw t3, a
		add t2, t2, t3  # y2 = x/2 + a 
	y2Pass:
		
	sw t2, y2, a2
	# end y2 ==============================
	
	#### Выведем y2
	la a0, y2FmtStr
        li a7, CALL_PRINT_STRING
        ecall
        
	lw a0, y2
        li a7, CALL_PRINT_INT
        ecall
	
	la a0, newLine
        li a7, CALL_PRINT_STRING
        ecall
        # ----------------------
        

	# y = 
	lw t2, y1
	lw t3, y2
	add t2, t2, t3
	sw t2, y, a2
	
	
	#### Выведем y
	la a0, yFmtStr
        li a7, CALL_PRINT_STRING
        ecall
        
	lw a0, y
        li a7, CALL_PRINT_INT
        ecall
	
	la a0, newLine2
        li a7, CALL_PRINT_STRING
        ecall
        # ----------------------
	
	# нарастим x 
	lw t2, x
	li t3, 1
	add t2, t2, t3
	sw t2, x, a2
	
	#
	li t2, 1
	sub t1, t1, t2
	bgtz t1, MainLoop

Exit:
	li a7, CALL_EXIT
	ecall
