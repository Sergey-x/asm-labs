format PE console 4.0 ; ������� ����������� FASM ����� ���� ������

entry Start

include 'win32a.inc'  ; ���������� ���������� FASM-�


section '.data' data readable writable  ; ������ ������
    inputDimMsg             db 'Enter dimension: ', 0
    inputDFmt               db '%d', 0
    outputDFmt              db '%2d', 0
    outputMinValMsg         db 'Min elem: %d', 10, 0
    outputMinColMsg         db 'Min col: [%d], sum: %d', 10, 0
    outputMinRowMsg         db 'Min row: [%d], sum: %d', 10, 0
    errAllocMsg             db 'Allocation memory error!', 10, 0
    newLine                 db '', 10, 0
    space                   db ' ', 0
    HNDR        dd 100
    minElem     dd HNDR
    minRowIdx   dd ?
    minColIdx   dd ?
    dim         dd ?
    size        dd ?   
    minRowSum   dd ?
    minColSum   dd ?
    vector      dd ?
    FOUR        dd 4
    sizeV       dd ?
    sizeM       dd ?
    matrix      dd ?
  
  
section '.code' code readable executable ; ������ ����
Start:
    ; ��������� ����������� �������
    cinvoke printf, inputDimMsg
    cinvoke scanf, inputDFmt, dim
    
    ; ���-�� ��������� � �������
    mov eax, [dim]
    imul eax, [dim]
    mov [size], eax
    ; ����� ������ ��� �������
    imul eax, [FOUR]
    mov [sizeM], eax
    
    ; ����� ������ ��� �������
    mov eax, [dim]
    imul eax, [FOUR]
    mov [sizeV], eax
    
    ; ������� ������ 
    cinvoke malloc, sizeM
    test eax, eax
    jz FailedAlloc
    mov [matrix], eax
    
    ;�������� ������� 
    mov esi, 0
    FillMatrix:
        invoke rand
        idiv [HNDR]                 ; ������� �������� �� ������
        add edx, 2                  ; � �������� ������� �� 0! 
        mov [matrix + 4*esi], edx
        inc esi
        cmp esi, [size]
        jne FillMatrix

    ; �� ��� ������?)
    call ShowMatrix   
    
    ; ��������� ����������� �������� ������������� � ��������
    mov eax, [HNDR]
    imul [dim]
    mov [minRowSum], eax
    mov [minColSum], eax
    
    mov esi, 0
    ColIter:
        mov edi, 0
        mov ecx, 0  ; ����� �� ������
        RowIter:
            mov ebx, esi
            imul ebx, [dim]
            add ebx, edi
            
            mov eax, [matrix + 4*ebx]
            ; ���� ����������� ������� 
            cmp eax, [minElem]
            jge NotGreater 
            mov [minElem], eax   ; ����� ����������� �������
            NotGreater:

            add ecx, eax   ; ����� �� ������
                
            inc edi
            cmp edi, [dim]
            jne RowIter
        
        cmp ecx, [minRowSum]
        jge NotGreaterRow
        mov [minRowSum], ecx
        mov [minRowIdx], esi 
        NotGreaterRow:

        inc esi
        cmp esi, [dim]
        jne ColIter
    
    mov esi, 0
    ColIter2:
        mov edi, 0
        mov edx, 0  ; ����� �� �������
        RowIter2:
            mov ebx, edi
            imul ebx, [dim]
            add ebx, esi
            
            mov eax, [matrix + 4*ebx]
            add edx, eax   ; ����� �� �������
            
            inc edi
            cmp edi, [dim]
            jne RowIter2

        cmp edx, [minColSum]
        jge NotGreaterCol
        mov [minColSum], edx
        mov [minColIdx], esi 
        NotGreaterCol:
        
        inc esi
        cmp esi, [dim]
        jne ColIter2
    
    ; ������� ������ ��� �������
    cinvoke malloc, sizeV
    test eax, eax
    jz FailedAlloc
    mov [vector], eax
    
; ����������� �������    
cinvoke printf, outputMinValMsg, [minElem]
; ����������� ������    
cinvoke printf, outputMinRowMsg, [minRowIdx], [minRowSum]       
; ����������� �������    
cinvoke printf, outputMinColMsg, [minColIdx], [minColSum]        

    ; �������� ������ � ������������ � ��������
    mov esi, 0
    FillVector:
        mov ebx, [minRowIdx]
        imul ebx, [dim]
        add ebx, esi
        mov eax, [matrix + 4*ebx]
    
        mov ebx, esi
        imul ebx, [dim]
        add ebx, [minColIdx]
        mov edx, [matrix + 4*ebx]

        sub edx, eax
        mov eax, edx
        
        mov edx, 0
        cdq
        idiv [minElem]
        
        mov [vector + 4*esi], eax
        
        inc esi
        cmp esi, [dim]
        jne FillVector
    call FPrintVector             
    invoke getch
    
    ; ����������� ������ �������
    cinvoke free, [vector]
    test eax, eax
    jz FailedAlloc
    
    ; ����������� ������ �������
    cinvoke free, [matrix]
    test eax, eax
    jz FailedAlloc
         
Exit:
    invoke getch    ; �������� � ��� ���� ���� ��������� �� �����������
    invoke exit, 0  ; ������� windows-� ��� � ��� ��������� �����������

FailedAlloc:
    cinvoke printf, errAllocMsg
    invoke getch
    invoke exit, 1

ShowMatrix:
    mov esi, 0
    PrintRow:
        mov edi, 0
        PrintColumn:
            mov ebx, esi
            imul ebx, [dim]
            add ebx, edi
            
            cinvoke printf, outputDFmt, [matrix + 4*ebx]
            cinvoke printf, space
            
            inc edi
            cmp edi, [dim]
            jne PrintColumn

        cinvoke printf, newLine

        inc esi
        cmp esi, [dim]
        jne PrintRow
    cinvoke printf, newLine
    ret
    
FPrintVector:
    mov esi, 0
    VectorIter2:
        cinvoke printf, outputDFmt, [vector + 4*esi]
        cinvoke printf, space
        inc esi
        cmp esi, [dim]
        jne VectorIter2
    cinvoke printf, newLine    
    ret


section '.idata' import data readable    ; ������ �������
    library msvcrt,'MSVCRT.DLL',\
            kernel32,'KERNEL32.DLL'

    import kernel32,\
        GetStdHandle, 'GetStdHandle',\
        ReadConsole, 'ReadConsoleA'
        
    import  msvcrt,\
            getch, '_getch',\
            scanf,'scanf',\
            printf,'printf',\
            malloc, 'malloc',\
            free, 'free',\
            rand, 'rand',\
            exit,'exit'
