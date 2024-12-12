; u64 is a primitive
; u64 doesn't contain the Rtti itself

u64_size equ 8

; INPUT:
; * rdi: u64
; * rsi: radix
; * rdx: alphabet -- must have $rsi bytes
; * rcx: prefix
; * r8: prefix_len
section .text
u64__print_radix:
    push rbp
    mov rbp, rsp
    ; 64bit integers have up to 19 decimal digits
    ; 8-byte stack alignment -> 24 bytes
    sub rsp, 0x18
    %define content rbp
    %define number r12
    %define radix r13
    %define alphabet r14
    %define len rcx
    push r12
    push r13
    push r14
    mov number, rdi
    mov radix, rsi
    mov alphabet, rdx

    ; print prefix
    mov rdi, STDOUT
    mov rsi, rcx
    mov rdx, r8
    write_all(rdi, rsi, rdx)

    ; convert

    mov rax, number
    mov rcx, 0
    .loop:
        xor edx, edx
        div radix
        mov dl, [alphabet + rdx]
        inc len
        mov rdi, len
        neg rdi
        mov [content + rdi], dl
        test rax, rax
        jnz .loop

    mov rdi, len
    neg rdi
    lea rsi, [content + rdi]
    mov rdi, STDOUT
    mov rdx, len
    write_all(rdi, rsi, rdx)

    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret


fn u64__print(this: u64 = rdi):
    rodata_cstring .decbytes, `0123456789`
    mov rsi, 10
    mov rdx, .decbytes
    mov rcx, 0
    mov r8, 0
    call u64__print_radix
endfn

fn u64__printhex(this: u64 = rdi)
    rodata_cstring .hexprefix, `0x`
    rodata_cstring .hexbytes, `0123456789abcdef`
    mov rsi, 16
    mov rdx, .hexbytes
    mov rcx, .hexprefix
    mov r8, 2
    call u64__print_radix
endfn

section .text
u64__println:
    push rbp
    mov rbp, rsp
    call u64__print
    print_newline()
    pop rbp
    ret

section .text
u64__printhexln:
    push rbp
    mov rbp, rsp
    call u64__printhex
    print_newline()
    pop rbp
    ret

section .text
u64__cmp:
    push rbp
    mov rbp, rsp
    cmp rdi, rsi
    pop rbp
    ret

section .text
u64__clone_into:
    push rbp
    mov rbp, rsp
    panic `clone_into not applicable for u64`

section .text
u64__destroy:
    push rbp
    mov rbp, rsp
    panic `destroy not applicable for u64`
