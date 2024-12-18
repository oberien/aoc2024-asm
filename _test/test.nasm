%include "../stdlib/stdlib.nasm"
%include "test_array.nasm"
%include "test_if.nasm"
%include "test_for.nasm"
%include "test_while.nasm"

section .text
main:
    push rbp
    mov rbp, rsp

    call hello_world
    call test_if
    call test_for
    call test_while
    call test_array

    pop rbp
    ret

fn hello_world():
    vars
        local string: String
    endvars
    mov rdi, %$string.ptr

    lea rdi, [%$string]
    String__with_capacity(rdi, 1337)

    rodata_cstring .s, `Hello, World!`
    lea rdi, [%$string]
    String__append_raw(rdi, .s, .s_len)

    lea rdi, [%$string]
    String__println(rdi)

    lea rdi, [%$string]
    String__destroy(rdi)
endfn
