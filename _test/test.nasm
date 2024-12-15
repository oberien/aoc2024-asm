%include "../stdlib/stdlib.nasm"
%include "test_array.nasm"

section .text
main:
    push rbp
    mov rbp, rsp

    call hello_world
    call test_if
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


fn test_if_internal(val: u64 = rdi):
    if (rdi < 5):
        if (rdi >= 3):
            mov rax, 0
        else:
            mov rax, 1
        endif
    else:
        mov rax, 3
        if (rdi > 10):
            mov rax, 2
        endif
    endif
endfn

fn test_if():
    test_if_internal(-1)
    assert_eq rax, 1
    test_if_internal(2)
    assert_eq rax, 1
    test_if_internal(3)
    assert_eq rax, 0
    test_if_internal(4)
    assert_eq rax, 0
    test_if_internal(5)
    assert_eq rax, 3
    test_if_internal(7)
    assert_eq rax, 3
    test_if_internal(12)
    assert_eq rax, 2
    rodata_cstring .s, `test_if completed`
    cstring__println(.s)
endfn
