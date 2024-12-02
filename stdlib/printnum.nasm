; INPUT:
; * rdi: number to print
section .text
global printnum
printnum:
    push rbp
    mov rbp, rsp
    ; 64bit integers have up to 19 decimal digits
    ; 8-byte stack alignment -> 24 bytes
    sub rsp, 0x30
    %define content rbp
    %define string rbp-0x30

    mov qword [string+0x10], 0x18
    mov qword [string+0x8], 0

    mov rax, rdi
    mov r10, 10
    .loop:
        xor edx, edx
        div r10
        add rdx, `0`
        inc qword [string+0x8]
        mov rdi, [string+0x8]
        neg rdi
        mov [content + rdi], dl
        test rax, rax
        jnz .loop

    mov rdi, [string+0x8]
    neg rdi
    lea rdi, [content + rdi]
    mov [string], rdi
    lea rdi, [string]
    call print

    add rsp, 0x30
    pop rbp
    ret
