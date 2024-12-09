; INPUT
; * rdi: addr
; * rsi: length
; * rdx: prot
; * r10: flags
; * r8: fd
; * r9: offset
%define PROT_READ 0x1
%define PROT_WRITE 0x2
%define PROT_EXEC 0x4
%define MAP_SHARED 0x01
%define MAP_PRIVATE 0x02
%define MAP_ANONYMOUS 0x20

%define syscall_mmap(addr, length, prot, flags, fd, offset) syscall_6 syscall_mmap, addr, length, prot, flags, fd, offset
section .text
syscall_mmap:
    mov rax, 9
    syscall
    jmp handleerror
