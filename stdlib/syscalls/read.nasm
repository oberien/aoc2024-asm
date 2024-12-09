; INPUT:
; * rdi: file descriptor
; * rsi: buffer
; * rdx: num bytes
; OUTPUT:
; * rax: number of bytes read
%define syscall_read(fd, buffer, num_bytes) syscall_3 syscall_read, fd, buffer, num_bytes
section .text
syscall_read:
    mov rax, 0
    syscall
    jmp handleerror
