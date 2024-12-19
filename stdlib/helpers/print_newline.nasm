fn print_newline():
    rodata_cstring .ln, `\n`
    syscall_write(STDOUT, .ln, 1)
endfn

; Print a short string (<=8 bytes) directly from 1 register (rdi)
fn print_short(s: u64 = reg):
    sub rsp, 0x10
    mov [rsp], rdi
    mov qword [rsp + 8], 0
    mov rdi, rsp
    call cstring__print
    add rsp, 0x10
endfn
