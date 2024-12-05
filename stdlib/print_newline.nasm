section .text
print_newline:
    push rbp
    mov rbp, rsp

    rodata_cstring .ln, `\n`
    mov rdi, STDOUT
    mov rsi, .ln
    mov rdx, 1
    call syscall_write

    pop rbp
    ret
