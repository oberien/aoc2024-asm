%macro parse_arg 1
    ; <name>: [&[out]] <type> [= register]
    ; `&` is only allowed for non-primitive types

    ; requires the following variables to exist:
    ; * arg_regs__

    ; defines the following names:
    ; * arg_name_str__
    ; * arg_type_str__
    ; * arg_type_is_ref__: 1 if yes, 0 otherwise
    ; * arg_type_is_out__: 1 if yes, 0 otherwise
    ; * arg_reg__: register the argument is passed in
    ; * arg_reg_str__: register the argument is passed in as string
    ; * arg_is_in_register__: if the argument is referred to in a register (either nv-reg or arg-reg)
    ; * arg_is_in_arg_register__: if the argument should be referred to in its argument-register
    ; * arg_is_in_nv_register__: if the argument should be moved to a non-volatile register

    mstring_index_of %1, ':'
    %substr arg_name_str__ %1 0,retval-1
    %substr arg_type_str__ %1 retval+1,-1

    ; strip whitespace off name and type
    mstring_strip_char arg_name_str__, ' '
    %xdefine arg_name_str__ retval
    mstring_strip_char arg_type_str__, ' '
    %xdefine arg_type_str__ retval

    ; check if there is the argument is a reference
    mstring_strip_char arg_type_str__, '&'
    %ifidn arg_type_str__, retval
        %assign arg_type_is_ref__ 0
    %else
        %assign arg_type_is_ref__ 1
    %endif
    mstring_strip_char retval, ' '
    %xdefine arg_type_str__ retval

    ; check if this is an out-parameter
    %assign arg_type_is_out__ 0
    %substr arg_type_is_out__ arg_type_str__ 0,3
    %ifidn arg_type_is_out__, "out"
        %assign arg_type_is_out__ 1
        %substr arg_type_str__ arg_type_str__ 4,-1
        mstring_strip_char arg_type_str__, ' '
        %xdefine arg_type_str__ retval
    %endif

    ; get argument register according to sysv64
    %ifidn arg_regs__, ""
        %error "only 0-6 arguments supported"
        %exitrep
    %endif
    %substr arg_reg_str__ arg_regs__ 0,3
    %substr arg_regs__ arg_regs__ 4,-1
    mstring_strip_char_end arg_reg_str__, ' '
    %xdefine arg_reg_str__ retval
    %deftok arg_reg__ arg_reg_str__

    ; check if the argument should stay in the register / the register should not be pushed
    %assign arg_is_in_register__ 0
    %assign arg_is_in_arg_register__ 0
    %assign arg_is_in_nv_register__ 0
    mstring_index_of arg_type_str__, '='
    %strlen arg_type_str_len__ arg_type_str__
    %if retval-1 != arg_type_str_len__
        %assign arg_is_in_register__ 1

        %substr arg_is_in_arg_register__ arg_type_str__ retval+1,-1
        %substr arg_type_str__ arg_type_str__ 0,retval-1
        mstring_strip_char_end arg_type_str__, ' '
        %xdefine arg_type_str__ retval

        mstring_strip_char arg_is_in_arg_register__, ' '
        mstring_strip_char_end retval, ' '
        %xdefine arg_is_in_arg_register__ retval

        %ifidn arg_is_in_arg_register__, "reg"
            %assign arg_is_in_arg_register__ 0
            %assign arg_is_in_nv_register__ 1
        %else
            %ifnidn arg_is_in_arg_register__, arg_reg_str__
                %strcat error_msg__ "Argument `", arg_name_str__, "` must be in register `", arg_reg_str__, "` and not `", arg_is_in_arg_register__, "`"
                %error error_msg__
            %endif
            %assign arg_is_in_arg_register__ 1
            %assign arg_is_in_nv_register__ 0
        %endif
    %endif
    %undef arg_type_str_len__
%endmacro

; stored non-volatile registers == %$__regs_to_push
; locals == %$__localsize
; stored non-volatile registers for function-arguments == %$__arg_nvregs_to_pop
; pushed arguments == %$__argsize
; return address <- ebp

%macro fn 1+
    %push
    %xdefine %$__regs "r12r13r14r15rbx"
    %xdefine %$__regs_to_push ""
    %xdefine %$__argsize 0
    %xdefine %$__arg_nvregs_to_pop ""
    %xdefine %$__localsize 0

    %defstr input__ %1
    mstring_index_of input__, '('
    %xdefine open__ retval
    mstring_index_of input__, ')'
    %xdefine close__ retval
    %substr name__ input__ 0,open__-1
    %substr args__ input__ open__+1,close__-open__-1

    %deftok name__ name__
    %xdefine arg_regs__ "rdirsirdxrcxr8 r9 "
    section .text
    name__:
        push rbp
        mov rbp, rsp

    ; parse args
    %assign num_args__ 0
    %xdefine nv_arg_instructions__ ""
    %xdefine args_with_comma__ ""
    %rep 10
        mstring_strip_char args__, ' '
        mstring_strip_char retval, ','
        mstring_strip_char retval, ' '
        %xdefine args__ retval
        ; split off next argument from arguments
        %strlen len__ args__
        %if len__ == 0
            %exitrep
        %endif
        %assign num_args__ num_args__+1
        mstring_index_of args__, ','
        %substr arg__ args__ 0,retval-1
        %substr args__ args__ retval+1,-1

        ; parse argument

        parse_arg arg__
        %deftok arg_type__ arg_type_str__

        ; The preprocessor doesn't care that we hit %exitrep before.
        ; It still insists that all variables must exist here.
        %ifdef arg_name_str__
            %strcat args_with_comma__ args_with_comma__, ", ", arg_name_str__

            ; define register for argument name
            %strcat arg_name '%$', arg_name_str__

            %if arg_is_in_register__
                __%[arg_type__]__create_fields__ arg_type_str__, arg_name
            %endif

            %deftok arg_name arg_name
            %if arg_is_in_arg_register__
                %xdefine %[arg_name] arg_reg__
            %elif arg_is_in_nv_register__
                %substr reg__ %$__regs 0,3
                %substr %$__regs %$__regs 4,-1
                %strcat %$__arg_nvregs_to_pop %$__arg_nvregs_to_pop, ", ", reg__
                %strcat nv_arg_instructions__ nv_arg_instructions__, `push `, reg__, `\nmov `, reg__, `, `, arg_reg_str__, `\n`
                %deftok reg__ reg__
                %xdefine %[arg_name] reg__
            %else
                %xdefine %[arg_name] qword [rbp - (%$__argsize) - 8]
                push arg_reg__
                %assign %$__argsize %$__argsize + 8
            %endif

            ; handle type shenanigans
            %assign is_primitive__ arg_type__ %+ __is_primitive


            ; insert `check_rtti` if needed
            %if !is_primitive__ && !arg_type_is_out__
                check_rtti arg_reg__, arg_type__
            %endif

            %if !is_primitive__ && !arg_is_in_register__ && !arg_type_is_ref__
                %strcat error_msg__ "Object argument `", arg_name_str__, "` stored on stack must be a reference: `&", arg_type_str__, "`"
                %error error_msg__
            %endif

            %if !is_primitive__ && arg_is_in_register__ && arg_type_is_ref__
                %strcat error_msg__ "Object argument `", arg_name_str__, "` used as register must not be a reference: `", arg_type_str__, "`"
                %error error_msg__
            %endif

            %if is_primitive__ && arg_type_is_ref__
                %strcat error_msg__ "Primitive argument `", arg_name_str__, "` must not be a reference: `", arg_type_str__, "`"
                %error error_msg__
            %endif
        %endif
    %endrep

    mstring_to_instructions nv_arg_instructions__

    %deftok args_with_comma_leading__ args_with_comma__
    mstring_strip_char args_with_comma__, ','
    %deftok args_with_comma__ retval
    %xdefine %[name__](%[args_with_comma__]) call_%[num_args__] %[name__] %[args_with_comma_leading__]

    %undef args_with_comma_leading__
    %undef error_msg__
    %undef nv_arg_instructions__
    %undef is_primitive__
    %undef arg_type_is_ref__
    %undef arg_type_is_out__
    %undef arg_is_in_arg_register__
    %undef arg_is_in_nv_register__
    %undef args_with_comma__
    %undef arg_reg__
    %undef arg_reg_str__
    %undef arg_regs__
    %undef num_args__
    %undef args__
    %undef arg__
    %undef reg__
    %undef arg_name
    %undef arg_name_str__
    %undef arg_type__
    %undef arg_type_str__
    %undef arg_is_in_register__
    %undef name__
    %undef open__
    %undef close__
    %undef input__
    %undef len__
%endmacro

%macro local 1+
    %defstr input %1
    mstring_index_of input, ':'
    %substr name__ input 0,retval-1
    %substr type_str input retval+1,-1
    mstring_strip_char type_str, ' '
    %xdefine type_str retval

    %deftok type type_str
    %strcat name__ "%$", name__
    __%[type]__create_fields__ type_str, name__
    %deftok name__ name__
    %xdefine addr rbp - (%[%$__argsize] + %[%$__localsize]) - %[type]_size
    %if type %+ __is_primitive == 1
        %xdefine %[name__] qword [addr]
    %else
        %xdefine %[name__] addr
    %endif
    %xdefine %$__localsize %$__localsize + %[type]_size

    %undef addr
    %undef type
    %undef type_str
    %undef name__
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

    mstring_index_of input, ':'
    %substr name input 0,retval-1
    %substr type_str input retval+1,-1
    mstring_strip_char type_str, ' '
    %xdefine type_str retval

    %deftok type type_str
    %strcat name "%$", name
    __%[type]__create_fields__ type_str, name
    %deftok name name
    %deftok reg reg
    %xdefine %[name] reg
    ; we just ignore the type -- nothing we can / need to do here

    %undef name
    %undef type
    %undef type_str
    %undef reg
    %undef input
%endmacro

%macro vars 0
%endmacro

%macro endvars 0
    %defstr localsize_str %$__localsize
    %ifnidn localsize_str, "0"
        sub rsp, %$__localsize
    %endif
    %ifnidn %$__regs_to_push, ""
        mstring_strip_char %$__regs_to_push, ','
        %xdefine %$__regs_to_push retval
        %deftok regs_to_push_tok %$__regs_to_push
        multipush regs_to_push_tok
    %endif


    %undef localsize_str
    %undef regs_to_push_tok
    %undef reglen
%endmacro

%macro endfn 0
    ; pop non-volatile registers for vars
    %ifnidn %$__regs_to_push, ""
        %deftok regs_to_push_tok %$__regs_to_push
        multipop regs_to_push_tok
    %endif

    %defstr localsize_str %$__localsize
    %assign has_locals 0
    %ifnidn localsize_str, "0"
        %assign has_locals 1
    %endif
    %assign has_pushed_args %$__argsize != 0
    %assign has_pushed_nvargregs 0
    %ifnidn %$__arg_nvregs_to_pop, ""
        %assign has_pushed_nvargregs 1
    %endif

    %if has_pushed_nvargregs
        %if has_locals
            add rsp, %$__localsize
        %endif
        mstring_strip_char %$__arg_nvregs_to_pop, ','
        %deftok %$__arg_nvregs_to_pop retval
        multipop %$__arg_nvregs_to_pop
        %if has_pushed_args
            mov rsp, rbp
        %endif
    %elif has_locals || has_pushed_args
        mov rsp, rbp
    %endif

    pop rbp
    ret

    %undef has_locals
    %undef has_pushed_args
    %undef has_pushed_nvargregs
    %undef regs_to_push_tok
    %undef localsize_str
    %pop
%endmacro
