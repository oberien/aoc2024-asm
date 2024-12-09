; INPUT:
; * rdi: file descriptor
; * rsi: offset
; * rdx: whence
; OUTPUT:
; * rax: new position
%define SEEK_SET 0
%define SEEK_CUR 1
%define SEEK_END 2

%define syscall_lseek(fd, offset, whence) syscall_3 syscall_lseek, fd, offset, whence
section .text
syscall_lseek:
    mov rax, 8
    syscall
    jmp handleerror
