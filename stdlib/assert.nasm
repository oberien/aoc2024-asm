; INPUT:
; * rdi: arg1
; * rsi: arg2
section .text
global assert_eq
assert_eq:
    cmp rdi, rsi
    jne .error
    ret

    .error:
        mov r12, rdi
        mov r13, rsi
        mov rdi, assert_eq_string1
        call printc
        mov rdi, r12
        call printnum
        mov rdi, assert_eq_string2
        call printc
        mov rdi, r13
        call printnum
        mov rdi, assert_eq_string3
        call printc
        mov rdi, -1
        call exit
        ud2

section .rodata
    assert_eq_string1: db `assert_eq failed on \`\0`
    assert_eq_string2: db `\` == \`\0`
    assert_eq_string3: db `\`\n\0`
