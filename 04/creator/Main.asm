format PE console 4.0 ; говорим компилятору FASM какой файл делать

entry Start

include 'win32a.inc'  ; подключаем библиотеку FASM-а


section '.data' data readable writable  ; секция данных
    outputFile       db "welders.txt", 0
    outFD            dd ?
    
    inpFirstnameMsg     db 'Enter firstname: ',  0
    inpSecondnameMsg    db 'Enter secondname: ', 0
    inpPatronymicMsg    db 'Enter patronymic: ', 0
    inpCategoryMsg      db 'Enter category: ',   10, 0
    
    strFmt db "%s", 0
    intFmt db "%d", 0
    
    intFieldSize=4
    strFieldSize=15
    structQuantity=3
    
    struct welder
        firstname    db strFieldSize dup (0)
        secondname   db strFieldSize dup (0)
        patronymic   db strFieldSize dup (0)
        category     dd 0
    ends
    
    w welder 0
    
    sizeOfWelder     dd sizeof.welder
    
    stdin               dd ?
    bytesRead           dd ?
    writedBytes         dd ?

  
section '.code' code readable executable ; секция кода
Start:
    cinvoke  GetStdHandle, STD_INPUT_HANDLE
    mov     [stdin], eax
    cld     ; DF = 0 (порядок обработки в сторону увеличения адресов)
    
    ; открываем файл
    invoke CreateFile, outputFile, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
    mov [outFD], eax
    
    cinvoke printf, intFmt, [sizeOfWelder]
    
    mov ebx, 0
    WelderIter:
            cinvoke printf, inpFirstnameMsg
            invoke ReadConsole, [stdin], w.firstname, strFieldSize, bytesRead, NULL
            cinvoke printf, strFmt, w.firstname
          
            
            cinvoke printf, inpSecondnameMsg
            invoke ReadConsole, [stdin], w.secondname, strFieldSize, bytesRead, NULL
            cinvoke printf, strFmt, w.secondname
             
            cinvoke printf, inpPatronymicMsg
            invoke ReadConsole, [stdin], w.patronymic, strFieldSize, bytesRead, NULL
            cinvoke printf, strFmt, w.patronymic
            
            cinvoke printf, inpCategoryMsg
            cinvoke scanf, intFmt, w.category
            cinvoke printf, intFmt, [w.category]
            
            invoke WriteFile, [outFD], w, [sizeOfWelder], writedBytes, NULL
            
            add ebx, 1
            cmp ebx, structQuantity
            jne WelderIter
            
    invoke CloseHandle, [outFD]     ; закрываем файл

Exit:
    invoke getch ; вызываем её для того чтоб программа не схлопнулась
    invoke exit, 0 ; говорим windows-у что у нас программа закончилась


section '.idata' import data readable    ; секция импорта
    library msvcrt,'MSVCRT.DLL',\
            kernel32,'KERNEL32.DLL'

    import kernel32,\
        GetStdHandle, 'GetStdHandle',\
        ReadConsole, 'ReadConsoleA',\
        CloseHandle, 'CloseHandle',\
        CreateFile, 'CreateFileA',\
        WriteFile, 'WriteFile'
        
    import  msvcrt,\
            getch, '_getch',\
            scanf,'scanf',\
            printf,'printf',\
            exit,'exit'
