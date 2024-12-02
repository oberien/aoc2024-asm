; INPUT:
; * rdi: CString
section .text
global printc
printc:
    push rbp
    mov rbp, rsp
    push r12

    mov r12, rdi
    call strlen
    mov rdi, 1
    mov rsi, r12
    mov rdx, rax
    call write

    pop r12
    pop rbp
    ret