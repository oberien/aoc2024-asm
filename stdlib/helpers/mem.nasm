; INPUT:
; * rdi: destination
; * rsi: source
; * rdx: num bytes
%define memcpy(dst, src, num_bytes) call_3 memcpy, dst, src, num_bytes
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
%define memcmp(buffer1, buffer2, num_bytes) call_3 memcmp, buffer1, buffer2, num_bytes
section .text
memcmp:
    push rbp
    mov rbp, rsp
    mov rcx, rdx
    repe cmpsb
    pop rbp
    ret

; OUTPUT:
; * EFLAGS
fn memcmp_with_lens(buffer1: ptr, buffer1_len: u64, buffer2: ptr, buffer2_len: u64):
    vars
        reg minlen: u64
    endvars
    mov %$minlen, %$buffer1_len
    min %$minlen, %$buffer2_len
    memcmp(%$buffer1, %$buffer2, %$minlen)
    jnz .end
    mov rdi, %$buffer1_len
    cmp rdi, %$buffer2_len

    .end:
endfn

fn memxchg(buffer1: ptr, buffer2: ptr, num_bytes: u64)
    .loop:
        cmp %$num_bytes, 0
        jz .end
        mov al, [rdi]
        mov bl, [rsi]
        mov [rdi], bl
        mov [rsi], al
        add rdi, 1
        add rsi, 1
        sub %$num_bytes, 1
        jmp .loop

    .end:
endfn
