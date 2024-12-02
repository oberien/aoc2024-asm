; INPUT:
; * rdi: exit code
section .text
global exit
exit:
    mov rax, 60
    syscall
    ud2