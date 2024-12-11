%macro syscall_1 2
    mov rdi, %2
    call %1
%endmacro
%macro syscall_2 3
    mov rdi, %2
    mov rsi, %3
    call %1
%endmacro
%macro syscall_3 4
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    call %1
%endmacro
%macro syscall_4 5
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    call %1
%endmacro
%macro syscall_5 6
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8, %6
    call %1
%endmacro
%macro syscall_6 7
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8, %6
    mov r9, %7
    call %1
%endmacro

%macro call_0 1
    call %1
%endmacro
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

%macro strip_char 2
    %strlen len %1
    %assign retval 0
    %rep len
        %substr char %1 retval,1
        %ifnidn char, %2
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

; stored non-volatile registers == %$__regs_to_push
; locals == %$__localsize
; pushed arguments == %$__argsize
; return address <- ebp

%macro fn 1+
    %push
    %xdefine %$__regs_to_push ""
    %xdefine %$__argsize 0

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
    %rep 100
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
        %substr arg_name_str arg 0,retval-1
        %substr arg_type_str arg retval+1,-1

        ; strip whitespace off name and type
        strip_char arg_name_str, ' '
        %xdefine arg_name_str retval
        strip_char arg_type_str, ' '
        %xdefine arg_type_str retval
        strip_char arg_type_str, '&'
        %assign arg_type_is_ref arg_type_str != retval
        %xdefine arg_type_str retval
        strip_char arg_type_str, ' '
        %xdefine arg_type_str retval
        %strcat args_with_comma args_with_comma, ", ", arg_name_str

        ; get register
        %ifidn regs, ""
            %error "only 0-6 arguments supported"
            %exitrep
        %endif
        %substr reg regs 0,3
        %substr regs regs 4,-1
        %deftok reg reg

        ; define register for argument name
        %strcat arg_name '%$', arg_name_str
        %deftok arg_name arg_name
        %xdefine %[arg_name] qword [rbp - (%$__argsize) - 8]
        push reg
        %assign %$__argsize %$__argsize + 8
        %deftok arg_type arg_type_str
        ; insert `check_rtti` if needed
        ; The preprocessor doesn't care that we hit %exitrep before.
        ; It still insists that arg_type must exist here.
        %ifdef arg_type
            %if arg_type %+ __is_primitive == 0
                %if !arg_type_is_ref
                    %strcat error_msg "Argument `", arg_name_str, "` must be a reference: `&", arg_type_str, "`"
                    %error error_msg
                %endif
                check_rtti reg, arg_type
            %else
                %if arg_type_is_ref
                    %strcat error_msg "Argument `", arg_name_str, "` must not be a reference: `", arg_type_str, "`"
                    %error error_msg
                %endif
            %endif
        %endif
    %endrep

    %deftok args_with_comma_leading args_with_comma
    strip_char args_with_comma, ','
    %deftok args_with_comma retval
    %xdefine %[name](%[args_with_comma]) call_%[num_args] %[name] %[args_with_comma_leading]

    %undef error_msg
    %undef arg_type_is_ref
    %undef args_with_comma
    %undef reg
    %undef regs
    %undef num_args
    %undef args
    %undef arg
    %undef arg_name
    %undef arg_name_str
    %undef arg_type
    %undef arg_type_str
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
    %xdefine addr rbp - (%[%$__argsize] + %[%$__localsize]) - %[type]_size
    %if type %+ __is_primitive == 1
        %xdefine %[name] qword [addr]
    %else
        %xdefine %[name] addr
    %endif
    %xdefine %$__localsize %$__localsize + %[type]_size

    %undef addr
    %undef type
    %undef name
    %undef input
%endmacro

%macro reg 1+
    %defstr input %1
    %ifidn %$__regs, ""
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
    %defstr localsize_str %$__localsize
    %ifnidn localsize_str, "0"
        sub rsp, %$__localsize
    %endif
    %ifnidn %$__regs_to_push, ""
        strip_char %$__regs_to_push, ','
        %xdefine %$__regs_to_push retval
        %deftok regs_to_push_tok %$__regs_to_push
        multipush regs_to_push_tok
    %endif

    %undef localsize_str
    %undef regs_to_push_tok
    %undef reglen
%endmacro

%macro endfn 0
    %defstr localsize_str %$__localsize
    %ifnidn %$__regs_to_push, ""
        %deftok regs_to_push_tok %$__regs_to_push
        multipop regs_to_push_tok
    %endif

    %ifnidn localsize_str, "0"
        mov rsp, rbp
    %elif %$__argsize != 0
        mov rsp, rbp
    %endif

    pop rbp
    ret

    %undef regs_to_push_tok
    %undef localsize_str
    %pop
%endmacro
