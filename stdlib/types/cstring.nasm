; cstring is a primitive
; cstring doesn't contain the Rtti itself
; cstring is a pointer to a nul-terminated string

cstring_size equ 8

; keyword for searching: strlen
; OUTPUT:
; * rax: length without the trailing nul-byte
section .text
cstring__len:
    push rbp
    mov rbp, rsp

    mov rsi, rdi

    xor ecx, ecx
    dec rcx
    xor eax,eax
    repne scasb

    sub rdi, rsi
    dec rdi
    mov rax, rdi

    pop rbp
    ret

section .text
cstring__extract_value:
    push rbp
    mov rbp, rsp
    mov rax, [rdi]
    pop rbp
    ret

section .text
cstring__print:
    push rbp
    mov rbp, rsp
    push r12

    mov r12, rdi
    call cstring__len
    mov rdi, STDOUT
    mov rsi, r12
    mov rdx, rax
    call write_all

    pop r12
    pop rbp
    ret

section .text
cstring__println:
    push rbp
    mov rbp, rsp
    call cstring__print
    call print_newline
    pop rbp
    ret

section .text
cstring__cmp:
    push rbp
    mov rbp, rsp
    %define this r12
    %define other r13
    %define this_len r14
    %define other_len r15
    multipush r12, r13, r14, r15
    mov this, rdi
    mov other, rsi

    mov rdi, this
    call cstring__len
    mov this_len, rax

    mov rdi, other
    call cstring__len
    mov other_len, rax

    mov rdi, this
    mov rsi, this_len
    mov rdx, other
    mov rcx, other_len
    call memcmp_with_lens

    multipop r12, r13, r14, r15
    pop rbp
    ret

section .text
cstring__destroy:
    ; noop
    ret