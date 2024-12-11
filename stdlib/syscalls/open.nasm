; INPUT:
; * rdi: nul-terminated filename
; * rsi: flags
; * rdx: mode
; OUTPUT:
; * rax: file descriptor
O_RDONLY equ 0
O_WRONLY equ 1
O_RDWR equ 2

%define syscall_open(filename, flags, mode) syscall_3 syscall_open, filename, flags, mode
section .text
syscall_open:
    mov rax, 2
    syscall
    jmp handleerror
