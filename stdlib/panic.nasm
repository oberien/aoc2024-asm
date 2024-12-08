%macro panic 1
    %strcat x %1, `\n`
    rodata_cstring %%s, x
    mov rdi, %%s
    mov rsi, %%s_len
    call _panic
%endmacro

; INPUT:
; * rdi: raw str
; * rsi: len
section .text
_panic:
    push rbp
    mov rbp, rsp

    mov rdx, rsi
    mov rsi, rdi
    mov rdi, STDERR
    call write_all
    int3
    ud2
