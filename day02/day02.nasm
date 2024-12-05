%include "../stdlib/stdlib.nasm"

section .text
global _start
_start:
    push rbp
    mov rbp, rsp
    %define string rbp - String_size
    sub rsp, String_size + File_size
    %define file rbp - String_size - File_size
    sub rsp, String_size + File_size

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

    ; read file
    rodata_cstring .filename, `sample.txt`
    lea rdi, [file]
    mov rsi, .filename
    call File__open

    lea rdi, [file]
    lea rsi, [string]
    call File__read_to_string

    lea rdi, [file]
    call File__destroy

    lea rdi, [string]
    call String__println

    lea rdi, [string]
    call String__destroy

    mov rdi, 0
    call syscall_exit

    ; lul dead code
    mov rsp, rbp
    pop rbp
    ret
