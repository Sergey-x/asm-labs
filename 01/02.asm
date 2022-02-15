%include 'myfunc.asm'


SECTION .data
inputXMsg db  'Please enter X: ', 0h
inputYMsg db  'Please enter Y: ', 0h
resultZMsg db '(X - Y) / (X * Y + 1) = ', 0h

formatin: db "%d", 0
formatout: db "%d", 10, 0


SECTION .bss
x: resb 32
y: resb 32
xysub: resb 32

SECTION .text
   global main 
   extern scanf 
   extern printf

main:
    ; save registers
    push ebx
    push ecx

    push eax
    ; print message to input x
    push inputXMsg
    call printf
    add esp, 4 ; remove parameters
    pop eax
    
    ; input x
    push x ; address of integer1 (second parameter)
    push formatin ; arguments are right to left (first parameter)
    call scanf
    add esp, 8 ; remove parameters
    
    ; print message to input y
    push eax
    push inputYMsg
    call printf
    add esp, 4 ; remove parameters
    pop eax
    
    ; input y
    push y ; address of integer1 (second parameter)
    push formatin ; arguments are right to left (first parameter)
    call scanf
    add esp, 8 ; remove parameters
    
    
    mov eax, [y]
    mov ebx, [x]
    
    sub ebx, [y]    ; ebx = X - Y
    imul long [x]   ; eax = X * Y
    
    add eax, 1      ; eax = X * Y + 1
    mov ecx, eax    ; ecx = X * Y + 1
    mov eax, ebx    ; eax = X - Y
    
    mov edx, 0
    idiv ecx        ; eax = (X - Y) / (X * Y + 1)
    
    ; print result message
    push eax
    push resultZMsg
    call printf
    add esp, 4 ; remove parameters
    pop eax
    
    ; print z
    push eax
    push formatout
    call printf
    add esp, 8
    
    ; restore registers
    pop ebx
    pop ecx
    
    call quit
