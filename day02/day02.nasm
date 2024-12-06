%include "../stdlib/stdlib.nasm"

section .text
main:
    push rbp
    mov rbp, rsp
    %define string rbp - String_size
    %define file rbp - String_size - File_size
    %define lines rbp - String_size - File_size - Array_size
    %define tmparray rbp - String_size - File_size - Array_size - Array_size
    sub rsp, String_size + File_size + Array_size + Array_size
    %define args r12
    %define index r13
    push r12
    push r13
    mov args, rdi

    ; Hello World

    lea rdi, [string]
    mov rsi, 1337
    call String__with_capacity

    rodata_cstring .s, `Hello, World!`
    lea rdi, [string]
    mov rsi, .s
    mov rdx, .s_len
    call String__append_raw

    lea rdi, [string]
    call String__println

    lea rdi, [string]
    call String__destroy

    ; Test Array<u64>
    lea rdi, [tmparray]
    mov rsi, u64_Rtti
    mov rdx, 10
    call Array__with_capacity

    lea rdi, [tmparray]
    mov rsi, 1337
    call Array__push_u64

    lea rdi, [tmparray]
    mov rsi, 42
    call Array__push_u64

    lea rdi, [tmparray]
    call Array__println

    lea rdi, [tmparray]
    call Array__sort
    lea rdi, [tmparray]
    call Array__println

    lea rdi, [tmparray]
    call Array__sort_desc
    lea rdi, [tmparray]
    call Array__println

    lea rdi, [tmparray]
    call Array__destroy

    ; read file passed as argument

    cmp qword [args + Array.len], 2
    jl .not_enough_args

    lea rdi, [file]
    mov rsi, [args + Array.ptr]
    mov rsi, [rsi + 0x8]
    call File__open

    lea rdi, [file]
    lea rsi, [string]
    call File__read_to_string

    lea rdi, [file]
    call File__destroy

    lea rdi, [string]
    call String__println

    lea rdi, [string]
    call String__count_lines

    lea rdi, [lines]
    mov rsi, Array_Rtti
    mov rdx, rax
    call Array__with_capacity

    ; parse input
    mov index, 0
    .loop:
        lea rdi, [tmparray]
        mov rsi, u64_Rtti
        mov rdx, 512
        call Array__with_capacity

        lea rdi, [string]
        mov rsi, index
        lea rdx, [tmparray]
        call parse_line_as_u64_array
        cmp index, rsi
        je .part1
        mov index, rsi

        lea rdi, [lines]
        lea rsi, [tmparray]
        call Array__push
        jmp .loop

    .part1:
    lea rdi, [tmparray]
    call Array__destroy

    lea rdi, [string]
    call String__destroy

    lea rdi, [lines]
    call Array__println

    lea rdi, [lines]
    call part1



    .end:
    mov rax, 0
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret

    .not_enough_args:
    panic `Not enough arguments -- provide the input file as first argument`

; INPUT:
; * rdi: Array<Array<u64>>
section .text
part1:
    push rbp
    mov rbp, rsp
    %define lines r12
    %define index r13
    %define count r14
    %define ptr r15
    push r12
    push r13
    push r14
    push r15
    mov ptr, [rdi + Array.ptr]

    rodata_cstring .part1, `part1: `
    mov rdi, .part1
    call cstring__print

    mov index, 0
    mov count, 0
    .loop:
        cmp index, [lines + Array.len]
        jae .end

        mov rdi, ptr
        call test_array_safe_part1
        add count, rax

        inc index
        mov rdi, [lines + Array.element_rtti]
        mov rdi, [rdi + Rtti.size]
        add ptr, rdi
        jmp .loop

    .end:
    mov rdi, count
    call u64__println

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; INPUT:
; * rdi: Array<u64> to check
; OUTPUT:
; * rax: 1 if the passed array is safe, 0 otherwise
section .text
test_array_safe_part1:
    push rbp
    mov rbp, rsp
    %define array r12
    %define direction r13
    %define index r14
    %define ptr r15
    push r12
    push r13
    push r14
    push r15
    mov array, rdi
    mov ptr, [array + Array.ptr]

    ; arrays with 0 or 1 element are ignored
    cmp qword [array + Array.len], 1
    jbe .unsafe

    mov index, 0
    .loop:
        mov rsi, [array + Array.len]
        dec rsi
        cmp index, rsi
        jae .safe

        mov rdi, [ptr]
        mov rsi, [ptr + 8]
        cmp rdi, rsi
        ja .above
        je .equal
        jb .below
        ud2

        .above:
        .equal:
        .below:

        inc index
        add ptr, 8
        jmp .loop

    .safe:
    mov rax, 1
    jmp .end

    .unsafe:
    mov rax, 0
    jmp .end

    .end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
