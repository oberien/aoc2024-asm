%assign __FOR_COUNT__ 0
%xdefine __FOR_STACK__() ""

; for (rcx = 0, rcx < 5, inc rcx):
;     my_for_body
; endfor
%macro for 1+
    %assign __FOR_COUNT__ __FOR_COUNT__ + 1
    marray_push __FOR_STACK__, __FOR_COUNT__
    %defstr retval %1
    mstring_strip_char_end retval, ' '
    mstring_strip_char_end retval, ':'
    mstring_strip_parens retval
    %xdefine for__() retval
    marray_pop for__
    %xdefine advancement__ retval
    marray_pop for__
    %xdefine condition__ retval
    marray_pop for__
    %xdefine initialization__ retval
    mstring_index_of initialization__, '='
    %substr var__ initialization__ 0,retval-1
    %deftok var__ var__
    %substr value__ initialization__ retval+1,-1
    %deftok value__ value__
    mov var__, value__
    .__for%[__FOR_COUNT__]:
    parse_condition condition__, .__for%[__FOR_COUNT__]_end
    marray_push __FOR_STACK__, advancement__
    %undef for__
    %undef advancement__
    %undef condition__
    %undef initialization__
    %undef var__
    %undef value__
%endmacro

%macro endfor 0
    marray_pop __FOR_STACK__
    mstring_to_instructions retval
    marray_pop __FOR_STACK__
    %deftok retval retval
    jmp .__for%[retval]
    .__for%[retval]_end:
%endmacro

