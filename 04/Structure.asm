format PE console 4.0 ; ������� ����������� FASM ����� ���� ������

entry Start

include 'win32a.inc'  ; ���������� ���������� FASM-�


section '.data' data readable writable  ; ������ ������    
    inputFile        db "welders.txt",     0
    outputFile       db "welders_upd.txt", 0
    inpFD            dd ?
    outFD            dd ?
       
    firstnameFmt     db "firstname = %s",  0
    secondnameFmt    db "secondname = %s", 0
    patronymicFmt    db "patronymic = %s", 0
    categoryFmt      db "category = %d;", 10, 10, 0
    
    strFmt db "%s", 0
    intFmt db "%d", 0
    
    strFieldSize=15
    intFieldSize=4
    structQuantity=3
    
    struct welder
        firstname    db strFieldSize dup (0)
        secondname   db strFieldSize dup (0)
        patronymic   db strFieldSize dup (0)
        category     dd 0
    ends
    
    sizeOfWelder     dd sizeof.welder
    welders          welder structQuantity dup (0)
    readBytes        dd ?
    writedBytes      dd ?
        
    macro printField formatString, fieldAddr, i
    {   
        mov eax, [sizeOfWelder]
        imul i
        add eax, fieldAddr 
        cinvoke printf, formatString, eax
    }
  
section '.code' code readable executable ; ������ ����
Start:
    ; ��������� ������� ����
    invoke CreateFile, inputFile, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0
    mov [inpFD], eax
    
    ; ��������� ������
    mov eax, [sizeOfWelder]
    imul eax, structQuantity    
    invoke ReadFile, [inpFD], welders, eax, readBytes, 0
    
    invoke CloseHandle, [inpFD]     ; ��������� ������� ����
    
    call FPrintData
    
    ; ������ ��������
    mov ebx, 0
    ChangeWelderIter:
        mov eax, ebx
        imul [sizeOfWelder]
        sub [welders.category + eax], 1
        
        add ebx, 1
        cmp ebx, structQuantity
        jne ChangeWelderIter
        
    call FPrintData
    
    ; ��������� �������� ����
    invoke CreateFile, outputFile, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
    mov [outFD], eax
    
    ; ���������� ���������� ��������
    mov ebx, 0
    WelderIter:
        mov eax, [sizeOfWelder]
        imul ebx
        add eax, welders
        invoke WriteFile, [outFD], eax, [sizeOfWelder], writedBytes, NULL
        
        add ebx, 1
        cmp ebx, structQuantity
        jne WelderIter

    invoke CloseHandle, [outFD]     ; ��������� �������� ����

Exit:
    cinvoke getch ; �������� � ��� ���� ���� ��������� �� �����������
    cinvoke exit, 0 ; ������� windows-� ��� � ��� ��������� �����������


FPrintData:
    mov ebx, 0
    printWelder:
        printField firstnameFmt,  welders.firstname,  ebx
        printField secondnameFmt, welders.secondname, ebx
        printField patronymicFmt, welders.patronymic, ebx
        
        mov eax, [sizeOfWelder]
        imul ebx
        add eax, welders.category 
        cinvoke printf, categoryFmt, [eax]
        
        inc ebx
        cmp ebx, structQuantity
        jne printWelder
    ret

section '.idata' import data readable    ; ������ �������
    library msvcrt,'MSVCRT.DLL',\
            kernel32,'KERNEL32.DLL'

    import kernel32,\
        GetStdHandle, 'GetStdHandle',\
        CloseHandle, 'CloseHandle',\
        CreateFile, 'CreateFileA',\
        WriteFile, 'WriteFile',\
        ReadFile, 'ReadFile'
        
    import  msvcrt,\
            getch, '_getch',\
            printf,'printf',\
            exit,'exit'
