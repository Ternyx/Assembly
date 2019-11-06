section .data
    NULL equ 0
    NEWLINE equ 10

section .bss
    strBuffer resb 11 ; ceil(log10(2^32)) + 1 (NULL)

section .text

extern stoi
extern atoi
extern coutn

global _start
_start:
    mov rbp, rsp; & of argc
    mov r12, qword [rsp] ; argc

    mov r13, r12
    dec r13 ; argc - 1 (ignore argv[0])

    cmp r13, 0 
    jle end

    mov rax, 4 ; (argc - 1) * 4 (since int array) 
    mul r13

    sub rsp, rax ; int[argc - 1] 
    push rbx
    mov rbx, rsp

    mov r14, 2 ; start from argv[1]
    xor rcx, rcx ; stack index 

pushL: ; convert null terminated string values to int array
    cmp r14, r12; r14 < argc
    ja startSort
    mov rdi, qword [rbp + r14 * 8] ; argv[r14 - 1]

    push rcx
    ; stoi (*char)
    call stoi ; null terminated string to int
    pop rcx

    mov dword [rbx + rcx * 4], eax ; put on stack
    
    inc r14
    inc rcx
    jmp pushL

startSort:

    mov rdi, rbx
    mov rsi, 0
    mov rdx, rcx
    dec rdx ; (hi inclusive)
    call qsort

    xor rcx, rcx

startPrint:
    cmp rcx, r13
    jae end

    mov edi, dword [rbx + rcx * 4]
    mov rsi, strBuffer
    push rcx
    call atoi
    pop rcx

    mov rdi, rax
    push rcx
    call coutn
    pop rcx

    inc rcx
    jmp startPrint

end:

    ; unpop 
    pop rbx
    mov rsp, rbp

    mov rax, 60
    mov rdi, 0
    syscall

; qsort(&int arr[], lo, hi) 
; sauce for algorithm - https://en.wikipedia.org/wiki/Quicksort#Hoare_partition_scheme
;
; 1) rdi - address of the signed int array
; 2) rsi - index of the lowest element (inclusive)
; 3) rdx - index of the highest element (inclusive)
;
; ret - address of the signed int array

global qsort
qsort:
    cmp rsi, rdx
    jae qend ; lo >= hi

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    mov r14, rdx

    call partition; partition(arr, lo, hi)
    mov r15, rax

    mov rdi, r12
    mov rsi, r13
    mov rdx, rax
    call qsort ; qsort(arr, lo, p)

    inc r15

    mov rdi, r12
    mov rsi, r15
    mov rdx, r14
    call qsort ; qsort(arr, p + 1, hi)

    pop r15
    pop r14
    pop r13
    pop r12

qend:
    mov rax, rdi
    ret

; partition(&int[], lo, hi)
;
; 1) rdi - address of the signed int array
; 2) rsi - index of the lowest element (inclusive)
; 3) rdx - index of the highest element (inclusive)
;
; ret - final index after partition

global partition
partition:
    ; get pivot 
    push rdx

    mov rax, rdx
    sub rax, rsi
    cqo ; rax -> rdx:rax
    mov rcx, 2
    div rcx ; rax/=2

    pop rdx

    mov rcx, rax
    add rcx, rsi
    mov eax, dword [rdi + rcx * 4] ; pivot

    mov r8, rsi
    dec r8

    mov r9, rdx
    inc r9

partitionLoop:

partitionLoopI:
    inc r8
    cmp dword [rdi + r8 * 4], eax
    jl partitionLoopI; arr[i] < pivot

partitionLoopJ:
    dec r9
    cmp dword [rdi + r9 * 4], eax
    jg partitionLoopJ; arr[j] > pivot

    cmp r8, r9 ; i >= j
    jge partitionEnd
    
    ;swap a[i] with a[j]
    mov r10d, dword [rdi + r8 * 4]
    mov r11d, dword [rdi + r9 * 4] 
    mov dword [rdi + r8 * 4], r11d
    mov dword [rdi + r9 * 4], r10d

    jmp partitionLoop

partitionEnd:
    mov rax, r9
    ret ; ret j
