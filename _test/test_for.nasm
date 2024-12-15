fn sum_until_for(until: u64 = rdi):
    xor eax, eax
    for (rcx = 0, rcx < rdi, inc rcx):
        add rax, rcx
    endfor
endfn

fn test_for():
    sum_until_for(5)
    assert_eq rax, 10
    sum_until_for(10)
    assert_eq rax, 45
    rodata_cstring .s, `test_for completed`
    cstring__println(.s)
endfn
