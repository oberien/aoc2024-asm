%macro panic 1
    %strcat error_msg__ %1, `\n`
    rodata_cstring %%s, error_msg__
    %undef error_msg__
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
