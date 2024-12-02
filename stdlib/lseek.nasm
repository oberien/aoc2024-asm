; INPUT:
; * rdi: file descriptor
; * rsi: offset
; * rdx: whence
; OUTPUT:
; * rax: new position
global SEEK_SET, SEEK_CUR, SEEK_END
section .data
    SEEK_SET: dq 0
    SEEK_CUR: dq 1
    SEEK_END: dq 2

section .text
global lseek
lseek:
    push rbp
    mov rbp, rsp

    mov rax, 8
    syscall
    call handleerror

    pop rbp
    ret