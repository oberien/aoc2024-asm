; INPUT:
; * rdi: String
section .text
global println
println:
    call print
    call print_newline
    ret
