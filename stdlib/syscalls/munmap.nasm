; INPUT
; * rdi: addr
; * rsi: length
%define syscall_munmap(addr, length) syscall_2 syscall_munmap, addr, length
section .text
syscall_munmap:
    mov rax, 11
    syscall
    jmp handleerror
