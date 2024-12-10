%macro qwordwrite 0
    sub rsp, 64
    %assign foo 0
    %rep 8
        mov [rsp+foo], r12
        mov rax, [rsp+foo]
        %assign foo foo+8
    %endrep
    add rsp, 64
%endmacro
%macro wordwrite 0
    sub rsp, 64
    %assign foo 0
    %rep 8
        mov [rsp+foo], r12w
        mov rax, [rsp+foo]
        %assign foo foo+8
    %endrep
    add rsp, 64
%endmacro
%macro pushsub 0
    %rep 8
        push r12w
        sub rsp, 6
        mov rax, [rsp]
    %endrep
    add rsp, 64
%endmacro
%macro subpush 0
    %rep 8
        sub rsp, 6
        push r12w
        mov rax, [rsp]
    %endrep
    add rsp, 64
%endmacro
%macro pushqword 0
    %rep 8
        push r12
        mov rax, [rsp]
    %endrep
    add rsp, 64
%endmacro

global _start
section .text
_start:
    mov r12, 1_000_000_000
    lea r13, [r12 - 250_000_000]
    .loop:
        qwordwrite
;        wordwrite
;        pushsub
;        subpush
;        pushqword
        cmp r12, r13
        je .enable
        dec r12
        jnz .loop
        ; exit
        mov rax, 60
        mov rdi, 0
        syscall
        ud2

        .enable:
            ; open
            mov rax, 2
            mov rdi, fifo_file
            mov rsi, 1
            mov rdx, 0
            syscall
            test rax, rax
            jl .error1
            ; write
            mov rdi, rax
            mov rax, 1
            mov rsi, enable_str
            mov rdx, enable_str_len
            syscall
            cmp rax, enable_str_len
            jl .error2
            dec r12
            jmp .loop

            .error1:
            push rax
            int3
            ud2
            .error2:
            push rbx
            int3
            ud2

section .rodata
    enable_str: db `enable\n`
    enable_str_len equ $ - enable_str
    fifo_file: db `perf_ctl.fifo\0`
    fifo_file_len equ $ - fifo_file
