.eqv CALL_PRINT_INT 		1
.eqv CALL_PRINT_STRING 		4
.eqv CALL_MALLOC 		9
.eqv CALL_EXIT 			10
.eqv CALL_FCLOSE 		57
.eqv CALL_FREAD 		63
.eqv CALL_FOPEN 		1024

.eqv READ_ONLY_FLAG 		0
.eqv SIZE_OF_WORD 		4
.eqv MAX_ELEM_VALUE 		99
.eqv MIN_ELEM_VALUE 		0

.data
mWidth:  			
	.word 0 		
mHeight: 			
	.word 0 		
mSize:
	.word 0
mSizeInBytes:
	.word 0
fd:
	.word 0
elem:
	.word 0
matrix:
	.word 0
maxRowVector:
	.word 0
maxRowVectorElem:
	.word 0
maxRow:
	.word 0
minCol:
	.word 0

space:
	.asciz " "
dspace:
	.asciz "   "
newLine:
	.asciz "\n"
newLine2:
	.asciz "\n\n"
inputFilename:
	.string "matrix.txt"
openFileErrMsg:
	.string "File matrix.txt doesn't open!"
ResultMsg:
	.string "Result maxmin = "
StartGoodMsg:
	.string "\nFound good elem: "
RowIndexMsg:
	.string " row index ["
ColIndexMsg:
	.string "] col index ["
EndGoodMsg:
	.string "]\n"

.text
main:
	### ��������� ����
	la a0, inputFilename 
        li a1, READ_ONLY_FLAG 
        li a7, CALL_FOPEN
        ecall
        sw a0, fd, a2

        ### �������� ������ �� ����
        lw t1, fd
        bltz t1, OpenFileErr
      
      	li a2, SIZE_OF_WORD
      	
	### ��������� w
	lw a0, fd
	la a1, mWidth
	li a2, SIZE_OF_WORD
	li a7, CALL_FREAD
	ecall
	
	### ��������� h
	lw a0, fd
	la a1, mHeight
	li a2, SIZE_OF_WORD
	li a7, CALL_FREAD
	ecall
	
	### ����� ��������� � ������� (mem, cyc)
	lw a0, mWidth
	lw a1, mHeight
	mul a0, a0, a1
	sw a0, mSize, t0
	#  ������ ������� � ������
	li a1, SIZE_OF_WORD
	mul a0, a0, a1
	sw a0, mSizeInBytes, t0   # �������� ��� ����. ��������
        
	### ������� ������ ��� �������
	lw a0, mSizeInBytes
        li a7, CALL_MALLOC
        ecall
        sw a0, matrix, t0
        
	### ��������� ��� ������� �����
	lw a0, fd
	lw a1, matrix
	lw a2, mSizeInBytes
	li a7, CALL_FREAD
	ecall


	### ������� ������ ��� ������ ���������� ��������� ����� ()
	lw a0, mHeight
	li a1, SIZE_OF_WORD
	mul a0, a0, a1
        li a7, CALL_MALLOC
        ecall
        sw a0, maxRowVector, t0

############################################################
	li t1, 0
	PrintMatrixRowLoop:
		li a0, MIN_ELEM_VALUE
		sw a0, maxRow, t0 
	
		li t3, 0
		PrintMatrixColLoop:
			### ������ �������� ��� elem
			mv t0, t1
			lw t2, mWidth
			mul t0, t0, t2		# i*w
			add t0, t0, t3		# i*w + h
			li t2, SIZE_OF_WORD
			mul t0, t0, t2
		
			lw t2, matrix
			add t0, t0, t2
			### ������� elem
			mv a1, t0
        		lw a0, (a1)
			sw a0, elem, t0
		
			### ����� ������� elem
			lw a0, elem
			li a7, CALL_PRINT_INT
        		ecall
			la a0, space
        		li a7, CALL_PRINT_STRING
        		ecall
        	
        		# ���� ������������ ������� � ������
        		lw t0, elem
        		lw t2, maxRow
        		bgt t0, t2, FoundMax
        		j Pass
        		FoundMax:
        			mv a2, t0
        			sw a2, maxRow, t2

        		Pass:
        	
			# ���������
			li t4, 1
			add t3, t3, t4
			lw t4, mWidth
			blt t3, t4, PrintMatrixColLoop

		# ������� ������������ �������
		la a0, dspace
		li a7, CALL_PRINT_STRING
		ecall      	
		lw a0, maxRow
		li a7, CALL_PRINT_INT
		ecall	
		la a0, newLine
		li a7, CALL_PRINT_STRING
		ecall
            
    		# ��������� ��������� ������������ ������� � ������
    		li t2, SIZE_OF_WORD
    		mul t2, t2, t1		
    		lw t0, maxRowVector
    		add t2, t2, t0
    		
    		lw t0, maxRow
		sw t0, (t2)
        	# -------------------------------------------------

		# inc
		li t2, 1
		add t1, t1, t2
		lw t2, mHeight
		blt t1, t2, PrintMatrixRowLoop

		# �������� �� �������
		la a0, newLine
		li a7, CALL_PRINT_STRING
		ecall
############################################################
	li t1, 0
	FindMinRowIterLoop:
		li a0, MAX_ELEM_VALUE
		sw a0, minCol, t0 
	
		li t3, 0
		FindMinColIterLoop:
			### ������ �������� ��� elem
			lw t2, mWidth	
			mul t2, t2, t3		# mWidth * t3
			add t2, t2, t1		# (mWidth * t3 + t1)
			
			li t0, SIZE_OF_WORD
			mul t2, t2, t0		# (mWidth * t3 + t1) * 4
			
			lw t0, matrix
			add t2, t2, t0		# (mWidth * t3 + t1)) * 4 + matrix
			### ������� elem
        		lw a0, (t2)
			sw a0, elem, t0


        		# ���� ����������� ������� � �������
        		lw t0, elem
        		lw t2, minCol
        		bgt t2, t0, FoundMin
        		j Pass2
        		FoundMin:
        			mv a2, t0
        			sw a2, minCol, t2

        		Pass2:
        	
			# ���������
			li t4, 1
			add t3, t3, t4
			lw t4, mHeight
			blt t3, t4, FindMinColIterLoop

lw a0, minCol
li a7, CALL_PRINT_INT
ecall
la a0, space
li a7, CALL_PRINT_STRING
ecall    

		###=================================================	
		li t4, 0
		CompareMaxElemsLoop:
			### ������ �������� ��� maxRow[t4] � �������
			mv t2, t4
			li t0, SIZE_OF_WORD
			mul t2, t2, t0		# t4 * 4
			
			lw t0, maxRowVector
			add t2, t2, t0		# (t4 * 4) + matrix
			### ��� ��������� ������������ � ������
        		lw t0, (t2)  
			lw t2, minCol	# ��� ������� ��� �������
			
        		# ����������, ����� �������� )
        		beq t2, t0, EqualMaxRowAndMinCol
        		j Pass3
        		EqualMaxRowAndMinCol:
        			# �������� ���������
				la a0, StartGoodMsg
        			li a7, CALL_PRINT_STRING
        			ecall
        			
        			mv a0, t0
				li a7, CALL_PRINT_INT
				ecall
        			
        			la a0, RowIndexMsg
        			li a7, CALL_PRINT_STRING
        			ecall
        			
        			mv a0, t4
        			li a7, CALL_PRINT_INT
        			ecall
        			
        			la a0, ColIndexMsg
        			li a7, CALL_PRINT_STRING
        			ecall  
        			      	        					        			
        			mv a0, t3
       				li a7, CALL_PRINT_INT
        			ecall
        			
        			la a0, EndGoodMsg
        			li a7, CALL_PRINT_STRING
        			ecall  
        		Pass3:
        	
			# ���������
			li t2, 1
			add t4, t4, t2
			lw t2, mHeight
			blt t4, t2, CompareMaxElemsLoop
		
		###===============================================
			
		# inc
		li t2, 1
		add t1, t1, t2
		lw t2, mWidth
		blt t1, t2, FindMinRowIterLoop
############################################################
        	
CloseFile:
	### ��������� ����
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
