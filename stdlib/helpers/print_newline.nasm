fn print_newline():
    rodata_cstring .ln, `\n`
    syscall_write(STDOUT, .ln, 1)
endfn
