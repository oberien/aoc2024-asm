; INPUT:
; * rdi: String-ptr
; * rsi: index
; OUTPUT:
; * rdi: String-ptr
; * rsi: new index after number
; * rax: number qword
section .text
atoi:
    push rbp
    mov rbp, rsp
    %define string rdi
    %define index rsi
    %define ptr rdx
    mov ptr, [string]

    xor rax, rax
    .loop:
        cmp index, [string+0x8]
        jge .end
        xor ecx, ecx
        mov cl, [ptr+index]
        cmp cl, `0`
        jb .end
        cmp cl, `9`
        ja .end
        imul rax, 10
        sub cl, `0`
        add rax, rcx
        inc index
        jmp .loop

    .end:
    pop rbp
    ret

; INPUT:
; * rdi: String-ptr
; * rsi: index
; OUTPUT:
; * rdi: String-ptr
; * rsi: index after whitespace
section .text
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
    pop rbp
    ret

