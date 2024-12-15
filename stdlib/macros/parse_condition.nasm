; string, label if condition is wrong
; e.g. `"rax < rdi", .endif`
%macro parse_condition 2
    %push
    %strlen %$len %1
    mstring_index_of %1, "<"
    %assign %$lt retval
    mstring_index_of %1, "<="
    %assign %$le retval
    mstring_index_of %1, "=="
    %assign %$eq retval
    mstring_index_of %1, ">="
    %assign %$ge retval
    mstring_index_of %1, ">"
    %assign %$gt retval
    mstring_index_of %1, "!="
    %assign %$ne retval
    %if %$eq < %$len
        %assign %$aend %$eq-1
        %assign %$bstart %$eq+2
        %xdefine %$cc ne
    %elif %$ne < %$len
        %assign %$aend %$ne-1
        %assign %$bstart %$ne+2
        %xdefine %$cc e
    %elif %$le < %$len
        %assign %$aend %$le-1
        %assign %$bstart %$le+2
        %xdefine %$cc nle
    %elif %$ge < %$len
        %assign %$aend %$ge-1
        %assign %$bstart %$ge+2
        %xdefine %$cc nge
    %elif %$lt < %$len
        %assign %$aend %$lt-1
        %assign %$bstart %$lt+1
        %xdefine %$cc nl
    %elif %$gt < %$len
        %assign %$aend %$gt-1
        %assign %$bstart %$gt+1
        %xdefine %$cc ng
    %else
        %error "can't parse condition"
    %endif
    %substr %$a %1 0,%$aend
    %substr %$b %1 %$bstart,-1
    %deftok %$a %$a
    %deftok %$b %$b
    cmp %$a, %$b
    j%$cc %2
    %pop
%endmacro
