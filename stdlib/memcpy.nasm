; INPUT:
; * rdi: destination
; * rsi: source
; * rdx: num bytes
section .text
memcpy:
    mov rcx, rdx
    rep movsb
    ret
