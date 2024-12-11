; doesn't modify any registers
%macro check_rtti 2
    ; rtti is always the first element in any object
    cmp qword [%1 + 0], %2 %+ _Rtti
    je %%end
    %defstr %%s %2
    %strcat %%s %%s, ` operation called with invalid type`
    panic %%s
    %%end:
%endmacro
