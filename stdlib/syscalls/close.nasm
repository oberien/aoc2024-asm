; INPUT:
; * rdi: file descriptor
section .text
syscall_close:
    mov rax, 3
    syscall
    jmp handleerror
