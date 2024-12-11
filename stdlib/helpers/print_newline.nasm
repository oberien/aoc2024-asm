section .text
print_newline:
    push rbp
    mov rbp, rsp

    rodata_cstring .ln, `\n`
    syscall_write(STDOUT, .ln, 1)

    pop rbp
    ret
