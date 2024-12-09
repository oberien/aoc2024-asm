; INPUT:
; * rdi: nul-terminated filename
; * rsi: flags
; * rdx: mode
; OUTPUT:
; * rax: file descriptor
%define O_RDONLY 0
%define O_WRONLY 1
%define O_RDWR 2

%define syscall_open(filename, flags, mode) syscall_3 syscall_open, filename, flags, mode
section .text
syscall_open:
    mov rax, 2
    syscall
    jmp handleerror
