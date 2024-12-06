; INPUT:
; * rdi: destination
; * rsi: source
; * rdx: num bytes
section .text
memcpy:
    push rbp
    mov rbp, rsp
    mov rcx, rdx
    rep movsb
    pop rbp
    ret

; INPUT:
; * rdi: buffer1
; * rsi: buffer2
; * rdx: num bytes
; OUTPUT:
; * EFLAGS
section .text
memcmp:
    push rbp
    mov rbp, rsp
    mov rcx, rdx
    repe cmpsb
    pop rbp
    ret

; INPUT:
; * rdi: buffer1
; * rsi: buffer1-len
; * rdx: buffer2
; * rcx: buffer2-len
; OUTPUT:
; * EFLAGS
memcmp_with_lens:
    push rbp
    mov rbp, rsp
    %define buffer1 r12
    %define buffer1_len r13
    %define buffer2 r14
    %define buffer2_len r15
    multipush r12, r13, r14, r15
    mov buffer1, rdi
    mov buffer1_len, rdi
    mov buffer2, rdx
    mov buffer2_len, rcx

    mov rdi, buffer1
    mov rsi, buffer2
    mov rdx, buffer1_len
    min rdx, buffer2_len
    call memcmp
    jnz .end
    cmp buffer1_len, buffer2_len

    .end:
    multipop r12, r13, r14, r15
    pop rbp
    ret

; INPUT:
; * rdi: buffer1
; * rsi: buffer2
; * rdx: num bytes
section .text
memxchg:
    push rbp
    mov rbp, rsp

    .loop:
        test rdx, rdx
        jz .end
        mov al, [rdi]
        mov bl, [rsi]
        mov [rdi], bl
        mov [rsi], al
        add rdi, 1
        add rsi, 1
        sub rdx, 1
        jmp .loop

    .end:
    pop rbp
    ret
