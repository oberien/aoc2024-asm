fn print_newline():
    rodata_cstring .ln, `\n`
    syscall_write(STDOUT, .ln, 1)
endfn

fn print_short(s: cstring):
    lea rdi, %$s
    call cstring__print
endfn
