; INPUT:
; * rdi: file descriptor
; * rsi: buffer-ptr
; * rdx: len
section .text
write_all:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    %define fd r12
    %define ptr r13
    %define len r14
    mov fd, rdi
    mov ptr, rsi
    mov len, rdx

    .loop:
        mov rdi, fd
        mov rsi, ptr
        mov rdx, len
        call syscall_write
        sub len, rax
        add ptr, rax
        test len, len
        jnz .loop

    pop r14
    pop r13
    pop r12
    pop rbp
    ret
