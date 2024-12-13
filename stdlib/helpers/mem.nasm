; INPUT:
; * rdi: destination
; * rsi: source
; * rdx: num bytes
fn memcpy(dst: ptr = rdi, src: ptr = rsi, num_bytes: u64 = rdx):
    mov rcx, %$num_bytes
    rep movsb
endfn

; INPUT:
; * rdi: buffer1
; * rsi: buffer2
; * rdx: num bytes
; OUTPUT:
; * EFLAGS
fn memcmp(buffer1: ptr = rdi, buffer2: ptr = rsi, num_bytes: u64 = rdx):
    ; cmpsb compares rsi with rdi, but we want to compare rdi to rsi
    mov rcx, rdi
    mov rdi, rsi
    mov rsi, rcx
    mov rcx, %$num_bytes
    repe cmpsb
endfn

; OUTPUT:
; * EFLAGS
fn memcmp_with_lens(buffer1: ptr = rdi, buffer1_len: u64, buffer2: ptr = rdx, buffer2_len: u64):
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

fn memxchg(buffer1: ptr = rdi, buffer2: ptr = rsi, num_bytes: u64 = rdx)
    .loop:
        test %$num_bytes, %$num_bytes
        jz .end
        mov al, [%$buffer1]
        mov cl, [%$buffer2]
        mov [%$buffer1], cl
        mov [%$buffer2], al
        add rdi, 1
        add rsi, 1
        sub %$num_bytes, 1
        jmp .loop

    .end:
endfn
