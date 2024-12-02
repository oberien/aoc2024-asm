section .text
global print_newline
print_newline:
    push rbp
    mov rbp, rsp

    mov rdi, 1
    mov rsi, .ln
    mov rdx, 1
    call write

    pop rbp
    ret

.ln: db `\n`
