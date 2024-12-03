; INPUT:
; * rax: return value of a syscall
; OUTPUT:
; * rax: not modified -- return value of the syscall
section .text
global handleerror
handleerror:
    cmp rax, 0
    jl .error
    ret

   .error:
   mov rdi, rax
   neg rdi
   call exit
   ud2
