; INPUT:
; * rdi: file descriptor
; * rsi: buffer-pointer
; * rdx: buffer-len
STDIN equ 0
STDOUT equ 1
STDERR equ 2

%define syscall_write(fd, buffer, len) syscall_3 syscall_write, fd, buffer, len
section .text
syscall_write:
    mov rax, 1
    syscall
    jmp handleerror
