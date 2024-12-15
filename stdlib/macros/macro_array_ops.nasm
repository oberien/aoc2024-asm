; Macro Arrays (marrays) are comma-separated strings.
; They must be defined as zero-argument macros to allow overwriting within the macros.
; They must be passed to the macros uninvoked, i.e., just their name without parens.
; %xdefine MY_ARRAY() "a,b,c"
; marray_push MY_ARRAY, "d"

; array (string), index
; returns the nth element (0-indexed)
%macro marray_get 2
    %push
    %xdefine %$substring %1()
    %rep %2
        mstring_index_of %$substring, ','
        %substr %$substring %$substring retval+1,-1
    %endrep
    mstring_index_of %$substring, ','
    %substr retval %$substring 0,retval-1
    %pop
%endmacro

; array
%macro marray_first 1
    mstring_index_of %1(), ','
    %substr retval %1() 0,retval-1
%endmacro

; array
%macro marray_last 1
    mstring_index_of_last %1(), ','
    %substr retval %1() retval+1,-1
%endmacro

; array, element
%macro marray_push 2
    %push
    %ifstr %2
        %xdefine %$element %2
    %else
        %defstr %$element %2
    %endif
    %strlen %$len %1()
    %xdefine %$array %1()
    %if %$len != 0
        %strcat %$array %$array, ","
    %endif
    %strcat %$array %$array, %$element
    %xdefine %1() %$array
    %pop
%endmacro

; array
%macro marray_pop 1
    %push
    %xdefine %$array %1()
    mstring_index_of_last %$array, ','
    %substr %$retval %$array retval+1,-1
    %if retval == -1
        %xdefine %$array ""
    %else
        %substr %$array %$array 0,retval-1
    %endif
    %xdefine %1() %$array
    %xdefine retval %$retval
    %pop
%endmacro
