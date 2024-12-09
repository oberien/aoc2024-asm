; INPUT:
; * rdi: file descriptor
%define syscall_close(fd) syscall_1 syscall_close, fd
section .text
syscall_close:
    mov rax, 3
    syscall
    jmp handleerror
