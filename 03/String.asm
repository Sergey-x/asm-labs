format PE console 4.0 ; говорим компил€тору FASM какой файл делать

entry Start

include 'win32a.inc'  ; подключаем библиотеку FASM-а


section '.data' data readable writable  ; секци€ данных
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
  
  
section '.code' code readable executable ; секци€ кода
Start:
    cinvoke  GetStdHandle, STD_INPUT_HANDLE
    mov     [stdin], eax
    
    cinvoke printf, inputTextMsg
    cinvoke ReadConsole, [stdin], text, 100, charsRead, NULL
    cld     ; DF = 0 (пор€док обработки в сторону увеличени€ адресов)
    
    ; коррекци€ длины строки (-2)
    mov eax, [charsRead]
    sub eax, 2
    mov [charsRead], eax
    
    ; инициализаци€ цикла
    mov ebx, 0             ; переменна€ цикла 
    mov eax, 0             ; длина самого длинного слова
    mov ecx, 0             ; длина слова
    mov edi, space         ; указатель на пробел
    mov esi, text          ; исходна€ строка
    TextIter:
        cmpsb
        jne commonSymbol
        ; пробел - новое слово
        cmp eax, ecx           ; сравниваем длины
        jg LongestWordLonger   ; старое длинее, увы и ах
        mov eax, ecx           ; Ќовое длинное слово!
        mov [longWord], esi
        LongestWordLonger:     
            mov ecx, -1         ; это дл€ нового слова
        commonSymbol:
            sub edi, 1      ; указатель на пробел измен€тьс€ не должен
            add ebx, 1      ; i++
            add ecx, 1      ; увеличение длины текущего слова
            cmp ebx, [charsRead]
            jne TextIter
    cmp eax, ecx           ; сравниваем длины дл€ последнего слова
    jg LongestWordLonger2   ; старое длинее, увы и ах
    mov eax, ecx           ; Ќовое длинное слово!
    mov [longWord], esi
    LongestWordLonger2:
        mov [maxWordLen], eax
    
    cinvoke printf, outputResultFormat, [maxWordLen]
    
    mov esi, [longWord]
    sub esi, [maxWordLen]
    mov ebx, 0             ; переменна€ цикла
    PrintLongestWord:
        add ebx, 1      ; i++
        cinvoke printf, outputCFormat, [esi]
        add esi, 1
        cmp ebx, [maxWordLen]
        jne PrintLongestWord
Exit:
    invoke getch ; вызываем еЄ дл€ того чтоб программа не схлопнулась
    invoke exit, 0 ; говорим windows-у что у нас программа закончилась


section '.idata' import data readable    ; секци€ импорта
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
