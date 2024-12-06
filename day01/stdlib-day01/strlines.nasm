; INPUT:
; * rdi: String
; OUTPUT:
; * rax: number of lines
section .text
global strlines
strlines:
    push rbp
    mov rbp, rsp
    %define string rdi

    mov rsi, [string+8]
    mov rdi, [string]

    xor eax, eax
    xor ecx, ecx
    .loop:
        cmp rcx, rsi
        jge .end
        cmp byte [rdi + rcx], `\n`
        lea rcx, [rcx + 1]
        jne .loop
        inc rax
        jmp .loop

    .end:
    pop rbp
    ret
