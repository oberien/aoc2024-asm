%macro rodata_cstring 2
    %strcat %%s %2, `\0`
    [section .rodata]
        %1: db %%s
        %1 %+ _len: equ $ - %1 - 1
    __?SECT?__
%endmacro
