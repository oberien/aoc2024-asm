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

