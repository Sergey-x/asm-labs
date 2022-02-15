%include 'myfunc.asm'


SECTION .data
inputXMsg db  'Please enter X: ', 0h
inputYMsg db  'Please enter Y: ', 0h
resultZMsg db 'Z = (-X / Y) + Y^2 + 3 = ', 0h

formatin: db "%d", 0h
formatout: db "%d", 0Ah, 0h


SECTION .bss
x: resb 32
y: resb 32


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
    
    push eax
    ; print message to input y
    push inputYMsg
    call printf
    add esp, 4 ; remove parameters
    pop eax
    
    ; input y
    push y ; address of integer1 (second parameter)
    push formatin ; arguments are right to left (first parameter)
    call scanf
    add esp, 8 ; remove parameters
    
    
    mov eax, [x]
    mov ebx, [y]
    
    mov edx, 0
    idiv ebx        ; eax = X / Y
    neg eax         ; eax = -X / Y
    
    mov ecx, eax    ; ecx = -X / Y
    
    mov eax, [y]    ; eax = Y
    imul long [y]   ; eax = Y * Y

    add eax, 3      ; eax = Y * Y + 3
    add eax, ecx
    
    push eax
    ; print result message
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
