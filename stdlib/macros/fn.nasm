%macro call_1 2
    mov rdi, %2
    call %1
%endmacro
%macro call_2 3
    mov rdi, %2
    mov rsi, %3
    call %1
%endmacro
%macro call_3 4
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    call %1
%endmacro
%macro call_4 5
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov rcx, %5
    call %1
%endmacro
%macro call_5 6
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov rcx, %5
    mov r8, %6
    call %1
%endmacro
%macro call_6 7
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov rcx, %5
    mov r8, %6
    mov r9, %7
    call %1
%endmacro

%macro index_of 2
    %strlen len %1
    %strlen needle_len %2
    %assign i 0
    %rep len+1
        %substr to_test %1 i,needle_len
        %if to_test == %2
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

%macro strip_char 2
    %strlen len %1
    %assign retval 0
    %rep len
        %substr char %1 retval,1
        %if char != %2
            %exitrep
        %endif
        %assign retval retval+1
    %endrep
    %substr retval %1 retval,-1
    %undef char
    %undef len
%endmacro

%macro string_to_instructions 1
    %xdefine input %1
    %strlen len input

    %rep len
        index_of input, `\n`
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

%macro fn 1+
    %push
    %xdefine %$__regs_to_push ""

    %defstr input %1
    index_of input, '('
    %xdefine open retval
    index_of input, ')'
    %xdefine close retval
    %substr name input 0,open-1
    %substr args input open+1,close-open-1

    %deftok name name
    %xdefine regs "rdirsirdxrcxr8 r9 "
    section .text
    name:
        push rbp
        mov rbp, rsp

    ; parse args
    %assign num_args 0
    %xdefine args_with_comma ""
    %rep 6
        strip_char args, ' '
        strip_char retval, ','
        strip_char retval, ' '
        %xdefine args retval
        ; split off next argument from arguments
        %strlen len args
        %if len == 0
            %exitrep
        %endif
        %assign num_args num_args+1
        index_of args, ','
        %substr arg args 0,retval-1
        %substr args args retval+1,-1
        index_of arg, ':'
        %substr arg_name arg 0,retval-1
        %substr arg_type arg retval+1,-1

        ; strip whitespace off name and type
        strip_char arg_name, ' '
        %xdefine arg_name retval
        strip_char arg_type, ' '
        %xdefine arg_type retval
        %strcat args_with_comma args_with_comma, ", ", arg_name

        ; get register
        [warning -other]
        %if regs == ""
        [warning +other]
            %error "only 0-6 arguments supported"
        %endif
        %substr reg regs 0,3
        %substr regs regs 4,-1
        %deftok reg reg

        ; define register for argument name
        %strcat arg_name '%$', arg_name
        %deftok arg_name arg_name
        %xdefine %[arg_name] reg
        %deftok arg_type arg_type
        ; insert `check_rtti` if needed
        check_rtti reg, arg_type
    %endrep

    strip_char args_with_comma, ','
    %deftok args_with_comma retval
;    _define: %[name](%[args_with_comma]) call_%[num_args] %[name], %[args_with_comma]
    %xdefine %[name](%[args_with_comma]) call_%[num_args] %[name], %[args_with_comma]


    %undef args_with_comma
    %undef reg
    %undef regs
    %undef num_args
    %undef args
    %undef arg
    %undef arg_name
    %undef arg_type
    %undef open
    %undef close
    %undef input
    %undef i
    %undef len
%endmacro

%macro local 1+
    %defstr input %1
    index_of input, ':'
    %substr name input 0,retval-1
    %substr type input retval+1,-1
    strip_char type, ' '
    %xdefine type retval

    %strcat name "%$", name
    %deftok name name
    %deftok type type
    %xdefine %[name] rbp - (%[%$__localsize]) - %[type]_size
    %xdefine %$__localsize %$__localsize + %[type]_size

    %undef type
    %undef name
    %undef input
%endmacro

%macro reg 1+
    %defstr input %1
    [warning -other]
    %if %$__regs == ""
    [warning +other]
        %error "Only 5 local registers allowed"
    %endif
    %substr reg %$__regs 0,3
    %substr %$__regs %$__regs 4,-1
    %strcat %$__regs_to_push %$__regs_to_push, ", ", reg

    index_of input, ':'
    %substr name input 0,retval-1
    %substr type input retval+1,-1
    strip_char type, ' '
    %xdefine type retval

    %strcat name "%$", name
    %deftok name name
    %deftok type type
    %deftok reg reg
    %xdefine %[name] reg
    ; we just ignore the type -- nothing we can / need to do here

    %undef name
    %undef type
    %undef reg
    %undef input
%endmacro

%macro vars 0
    %xdefine %$__localsize 0
    %xdefine %$__regs "r12r13r14r15rbx"
%endmacro

%macro endvars 0
    sub rsp, %$__localsize
    [warning -other]
    %if %$__regs_to_push != ""
    [warning +other]
        strip_char %$__regs_to_push, ','
        %xdefine %$__regs_to_push retval
        %deftok regs_to_push_tok %$__regs_to_push
        multipush regs_to_push_tok
    %endif

    %undef regs_to_push_tok
    %undef reglen
%endmacro

%macro endfn 0
    %defstr localsize_str %$__localsize
    [warning -other]
    %if localsize_str != "0"
    [warning +other]
        mov rsp, rbp
    %endif
    [warning -other]
    %if %$__regs_to_push != ""
    [warning +other]
        %deftok regs_to_push_tok %$__regs_to_push
        multipop regs_to_push_tok
    %endif

    pop rbp
    ret

    %undef regs_to_push_tok
    %undef localsize_str
    %pop
%endmacro
