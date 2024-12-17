%define SYSV64ARGREGS() "rdi,rsi,rdx,rcx,r8,r9"
%define SYSCALLARGREGS() "rdi,rsi,rdx,r10,r8,r9"

; function name, register-string, args...
%macro call_n 2-*.nolist
    %assign index__ 0
    %xdefine fn_name__ %1
    %xdefine argregs__ %2
    %rep %0-2
        marray_get argregs__, index__
        %deftok register__ retval
        %defstr argstr__ %3
        mstring_index_of argstr__, "lea "
        %if retval == 0
            %substr argstr__ argstr__ 5,-1
            %deftok argstr__ argstr__
            lea register__, [argstr__]
        %elifnidn %3, register__
            ; prevent `mov rdi, rdi`
            mov register__, %3
        %endif
        %assign index__ index__ + 1
        %rotate 1
    %endrep
    %rotate 2
    call fn_name__
    %undef index__
    %undef fn_name__
    %undef argregs__
    %undef register__
    %undef argstr__
%endmacro

%macro syscall_0 1.nolist
    call_n %1, SYSCALLARGREGS
%endmacro
%macro syscall_1 2.nolist
    call_n %1, SYSCALLARGREGS, %2
%endmacro
%macro syscall_2 3.nolist
    call_n %1, SYSCALLARGREGS, %2, %3
%endmacro
%macro syscall_3 4.nolist
    call_n %1, SYSCALLARGREGS, %2, %3, %4
%endmacro
%macro syscall_4 5.nolist
    call_n %1, SYSCALLARGREGS, %2, %3, %4, %5
%endmacro
%macro syscall_5 6.nolist
    call_n %1, SYSCALLARGREGS, %2, %3, %4, %5, %6
%endmacro
%macro syscall_6 7.nolist
    call_n %1, SYSCALLARGREGS, %2, %3, %4, %5, %6, %7
%endmacro

%macro call_0 1.nolist
    call_n %1, SYSV64ARGREGS
%endmacro
%macro call_1 2.nolist
    call_n %1, SYSV64ARGREGS, %2
%endmacro
%macro call_2 3.nolist
    call_n %1, SYSV64ARGREGS, %2, %3
%endmacro
%macro call_3 4.nolist
    call_n %1, SYSV64ARGREGS, %2, %3, %4
%endmacro
%macro call_4 5.nolist
    call_n %1, SYSV64ARGREGS, %2, %3, %4, %5
%endmacro
%macro call_5 6.nolist
    call_n %1, SYSV64ARGREGS, %2, %3, %4, %5, %6
%endmacro
%macro call_6 7.nolist
    call_n %1, SYSV64ARGREGS, %2, %3, %4, %5, %6, %7
%endmacro
