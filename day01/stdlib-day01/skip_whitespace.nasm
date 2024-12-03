; INPUT:
; * rdi: String
; * rsi: index
; OUTPUT:
; * rax: index after whitespace
section .text
global skip_whitespace
skip_whitespace:
    push rbp
    mov rbp, rsp
    %define string rdi
    %define index rsi
    %define ptr rdx
    mov ptr, [string]

    .loop:
        cmp index, [string+0x8]
        jge .end
        cmp byte [ptr + index], ` `
        je .continue
        cmp byte [ptr + index], `\t`
        je .continue
        cmp byte [ptr + index], `\r`
        je .continue
        cmp byte [ptr + index], `\n`
        je .continue
        cmp byte [ptr + index], `\v`
        je .continue
        cmp byte [ptr + index], `\f`
        je .continue
        jmp .end
        .continue:
        inc index
        jmp .loop

    .end:
    mov rax, index
    pop rbp
    ret