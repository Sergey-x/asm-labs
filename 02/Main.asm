format PE console 4.0 ; говорим компилятору FASM какой файл делать

entry Start

include 'win32a.inc'  ; подключаем библиотеку FASM-а


section '.data' data readable writable  ; секция данных
    inputMsgA db 'Enter a: ', 0
    inputMsgX db 'Enter x: ', 0
    inputFormat db '%lf', 0
    outputResult db 'y = (y1 - y2) = %f', 10, 0
    XE db 'x = %f  ', 0
    Y2E db 'y2 = %f  ', 10, 0
    Y1E db 'y1 = %f  ', 10, 0
    TWO dq 2.0
    ONE dq 1.0
    NEGONE dq -1.0
    ZERO dq 0.0
    
    
section '.bss' readable writeable
    a  dq ?
    x  dq ?
    y1  dq ?
    y2  dq ?
    y  dq ?
  
  
section '.code' code readable executable ; секция кода
Start:
    ; считываем у пользователя a, x
    ; ОСТОРОЖНО EAX, ECX!!!
    cinvoke printf, inputMsgA
    cinvoke scanf, inputFormat, a
    cinvoke printf, inputMsgX
    cinvoke scanf, inputFormat, x
    
    ; Проверить на наличие отложенных незамаскированных исключений и инициализировать FPU
    finit

    mov ecx, 0
    
    ; loop 0-9
    MainLoop:
        push ecx ; save
        
        EvalY1:
            fld qword ptr x     ; st0 = x
            fmul qword ptr TWO  ; st0 = 2*x
            fstp qword ptr y1   ; y1 = 2*x
            
            fld qword ptr x
            fld qword ptr TWO
            fcomi st1
            fstp qword ptr TWO
            fstp qword ptr x
            fld qword ptr y1
            ja xLessEq2
            jmp xMore2
            
            xMore2:
                fadd qword ptr a ; y1 = 2*x + a
                jmp endy1
            xLessEq2:
                fadd qword ptr ONE   ; y1 = 2*x + 1
            endy1:
                fstp qword ptr y1
                push ecx
                cinvoke printf, XE, dword[x], dword[x+4]
                pop ecx
                push ecx
                cinvoke printf, Y1E, dword[y1], dword[y1+4]
                pop ecx               

        EvalY2:
            fld qword ptr x
            fld qword ptr ZERO
            fcomi st1
            fstp qword ptr ZERO
            fstp qword ptr x
            ja xLessEqZero
            jmp xMoreZero
            
            xLessEqZero:
                fld qword ptr a
                fsub qword ptr ONE  ; y2 = a - 1  
                jmp endy2
            xMoreZero:
                fld qword ptr x
                fadd qword ptr ONE ; y2 = x + 1
            endy2:
                fstp qword ptr y2
                push ecx
                cinvoke printf, XE, dword[x], dword[x+4]
                pop ecx
                push ecx
                cinvoke printf, Y2E, dword[y2], dword[y2+4]
                pop ecx
         
        ; eval y = y1- y2
        fld qword ptr y1
        fsub qword ptr y2
        fstp qword ptr y
        
        ; PrintY
        push ecx
        cinvoke printf, outputResult, dword[y], dword[y+4]
        pop ecx
    
        pop ecx ; restore
        add ecx, 1
        cmp ecx, 10
        
        ; add 1.0 to x on iter  x, x+1, x+2
        fld qword ptr x
        fadd qword ptr ONE
        fstp qword ptr x
        
        jne MainLoop      

Exit:
    invoke getch ; вызываем её для того чтоб программа не схлопнулась
    invoke exit, 0 ; говорим windows-у что у нас программа закончилась


section '.idata' import data readable    ; секция импорта
    library msvcrt,'MSVCRT.DLL',\
            kernel32,'KERNEL32.DLL'

    import  msvcrt,\
            getch, '_getch',\
            scanf,'scanf',\
            printf,'printf',\
            exit,'exit'
