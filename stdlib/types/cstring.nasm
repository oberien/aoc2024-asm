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
cstring__equals:
    push rbp
    mov rbp, rsp
    ud2 ; TODO
    pop rbp
    ret

section .text
cstring__cmp:
    push rbp
    mov rbp, rsp
    ud2 ; TODO
    pop rbp
    ret

section .text
cstring__destroy:
    ; noop
    ret