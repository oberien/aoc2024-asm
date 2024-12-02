section .text

extern printnumln, printcln, printc, println, exit, read_file, strlines, calloc, printqwordarray, skip_whitespace, atoi, strlen, sortqwordarray, write_all
global _start
_start:
    push rbp
    mov rbp, rsp
    %define localsize 0x60
    sub rsp, localsize
    %define input rbp-0x18
    %define numlines rbp-0x30
    %define array1 rbp-0x48
    %define array2 rbp-0x60
    push r12 ; argc
    push r13 ; argv

    ; argc
    mov r12, [rbp + 0x8]
    mov rdi, r12
    call printnumln

    ; argv
    lea r13, [rbp + 0x10]
    mov rdi, r13
    call printnumln

    ; argv[0]
    mov rdi, [r13]
    call printcln

    ; argv[1]
    mov rdi, [r13 + 0x8]
    call printcln

    mov rdi, [r13 + 0x8]
    call strlen

    ; read input file
    mov rdi, [r13 + 0x8]
    lea rsi, [input]
    call read_file

    lea rdi, [input]
    call println

    ; get number of lines = max number of numbers
    lea rdi, [input]
    call strlines
    mov [numlines], rax

    ; allocate arrays
    lea rdi, [array1]
    mov rsi, [numlines]
    mov rdx, 8
    call calloc
    lea rdi, [array2]
    mov rsi, [numlines]
    mov rdx, 8
    call calloc

    ; parse code
    lea rdi, [input]
    lea rsi, [array1]
    lea rdx, [array2]
    call parse

    ; debug print
    lea rdi, [array1]
    call printqwordarray
    lea rdi, [array2]
    call printqwordarray

    ; sort arrays
    lea rdi, [array1]
    call sortqwordarray
    lea rdi, [array1]
    call printqwordarray
    lea rdi, [array2]
    call sortqwordarray
    lea rdi, [array2]
    call printqwordarray

    ; PART 1

    section .rodata
        part1_string: db `part1: \0`
    section .text
    mov rdi, part1_string
    call printc
    ; compare arrays
    xor eax, eax
    mov rdx, [array1]
    mov rcx, [array2]
    mov r8, 0
    .loop:
        cmp r8, [array1+0x8]
        jae .end
        cmp r8, [array2+0x8]
        jae .end
        ; load & diff
        mov rdi, [rdx + r8*8]
        mov rsi, [rcx + r8*8]
        sub rdi, rsi
        ; abs
        mov rsi, rdi
        neg rsi
        cmovl rsi, rdi
        ; sum
        add rax, rsi
        inc r8
        jmp .loop
    .end:
    mov rdi, rax
    call printnumln

    mov rdi, 0
    call exit

    ; lul dead code
    add rsp, localsize
    pop r13
    pop r12
    pop rbp
    ret

; INPUT:
; * rdi: input String
; * rsi: array1 Array<byte>
; * rdx: array2 Array<byte>
parse:
    push rbp
    mov rbp, rsp
    %define localsize 0x10
    sub rsp, localsize
    %define index rbp-0x8
    %define array_index rbp-0x10
    push r12
    push r13
    push r14
    %define input r12
    %define array1 r13
    %define array2 r14
    mov input, rdi
    mov array1, rsi
    mov array2, rdx
    mov qword [index], 0
    mov qword [array_index], 0

    .loop:
        ; bounds-check
        mov rdi, [index]
        cmp rdi, [input+0x8]
        jae .end
        mov rdi, [array_index]
        cmp rdi, [array1+0x10]
        jae .end
        cmp rdi, [array2+0x10]
        jae .end
        ; parse first number
        mov rdi, input
        mov rsi, [index]
        call parse_number
        ; check if file end
        cmp [index], rsi
        je .end
        mov [index], rsi
        mov rdi, [array1]
        mov rsi, [array_index]
        mov [rdi + rsi*8], rax
        ; parse second number
        mov rdi, input
        mov rsi, [index]
        call parse_number
        mov [index], rsi
        mov rdi, [array2]
        mov rsi, [array_index]
        mov [rdi + rsi*8], rax
        inc qword [array_index]
        jmp .loop

    .end:
    ; store array lengths
    mov rdi, [array_index]
    mov [array1+0x8], rdi
    mov [array2+0x8], rdi
    pop r14
    pop r13
    pop r12
    add rsp, localsize
    pop rbp
    ret

; INPUT:
; * rdi: input String
; * rsi: index
; OUTPUT:
; * rax: number
; * rsi: new index after number
parse_number:
    push rbp
    mov rbp, rsp
    push r12
    %define input r12

    mov input, rdi
    ; skip whitespace
    call skip_whitespace
    mov rdi, input
    mov rsi, rax
    call atoi

    pop r12
    pop rbp
    ret
