; doesn't modify any registers in success-case
%macro assert_eq 2
    cmp qword %1, qword %2
    je %%noerror
    push rbp
    sub rsp, 0x10
    mov rbp, %2
    mov [rsp + 0x8], rbp
    mov rbp, %1
    mov [rsp], rbp
    mov rbp, [rsp + 0x10]
    call assert_eq_error
    %%noerror:

%endmacro

; 2 arguments on the stack
section .text
assert_eq_error:
    push rbp
    mov rbp, rsp

    mov r12, [rbp + 0x10]
    mov r13, [rbp + 0x18]
    rodata_cstring .s1, `assert_eq failed on \``
    mov rdi, .s1
    call cstring__print
    mov rdi, r12
    call u64__print
    rodata_cstring .s2, `\` == \``
    mov rdi, .s2
    call cstring__print
    mov rdi, r13
    call u64__print
    rodata_cstring .s3, `\`\n`
    mov rdi, .s3
    call cstring__print
    mov rdi, -1
    int3
    ud2
