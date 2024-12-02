; INPUT:
; * rdi: file descriptor
; * rsi: buffer-pointer
; * rdx: buffer-len
section .text
global write
write:
    mov rax, 1
    syscall
    call handleerror
    ret

; INPUT:
; * rdi: file descriptor
; * rsi: Array<byte>
global write_all
write_all:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    %define fd r12
    %define array r13
    %define written r14
    %define ptr r15
    mov fd, rdi
    mov array, rsi
    mov written, 0
    mov ptr, [array]

    .loop:
        mov rdi, fd
        mov rsi, [array]
        mov rdx, [array+0x8]
        call write
        add written, rax
        add ptr, rax
        cmp written, [array+0x8]
        jl .loop

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
