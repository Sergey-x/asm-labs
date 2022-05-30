.data
outputStrMsg: 
	.asciz "Lower case string: "
outputTruncatedStrMsg: 
	.asciz "Lower case truncated string: "
inpStr:
	.asciz	"     I'mTheFirstWordTruncateMe      IT       ShouLD be  A   LOWERcasE String\n"
firstSkipFlag:
	.word	0
skipFirstSpaceFlag:
	.word	0

.equ SPACE_ASCII_CODE, 32
.equ A_ASCII_CODE, 65
.equ Z_ASCII_CODE, 90


.text
.global	_start
_start:
	bl toLowerCase

	@ Напечатаем строку в нижнем регистре
	ldr r0, =outputStrMsg
	bl prints
	ldr r0, =inpStr
	bl prints
	
	bl skipSpaces
	bl skipAlphas
	bl skipSpaces
	mov r1, r0

	@ Напечатаем строку с обрезанным первым словом
	ldr r0, =outputTruncatedStrMsg
	bl prints
	@ldr r0, =inpStr
	mov r0, r1 
	bl prints


toLowerCase:
	stmfd	sp!, {r0-r2, lr}

	@ Поменяем регистр на нижний
	ldr r0, =inpStr
	bl strlen
	mov r2, r0
	ldr r0, =inpStr
	add r0, r0, r2
	@ Терминирующий нуль не обрабатываем, он не входит в длину строки
	sub r0, r0, #1
	
	@ Проверяем регистр из диапазона ascii
	1:
		ldrb r1, [r0]
		cmp r1, #A_ASCII_CODE
		blt 2f
	
		cmp r1, #Z_ASCII_CODE
		bgt 2f

		add r1, r1, #32
		strb r1, [r0]

	@ Итерируемся
	2:
		sub r0, r0, #1
		sub r2, r2, #1
		cmp r2, #0
		bgt 1b
	
	ldmfd	sp!, {r0-r2, pc}

skipSpaces:
	stmfd	sp!, {r1, lr}
	1:
		@ Пропускаем все первые пробелы
		ldrb r1, [r0]
		cmp r1, #SPACE_ASCII_CODE
		beq 2f
		bl 3f
	@ Итерируемся
	2:
		add r0, r0, #1
		bl 1b

	@ Выходим
	3:
	ldmfd	sp!, {r1, pc}

skipAlphas:
	stmfd	sp!, {r1, lr}
	1:
		@ Пропускаем все не пробельные символы
		ldrb r1, [r0]
		cmp r1, #SPACE_ASCII_CODE
		bne 2f
		bl 3f
	@ Итерируемся
	2:
		add r0, r0, #1
		bl 1b

	@ Выходим
	3:
	ldmfd	sp!, {r1, pc}

.end