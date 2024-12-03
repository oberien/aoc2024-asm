; INPUT:
; * rdi: nul-terminated filename
; * rsi: flags
; * rdx: mode
; OUTPUT:
; * rax: file descriptor
section .data
global O_RDONLY, O_WRONLY, O_RDWR
    O_RDONLY: dq 0
    O_WRONLY: dq 1
    O_RDWR: dq 2

section .text
global open
open:
    push rbp
    mov rbp, rsp

    mov rax, 2
    syscall
    call handleerror

    pop rbp
    ret
