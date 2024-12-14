; haystack: string, needle: string
%macro mstring_index_of 2
    %strlen len %1
    %strlen needle_len %2
    %assign i 0
    %rep len+1
        %substr to_test %1 i,needle_len
        %ifidn to_test, %2
            %exitrep
        %endif
        %assign i i+1
    %endrep

    %xdefine retval i
    %undef i
    %undef to_test
    %undef len
    %undef needle_len
%endmacro

; string, char
; strips all instances of `char` from the start of the string
%macro strip_char 2
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
%macro strip_char_end 2
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

; string
; converts a newline-character separated instructions into their actual instructions
%macro string_to_instructions 1
    %xdefine input %1
    %strlen len input

    %rep len
        mstring_index_of input, `\n`
        %substr instruction input 0,retval-1
        %if retval == 0
            %exitrep
        %endif
        %substr input input retval+1,-1
        %deftok instruction instruction
        instruction
    %endrep

    %undef instruction
    %undef len
    %undef input
%endmacro

