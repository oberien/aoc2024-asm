; INPUT:
; * rdi: exit code
section .text
syscall_exit:
    mov rax, 60
    syscall
    ud2
