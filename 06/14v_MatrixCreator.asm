.eqv CALL_PRINT_INT 		1
.eqv CALL_PRINT_STRING 		4
.eqv CALL_READ_INT 		5
.eqv CALL_EXIT 			10
.eqv CALL_RAND_INT_RANGE	42
.eqv CALL_FCLOSE 		57
.eqv CALL_FWRITE 		64
.eqv CALL_FOPEN 		1024

.eqv WRITE_CREATE_FLAG 		1
.eqv SIZE_OF_WORD 		4
.eqv MAX_ELEM_VALUE 		99
.eqv MIN_ELEM_VALUE 		10


.data
mWidth:  			
	.word 0 		
mHeight: 			
	.word 0 		
mSize:
	.word 0
fd:
	.word 0
elem:
	.word 0

inpWStr:
	.asciz "Insert matrix width = "
inpHStr:
	.asciz "Insert matrix height = "
newLine:
	.asciz "\n"
outputFilename:
	.string "matrix.txt"
openFileErrMsg:
	.string "File matrix.txt doesn't open!"


.text
main:
	### Считываем w
	la a0, inpWStr
        	li a7, CALL_PRINT_STRING
        	ecall
        
	li a7, CALL_READ_INT
	ecall
	sw a0, mWidth, t0 
	
	### Считываем h
	la a0, inpHStr
     	li a7, CALL_PRINT_STRING
        ecall
        
	li a7, CALL_READ_INT
	ecall
	sw a0, mHeight, t0
	
	### Всего элементов в матрице (для цикла)
	lw t1, mWidth
	lw t2, mHeight
	mul t1, t1, t2
	sw t1, mSize, a2
	
	### Открываем файл
	la a0, outputFilename 
        li a1, WRITE_CREATE_FLAG 
        li a7, CALL_FOPEN
        ecall
        sw a0, fd, a2
        
        ### Проверка открыт ли файл
        lw t1, fd
        bltz t1, OpenFileErr
        
        
        ### Записываем ширину и высоту в файл
        lw a0, fd
        la a1, mWidth
        li a2, SIZE_OF_WORD
        li a7, CALL_FWRITE
        ecall
        
        lw a0, fd
        la a1, mHeight
        li a2, SIZE_OF_WORD
        li a7, CALL_FWRITE
        ecall
        
	#### Основной цикл
	lw t1, mSize
MainLoop:
	#li a1, MAX_ELEM_VALUE
	#li a2, 10
	#sub a1, a1, a2
	#li a7, CALL_RAND_INT_RANGE
	#ecall
	#li a2, 10
	#add a0, a0, a2
	#sw a0, elem, t0
	
	li a7, CALL_READ_INT
	ecall
	sw a0, elem, t0
	
	
	
	lw a0, fd
	### Записываем число в файл
	la a1, elem
        li a2, SIZE_OF_WORD
        li a7, CALL_FWRITE
        ecall
        
	# inc
	li t2, 1
	sub t1, t1, t2
	bgtz t1, MainLoop

FreeResources:
	### Закрываем файл
	lw a0, fd
        li a7, CALL_FCLOSE
        ecall

Exit:
	li a7, CALL_EXIT
	ecall

OpenFileErr:
	la a0, openFileErrMsg
        li a7, CALL_PRINT_STRING
        ecall
        j Exit
