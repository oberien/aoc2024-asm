; INPUT:
; * rdi: number
section .text
global printnumln
printnumln:
    call printnum
    call print_newline
    ret
