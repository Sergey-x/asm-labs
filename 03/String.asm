format PE console 4.0 ; ������� ����������� FASM ����� ���� ������

entry Start

include 'win32a.inc'  ; ���������� ���������� FASM-�


section '.data' data readable writable  ; ������ ������
    inputTextMsg        db 'Enter string: ', 0
    outputResultFormat  db 'The length of the longest word = %d', 10, 0
    outputCFormat  db '%c', 0
    space    db ' ', 0Dh, 0Ah

    
section '.bss' readable writeable
    text           db 100 dup(0), 0
    stdin               dd ?
    charsRead           dd ?
    maxWordLen          dd ?
    longWord            dd ?
  
  
section '.code' code readable executable ; ������ ����
Start:
    cinvoke  GetStdHandle, STD_INPUT_HANDLE
    mov     [stdin], eax
    
    cinvoke printf, inputTextMsg
    cinvoke ReadConsole, [stdin], text, 100, charsRead, NULL
    cld     ; DF = 0 (������� ��������� � ������� ���������� �������)
    
    ; ��������� ����� ������ (-2)
    mov eax, [charsRead]
    sub eax, 2
    mov [charsRead], eax
    
    ; ������������� �����
    mov ebx, 0             ; ���������� ����� 
    mov eax, 0             ; ����� ������ �������� �����
    mov ecx, 0             ; ����� �����
    mov edi, space         ; ��������� �� ������
    mov esi, text          ; �������� ������
    TextIter:
        cmpsb
        jne commonSymbol
        ; ������ - ����� �����
        cmp eax, ecx           ; ���������� �����
        jg LongestWordLonger   ; ������ ������, ��� � ��
        mov eax, ecx           ; ����� ������� �����!
        mov [longWord], esi
        LongestWordLonger:     
            mov ecx, -1         ; ��� ��� ������ �����
        commonSymbol:
            sub edi, 1      ; ��������� �� ������ ���������� �� ������
            add ebx, 1      ; i++
            add ecx, 1      ; ���������� ����� �������� �����
            cmp ebx, [charsRead]
            jne TextIter
    cmp eax, ecx           ; ���������� ����� ��� ���������� �����
    jg LongestWordLonger2   ; ������ ������, ��� � ��
    mov eax, ecx           ; ����� ������� �����!
    mov [longWord], esi
    LongestWordLonger2:
        mov [maxWordLen], eax
    
    cinvoke printf, outputResultFormat, [maxWordLen]
    
    mov esi, [longWord]
    sub esi, [maxWordLen]
    mov ebx, 0             ; ���������� �����
    PrintLongestWord:
        add ebx, 1      ; i++
        cinvoke printf, outputCFormat, [esi]
        add esi, 1
        cmp ebx, [maxWordLen]
        jne PrintLongestWord
Exit:
    invoke getch ; �������� � ��� ���� ���� ��������� �� �����������
    invoke exit, 0 ; ������� windows-� ��� � ��� ��������� �����������


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
            exit,'exit'
