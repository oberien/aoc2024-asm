; INPUT:
; * rdi: file descriptor
; * rsi: buffer
; * rdx: num bytes
; OUTPUT:
; * rax: number of bytes read
section .text
syscall_read:
    mov rax, 0
    syscall
    jmp handleerror
