; INPUT:
; * rdi: nul-terminated string-pointer
section .text
global printcln
printcln:
    call printc
    call print_newline
    ret