section .data
    MINUS equ 0x2D
    NULL equ 0
    WHITESPACE equ 0x20
    NEWLINE equ 0xA

section .text

; strlen(&str)
; 1) rdi - address, location of str
; 
; Return
; qword, len of given str

global strlen
strlen:
    mov rax, 0
    jmp strLoop
incCount:
    inc rax
strLoop:
    cmp byte [rdi + rax], 0
    jne incCount
    ret
    
; strcat(&target, &src)
;
; Concatenates two null terminated strings
; 1) rdi - address, target str
; 2) rsi - address, src string

; Return
; &target

global strcat
strcat:
    mov r8, rdi; save target
    mov rdi, rsi;
    call strlen

    mov rcx, 0 ; pos counter
    xor rsi, rsi
    jmp checknull

concat:
    mov byte [r8 + rcx], sil
    inc rcx

checknull:
    mov sil, byte[rdi + rcx]
    cmp sil, NULL 

    jne concat

    mov byte[r8 + rcx], NULL ; NULL terminated
    mov rax, r8

    ret

; stoi(&str)
;
; Converts a null terminated string to a signed integer
; 1) rdi - address, src string
;
; Return
; dword, signed integer
global stoi
stoi:
    xor rcx, rcx ; push counter;
    xor rsi, rsi ; char container

    xor r8, r8 ; str pos
    mov r9, 10 ; base
    xor r10b, r10b ; sign indicator
    xor r11, r11 ; end num

    jmp stoiPushL

stoiNegative:
    mov r10b, 1

stoiPushL:
    mov sil, byte [rdi + r8];
    cmp sil, NULL
    je stoiPushLEnd

    inc r8

    cmp rsi, WHITESPACE ; ignore whitespaces
    je stoiPushL

    cmp rsi, NEWLINE ; ignore newlines
    je stoiPushL

    cmp rsi, MINUS ; detect a minus
    je stoiNegative

    inc rcx
    push rsi
    jmp stoiPushL

stoiPushLEnd:
    pop rsi
    sub rsi, 48
    mov r11d, esi
    dec rcx
    mov rax, 10

    cmp rcx, NULL
    je stoiPopLEnd

stoiPopL:
    mov r8, rax ; save current multiplier
    pop rsi

    sub esi, 48
    mul esi
    add r11d, eax

    mov rax, r8
    mul r9 ; get next power ten
    loop stoiPopL

stoiPopLEnd:
    ; check sign
    cmp r10b, 0
    je stoiEnd
    ;convert to twos complement
    not r11d
    inc r11d

stoiEnd:
    mov eax, r11d
    ret

; atoiu(digit, &str)  (unsigned, only base 10)
;
; Converts an unsigned integer to a null terminated string
; 1) edi - dword, digit to convert
; 2) rsi - address, location of str
; 
; Return:
; address of given str

global atoiu
atoiu:
    mov eax, edi
    mov rcx, 0 ; counter for popLoop
    mov r8, 10 ; base
    mov r9, 0  ; iStr pos

pushLoop:
    mov edx, 0
    div r8

    inc rcx
    push rdx

    cmp eax, 0
    jne pushLoop

popLoop:
    pop rax
    add al, 48
    mov byte[rsi + r9], al
    inc r9
    loop popLoop

    mov byte [rsi + r9], 0

    mov rax, rsi
    ret

; atoi(digit, &str) (signed, only base 10) 
;
; Converts a signed integer to a null terminated string
; 1) edi - dword, digit to convert
; 2) rsi - address, location of str
; 
; Return:
; address of given str

global atoi
atoi:
    mov eax, edi
    mov rcx, 0 ; counter for popLoop
    mov r8, 10 ; base
    mov r9, 0  ; iStr pos

    cmp eax, 0 ; check if negative
    jge pushLoop

    mov byte[rsi], MINUS
    inc r9

    sub eax, 1 ; convert to unsigned
    not eax
    jmp pushLoop
; cout 
;
; Prints a null terminated string to console
; 1) rdi - adress of null terminated string

global cout
cout:
    call strlen 
    inc rax
    mov rdx, rax ; number of bytes to write
    mov rsi, rdi ; & of string
    mov rdi, 1 ; file handle (stdout)
    mov rax, 1 ; write syscall
    syscall
    ret

; coutn 
;
; Adds a newline and prints a null terminated string
; (does so by pushing the char values on the stack, adding a newline + null)
; 1) rdi - adress of null terminated string

global coutn
coutn:
    xor rdx, rdx
    call strlen 
    push rbp
    mov rbp, rsp

    inc rax; +1 since newline
    sub rsp, rax ; strlen + 1

    push rbx

    mov rbx, rbp
    sub rbx, rax
    dec rax

coutnPushL:
    cmp rdx, rax
    je coutnEnd

    mov r8b, byte[rdi + rdx]

    mov byte[rbx + rdx], r8b
    inc rdx
    jmp coutnPushL

coutnEnd:
    mov byte[rbx + rdx], NEWLINE
    inc rdx
    mov byte[rbx + rdx], NULL

    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    ; rdx already done
    syscall

    pop rbx
    mov rsp, rbp
    pop rbp
    ret
