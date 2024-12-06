; INPUT:
; * rdi: String-ptr
; * rsi: index
; OUTPUT:
; * rdi: String-ptr
; * rsi: new index after number
; * rax: u64 number
section .text
atoi:
    push rbp
    mov rbp, rsp
    %define string rdi
    %define index rsi
    %define ptr rdx
    mov ptr, [string + String.ptr]

    xor eax, eax
    .loop:
        cmp index, [string + String.len]
        jae .end
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
; * rdi: String-ptr (not clobbered)
; * rsi: index after whitespace
; * rax: number of newline characters skipped
section .text
skip_whitespace:
    push rbp
    mov rbp, rsp
    %define string rdi
    %define index rsi
    %define ptr rdx
    mov ptr, [string + String.ptr]
    xor eax, eax

    .loop:
        cmp index, [string + String.len]
        jae .end
        cmp byte [ptr + index], ` `
        je .continue
        cmp byte [ptr + index], `\t`
        je .continue
        cmp byte [ptr + index], `\r`
        je .continue
        cmp byte [ptr + index], `\n`
        je .line
        cmp byte [ptr + index], `\v`
        je .continue
        cmp byte [ptr + index], `\f`
        je .continue
        jmp .end
        .line:
        inc rax
        .continue:
        inc index
        jmp .loop

    .end:
    pop rbp
    ret

; INPUT:
; * rdi: String-ptr
; * rsi: index
; * rdx: (out) Array<u64>
; OUTPUT:
; * rdi: String-ptr (not clobbered)
; * rsi: index after the line
section .text
parse_line_as_u64_array:
    push rbp
    mov rbp, rsp
    %define string r12
    %define index r13
    %define array r14
    push r12
    push r13
    push r14
    mov string, rdi
    mov index, rsi
    mov array, rdx

    .loop:
        cmp index, [string + String.len]
        jae .end

        mov rdi, string
        mov rsi, index
        call skip_whitespace
        mov index, rsi
        test rax, rax
        jnz .end

        call atoi
        mov index, rsi

        mov rdi, array
        mov rsi, rax
        call Array__push_u64

        jmp .loop

    .end:
    mov rdi, string
    mov rsi, index
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
