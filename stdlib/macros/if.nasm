; increments with every `if`; used for else-label-numbers
%assign __IF_COUNT__ 0
; array to track if-numbers in nested ifs
; each number is pushed twice to detect if an else was encountered or not
; else pops one element
%xdefine __IF_STACK__() ""

; if (rax < rdi):
%macro if 1+
    %assign __IF_COUNT__ __IF_COUNT__ + 1
    marray_push __IF_STACK__, __IF_COUNT__
    marray_push __IF_STACK__, __IF_COUNT__
    %defstr retval %1
    mstring_strip_char_end retval, ' '
    mstring_strip_char_end retval, ':'
    mstring_strip_parens retval
    parse_condition retval, .__if%[__IF_COUNT__]_else
%endmacro

%macro else 0+
    marray_pop __IF_STACK__
    %deftok retval retval
    jmp .__if%[retval]_end
    .__if%[retval]_else:
%endmacro

%macro endif 0
    %push
    marray_pop __IF_STACK__
    %deftok %$if_number retval
    marray_last __IF_STACK__
    %ifidn retval, ""
        %assign %$lower_if_number -1
    %else
        %deftok %$lower_if_number retval
    %endif
    %if %$if_number == %$lower_if_number
        ; we haven't hit an `else`
        marray_pop __IF_STACK__
        .__if%[%$if_number]_else:
    %endif
    .__if%[%$if_number]_end:
    %pop
%endmacro

