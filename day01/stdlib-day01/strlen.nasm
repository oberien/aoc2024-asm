; INPUT:
; * rdi: CString
; OUTPUT:
; * rax: length without the trailing nul-byte
section .text
global strlen
strlen:
    push rbp
    mov rbp, rsp

    mov rsi, rdi

    xor ecx, ecx
    dec rcx
    xor eax,eax
    repne scasb

    sub rdi, rsi
    dec rdi
    mov rax, rdi

    pop rbp
    ret
