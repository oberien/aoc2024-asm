; INPUT:
; * rdi: exit code
%define syscall_exit(code) syscall_1 syscall_exit, code
section .text
syscall_exit:
    mov rax, 60
    syscall
    ud2
