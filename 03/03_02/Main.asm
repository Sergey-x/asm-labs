format PE console 4.0 ; говорим компилятору FASM какой файл делать

entry Start

include 'win32a.inc'  ; подключаем библиотеку FASM-а


section '.data' data readable writable  ; секция данных
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
  
  
section '.code' code readable executable ; секция кода
Start:
    ; считываем размерность матрицы
    cinvoke printf, inputDimMsg
    cinvoke scanf, inputDFmt, dim
    
    ; кол-во элементов в матрице
    mov eax, [dim]
    imul eax, [dim]
    mov [size], eax
    ; объем памяти для матрицы
    imul eax, [FOUR]
    mov [sizeM], eax
    
    ; объем памяти для вектора
    mov eax, [dim]
    imul eax, [FOUR]
    mov [sizeV], eax
    
    ; выделим память 
    cinvoke malloc, sizeM
    test eax, eax
    jz FailedAlloc
    mov [matrix], eax
    
    ;заполним матрицу 
    mov esi, 0
    FillMatrix:
        invoke rand
        idiv [HNDR]                 ; большие значения не неужны
        add edx, 2                  ; и избегаем деления на 0! 
        mov [matrix + 4*esi], edx
        inc esi
        cmp esi, [size]
        jne FillMatrix

    ; че там внутри?)
    call ShowMatrix   
    
    ; первичные минимальные значения устанавливаем в максимум
    mov eax, [HNDR]
    imul [dim]
    mov [minRowSum], eax
    mov [minColSum], eax
    
    mov esi, 0
    ColIter:
        mov edi, 0
        mov ecx, 0  ; сумма по строке
        RowIter:
            mov ebx, esi
            imul ebx, [dim]
            add ebx, edi
            
            mov eax, [matrix + 4*ebx]
            ; ищем миинмальный элемент 
            cmp eax, [minElem]
            jge NotGreater 
            mov [minElem], eax   ; нашли миинмальный элемент
            NotGreater:

            add ecx, eax   ; сумма по строке
                
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
        mov edx, 0  ; сумма по столбцу
        RowIter2:
            mov ebx, edi
            imul ebx, [dim]
            add ebx, esi
            
            mov eax, [matrix + 4*ebx]
            add edx, eax   ; сумма по столбцу
            
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
    
    ; выделим память для вектора
    cinvoke malloc, sizeV
    test eax, eax
    jz FailedAlloc
    mov [vector], eax
    
; миинмальный элемент    
cinvoke printf, outputMinValMsg, [minElem]
; миинмальная строка    
cinvoke printf, outputMinRowMsg, [minRowIdx], [minRowSum]       
; миинмальный столбец    
cinvoke printf, outputMinColMsg, [minColIdx], [minColSum]        

    ; заполним вектор в соответствии с заданием
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
    
    ; освобождаем память вектора
    cinvoke free, [vector]
    test eax, eax
    jz FailedAlloc
    
    ; освобождаем память матрицы
    cinvoke free, [matrix]
    test eax, eax
    jz FailedAlloc
         
Exit:
    invoke getch    ; вызываем её для того чтоб программа не схлопнулась
    invoke exit, 0  ; говорим windows-у что у нас программа закончилась

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


section '.idata' import data readable    ; секция импорта
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
