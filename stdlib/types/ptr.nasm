; ptr is a primitive
; ptr doesn't contain the Rtti itself

ptr_size equ 8

section .text
ptr__print:
    jmp u64__printhex

section .text
ptr__println:
    jmp u64__printhexln

section .text
ptr__cmp:
    jmp u64__cmp

section .text
ptr__clone_into:
    push rbp
    mov rbp, rsp
    panic `clone_into not applicable for ptr`

section .text
ptr__destroy:
    push rbp
    mov rbp, rsp
    panic `destroy not applicable for ptr`
