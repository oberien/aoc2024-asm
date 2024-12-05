; INPUT:
; * rdi: Array<qword>
section .text
printqwordarray:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    %define array r12
    %define ptr r13
    %define index r14
    mov array, rdi
    mov ptr, [array]
    mov index, 0

    mov rdi, 1
    mov rsi, square_paren_open
    mov rdx, 1
    call write

    .loop:
        cmp index, [array+0x8]
        jae .end
        ; print number
        mov rdi, [ptr + index * 0x8]
        call printnum
        ; print comma
        mov rdi, 1
        mov rsi, comma
        mov rdx, 1
        call write
        inc index
        jmp .loop

    .end:
    mov rdi, 1
    mov rsi, square_paren_close
    mov rdx, 1
    call write
    call print_newline

    pop r14
    pop r13
    pop r12
    pop rbp
    ret

section .rodata
    square_paren_open: db `[`
    square_paren_close: db `]`
    comma: db `,`
