; INPUT:
; * rdi: String
section .text
global print
print:
    push rbp
    mov rbp, rsp

    mov rsi, rdi
    mov rdi, 1
    call write_all

    pop rbp
    ret


; INPUT:
; * rdi: CString
global dbgc
dbgc:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    %define cstring r12
    %define index r13
    mov cstring, rdi
    mov index, 0

    .loop:


    pop r13
    pop r12
    pop rbp
    ret