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


%macro parse_arg 1
    ; <name>: [&[out]] <type> [= register]
    ; `&` is only allowed for non-primitive types

    ; requires the following variables to exist:
    ; * arg_regs

    ; defines the following names:
    ; * arg_name_str
    ; * arg_type_str
    ; * arg_type_is_ref: 1 if yes, 0 otherwise
    ; * arg_type_is_out: 1 if yes, 0 otherwise
    ; * arg_reg: register the argument is passed in
    ; * arg_reg_str: register the argument is passed in as string
    ; * arg_is_in_register: if the argument should be referred to in the register or pushed to the stack

    index_of %1, ':'
    %substr arg_name_str %1 0,retval-1
    %substr arg_type_str %1 retval+1,-1

    ; strip whitespace off name and type
    strip_char arg_name_str, ' '
    %xdefine arg_name_str retval
    strip_char arg_type_str, ' '
    %xdefine arg_type_str retval

    ; check if there is the argument is a reference
    strip_char arg_type_str, '&'
    %ifidn arg_type_str, retval
        %assign arg_type_is_ref 0
    %else
        %assign arg_type_is_ref 1
    %endif
    strip_char retval, ' '
    %xdefine arg_type_str retval

    ; check if this is an out-parameter
    %assign arg_type_is_out 0
    %substr arg_type_is_out arg_type_str 0,3
    %ifidn arg_type_is_out, "out"
        %assign arg_type_is_out 1
        %substr arg_type_str arg_type_str 4,-1
        strip_char arg_type_str, ' '
        %xdefine arg_type_str retval
    %endif

    ; get argument register according to sysv64
    %ifidn arg_regs, ""
        %error "only 0-6 arguments supported"
        %exitrep
    %endif
    %substr arg_reg_str arg_regs 0,3
    %substr arg_regs arg_regs 4,-1
    %deftok arg_reg arg_reg_str

    ; check if the argument should stay in the register / the register should not be pushed
    %assign arg_is_in_register 0
    index_of arg_type_str, '='
    %strlen arg_type_str_len arg_type_str
    %if retval-1 != arg_type_str_len
        %substr arg_is_in_register arg_type_str retval+1,-1
        %substr arg_type_str arg_type_str 0,retval-1
        strip_char_end arg_type_str, ' '
        %xdefine arg_type_str retval

        strip_char arg_is_in_register, ' '
        strip_char_end retval, ' '
        %xdefine arg_is_in_register retval
        %ifnidn arg_is_in_register, arg_reg_str
            %strcat error_msg "Argument `", arg_name_str, "` must be in register `", arg_reg_str, "` and not `", arg_is_in_register, "`"
            %error error_msg
        %endif
        %assign arg_is_in_register 1
    %endif
    %undef arg_type_str_len
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
    %xdefine arg_regs "rdirsirdxrcxr8 r9 "
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
            %undef len
            %exitrep
        %endif
        %undef len
        %assign num_args num_args+1
        index_of args, ','
        %substr arg args 0,retval-1
        %substr args args retval+1,-1

        ; parse argument

        parse_arg arg
        %strcat args_with_comma args_with_comma, ", ", arg_name_str

        ; define register for argument name
        %strcat arg_name '%$', arg_name_str
        %deftok arg_name arg_name
        %if arg_is_in_register == 0
            %xdefine %[arg_name] qword [rbp - (%$__argsize) - 8]
            push arg_reg
            %assign %$__argsize %$__argsize + 8
        %else
            %xdefine %[arg_name] arg_reg
        %endif

        %deftok arg_type arg_type_str
        ; The preprocessor doesn't care that we hit %exitrep before.
        ; It still insists that arg_type must exist here, even though we would
        ; define it literally the line above.
        %ifdef arg_type
            %assign is_primitive arg_type %+ __is_primitive


            ; insert `check_rtti` if needed
            %if !is_primitive && !arg_type_is_out
                check_rtti arg_reg, arg_type
            %endif

            %if !is_primitive && !arg_is_in_register && !arg_type_is_ref
                %strcat error_msg "Object argument `", arg_name_str, "` stored on stack must be a reference: `&", arg_type_str, "`"
                %error error_msg
            %endif

            %if !is_primitive && arg_is_in_register && arg_type_is_ref
                %strcat error_msg "Object argument `", arg_name_str, "` used as register must not be a reference: `", arg_type_str, "`"
                %error error_msg
            %endif

            %if is_primitive && arg_type_is_ref
                %strcat error_msg "Primitive argument `", arg_name_str, "` must not be a reference: `", arg_type_str, "`"
                %error error_msg
            %endif
        %endif
    %endrep

    %deftok args_with_comma_leading args_with_comma
    strip_char args_with_comma, ','
    %deftok args_with_comma retval
    %xdefine %[name](%[args_with_comma]) call_%[num_args] %[name] %[args_with_comma_leading]

    %undef error_msg
    %undef is_primitive
    %undef arg_type_is_ref
    %undef arg_type_is_out
    %undef args_with_comma
    %undef arg_reg
    %undef arg_reg_str
    %undef arg_regs
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
