; INPUT
; * rdi: addr
; * rsi: length
section .text
syscall_munmap:
    mov rax, 11
    syscall
    jmp handleerror
