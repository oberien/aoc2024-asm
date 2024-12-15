fn sum_until_while(until: u64 = rdi):
    xor eax, eax
    xor ecx, ecx
    while (rcx < rdi):
        add rax, rcx
        inc rcx
    endwhile
endfn

fn test_while():
    sum_until_for(5)
    assert_eq rax, 10
    sum_until_for(10)
    assert_eq rax, 45
    rodata_cstring .s, `test_while completed`
    cstring__println(.s)
endfn
