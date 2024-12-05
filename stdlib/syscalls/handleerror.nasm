; INPUT:
; * rax: return value of a syscall
; OUTPUT:
; * rax: not modified -- return value of the syscall
section .text
handleerror:
    cmp rax, 0
    jl .error
    ret

   .error:
   mov rdi, rax
   neg rdi
   int3
   ud2
