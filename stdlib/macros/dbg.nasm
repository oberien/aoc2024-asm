%macro dbg 1
    rodata_cstring %%s, %1
    mov rdi, %%s
    call cstring__print
%endmacro

%macro dbgln 1
    rodata_cstring %%s, %1
    mov rdi, %%s
    call cstring__println
%endmacro
