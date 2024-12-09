; INPUT:
; * rdi: file descriptor
; * rsi: buffer-pointer
; * rdx: buffer-len
%define STDIN 0
%define STDOUT 1
%define STDERR 2

%define syscall_write(fd, buffer, len) syscall_3 syscall_write, fd, buffer, len
section .text
syscall_write:
    mov rax, 1
    syscall
    jmp handleerror
