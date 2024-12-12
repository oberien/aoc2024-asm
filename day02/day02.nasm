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
    String__println(rdi)

    lea rdi, [string]
    String__count_lines(rdi)

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
        parse_line_as_u64_array(rdi, rsi, rdx)
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
    String__destroy(rdi)

    lea rdi, [lines]
    call Array__println

    lea rdi, [lines]
    call part1

    lea rdi, [lines]
    call part2



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

    call count_safe
    push rax

    rodata_cstring .part1, `part1: `
    mov rdi, .part1
    call cstring__print

    pop rax
    mov rdi, rax
    call u64__println

    pop rbp
    ret

; INPUT:
; * rdi: Array<Array<u64>>
; OUTPUT:
; * rax: number of safe lists
section .text
count_safe:
    push rbp
    mov rbp, rsp
    %define lines r12
    %define index r13
    %define count r14
    %define ptr r15
    multipush r12, r13, r14, r15
    mov lines, rdi
    mov ptr, [lines + Array.ptr]
    check_rtti rdi, Array
    check_rtti ptr, Array

    mov index, 0
    mov count, 0
    .loop:
        cmp index, [lines + Array.len]
        jae .end

        mov rdi, ptr
        call test_array_safe
        add count, rax

        inc index
        mov rdi, [lines + Array.element_rtti]
        mov rdi, [rdi + Rtti.size]
        add ptr, rdi
        jmp .loop

    .end:
    mov rax, count
    multipop r12, r13, r14, r15
    pop rbp
    ret

; INPUT:
; * rdi: Array<Array<u64>>
section .text
part2:
    push rbp
    mov rbp, rsp
    %define this r12
    %define index r13
    %define len r15
    %define count rbx
    multipush r12, r13, r14, r15, rbx
    mov this, rdi
    mov index, 0
    mov len, [this + Array.len]
    check_rtti this, Array
    mov rdi, [this + Array.ptr]
    check_rtti rdi, Array

    .loop:
        cmp index, len
        jae .end

        mov rdi, this
        mov rsi, index
        call Array__get
        mov rdi, rax
        call test_array_safe_part2
        add count, rax

        inc index
        jmp .loop

    .end:
    rodata_cstring .part2, `part2: `
    mov rdi, .part2
    call cstring__print

    mov rdi, count
    call u64__println

    multipop r12, r13, r14, r15, rbx
    pop rbp
    ret

; INPUT:
; * rdi: Array<u64>
; OUTPUT:
; * rax: safe=1 unsafe=0
section .text
test_array_safe_part2:
    push rbp
    mov rbp, rsp
    %define clone rbp - Array_size
    sub rsp, Array_size
    %define this r12
    %define index r13
    multipush r12, r13
    mov this, rdi
    mov index, 0

    .loop:
        cmp index, [this + Array.len]
        jae .unsafe

        mov rdi, this
        lea rsi, [clone]
        call Array__clone_into

        lea rdi, [clone]
        mov rsi, index
        call Array__remove

        lea rdi, [clone]
        call test_array_safe
        test rax, rax
        ja .safe
        inc index
        jmp .loop

    .unsafe:
    mov rax, 0
    jmp .end
    .safe:
    mov rax, 1
    jmp .end

    .end:
    multipop r12, r13
    mov rsp, rbp
    pop rbp
    ret

; INPUT:
; * rdi: Array<u64> to check
; OUTPUT:
; * rax: 1 if the passed array is safe, 0 otherwise
section .text
test_array_safe:
    push rbp
    mov rbp, rsp
    %define asc rbp - Array_size
    %define desc rbp - Array_size - Array_size
    sub rsp, Array_size + Array_size
    %define array r12
    %define index r13
    %define ptr r14
    multipush r12, r13, r14
    mov array, rdi

    ; arrays with 0 or 1 element are ignored
    cmp qword [array + Array.len], 1
    jbe .unsafe

    ; check if all elements are ascending
    mov rdi, array
    lea rsi, [asc]
    call Array__clone_into
    lea rdi, [asc]
    call Array__sort
    mov rdi, array
    lea rsi, [asc]
    call Array__cmp
    je .all_inc_or_dec

    ; check if all elements are descending
    mov rdi, array
    lea rsi, [desc]
    call Array__clone_into
    lea rdi, [desc]
    call Array__sort_desc
    mov rdi, array
    lea rsi, [desc]
    call Array__cmp
    je .all_inc_or_dec
    jmp .unsafe

    .all_inc_or_dec:
    lea rdi, [asc]
    call check_deltas
    test rax, rax
    jz .unsafe

    .safe:
    dbg `safe: `
    mov rdi, array
    call Array__println
    mov rax, 1
    jmp .end

    .unsafe:
    dbg `unsafe: `
    mov rdi, array
    call Array__println
    mov rax, 0
    jmp .end

    .end:
    multipop r12, r13, r14
    mov rsp, rbp
    pop rbp
    ret

; INPUT:
; * rdi: asc Array<u64>
; OUTPUT:
; * rax: safe=1, unsafe=0
section .text
check_deltas:
    push rbp
    mov rbp, rsp
    %define asc rdi
    %define len rsi
    %define ptr rdx
    %define index rcx
    mov len, [asc + Array.len]

    mov index, 0
    mov ptr, [asc + Array.ptr]
    .loop:
        mov r8, [asc + Array.len]
        dec r8
        cmp index, r8
        jae .safe

        ; check if 0 < diff <= 3
        mov r8, [ptr]
        mov r9, [ptr + 8]
        sub r9, r8
        cmp r9, 0
        jbe .unsafe
        cmp r9, 3
        ja .unsafe

        inc index
        add ptr, 8
        jmp .loop

    .safe:
    mov rax, 1
    jmp .end
    .unsafe:
    mov rax, 0

    .end:
    pop rbp
    ret
