; ptr is a primitive
; ptr doesn't contain the Rtti itself

section .text
ptr__print:
    jmp u64__printhex

section .text
ptr__println:
    jmp u64__printhexln

section .text
ptr__cmp:
    jmp u64__cmp

fn ptr__clone_into(this: ptr = rdi):
    panic `clone_into not applicable for ptr`
endfn

fn ptr__destroy(this: ptr = rdi):
    panic `destroy not applicable for ptr`
endfn
