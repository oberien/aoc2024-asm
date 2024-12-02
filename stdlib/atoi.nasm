; INPUT:
; * rdi: input String
; * rsi: index
; OUTPUT:
; * rax: number qword
; * rsi: new index after number
section .text
global atoi
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

