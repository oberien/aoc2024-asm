%assign __WHILE_COUNT__ 0
%xdefine __WHILE_STACK__() ""

; while (rax < rdi):
;     my_while_body
; endwhile
%macro while 1+
    %assign __WHILE_COUNT__ __WHILE_COUNT__ + 1
    marray_push __WHILE_STACK__, __WHILE_COUNT__
    %defstr retval %1
    mstring_strip_char_end retval, ' '
    mstring_strip_char_end retval, ':'
    mstring_strip_parens retval
    .__while%[__WHILE_COUNT__]:
    parse_condition retval, .__while%[__WHILE_COUNT__]_end
%endmacro

%macro continuewhile 0
    marray_last __WHILE_STACK__
    %deftok retval retval
    jmp .__while%[retval]
%endmacro

%macro breakwhile 0
    marray_last __WHILE_STACK__
    %deftok retval retval
    jmp .__while%[retval]_end
%endmacro

%macro endwhile 0
    marray_pop __WHILE_STACK__
    %deftok retval retval
    jmp .__while%[retval]
    .__while%[retval]_end:
%endmacro

