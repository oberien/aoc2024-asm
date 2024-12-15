; haystack: string, needle: string, direction: -1 or +1
%macro mstring_index_of_direction 3
    %push
    %strlen %$len %1
    %strlen %$needle_len %2
    %assign %$direction %3
    %if %$direction == 1
        %assign %$index 0
    %elif %$direction == -1
        %assign %$index %$len
    %else
        %error "mstring_index_of direction must be -1 or +1"
    %endif
    %rep %$len+1
        %substr %$to_test %1 %$index,%$needle_len
        %ifidn %$to_test, %2
            %exitrep
        %endif
        %assign %$index %$index + %$direction
    %endrep

    %xdefine retval %$index
    %pop
%endmacro
; haystack: string, needle: string
%macro mstring_index_of 2
    mstring_index_of_direction %1, %2, 1
%endmacro

; haystack: string, needle: string
%macro mstring_index_of_last 2
    mstring_index_of_direction %1, %2, -1
%endmacro

; string, char
; strips all instances of `char` from the start of the string
%macro mstring_strip_char 2
    %push
    %strlen %$len %1
    %assign %$index 0

    ; from the front
    %rep %$len
        %substr %$char %1 %$index,1
        %ifnidn %$char, %2
            %exitrep
        %endif
        %assign %$index %$index+1
    %endrep

    %substr retval %1 %$index,-1
    %pop
%endmacro

; string, char
; strips all instances of `char` from the end of the string
%macro mstring_strip_char_end 2
    %push
    %strlen %$len %1
    %assign %$index %$len

    ; from the end
    %assign %$index %$len
    %rep %$len
        %substr %$char %1 %$index, 1
        %ifnidn %$char, %2
            %exitrep
        %endif
        %assign %$index %$index-1
    %endrep

    %substr retval %1 0,%$index
    %pop
%endmacro

; string to strip leading `(` and trailing `)` from
%macro mstring_strip_parens 1
    mstring_strip_char %1, ' '
    mstring_strip_char retval, '('
    mstring_strip_char_end retval, ' '
    mstring_strip_char_end retval, ')'
%endmacro

; string
; converts a newline-character separated instruction-string into the actual instructions
%macro mstring_to_instructions 1
    %xdefine input__ %1
    %strlen len__ input__

    %rep len__
        mstring_index_of input__, `\n`
        %substr instruction__ input__ 0,retval-1
        %if retval == 0
            %exitrep
        %endif
        %substr input__ input__ retval+1,-1
        %deftok instruction__ instruction__
        instruction__
    %endrep

    %undef instruction__
    %undef len__
    %undef input__
%endmacro
