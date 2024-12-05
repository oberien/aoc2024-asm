; INPUT:
; * rdi: file descriptor
; * rsi: buffer-pointer
; * rdx: buffer-len
%define STDIN 0
%define STDOUT 1
%define STDERR 2

section .text
syscall_write:
    mov rax, 1
    syscall
    jmp handleerror
