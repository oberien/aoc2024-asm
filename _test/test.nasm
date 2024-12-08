%include "stdlib.nasm"
%include "test_array.nasm"

section .text
main:
    push rbp
    mov rbp, rsp

    call hello_world
    call test_array

    pop rbp
    ret

hello_world:
    push rbp
    mov rbp, rsp
    %define string rbp - String_size
    sub rsp, String_size

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

    mov rsp, rbp
    pop rbp
    ret
