struc Rtti
    .name: resb String_size
    .size: resq 1
    ; if a type is primitive, it fits into a single register
    ; it must also be dereferenced before being passed into functions
    ; if a type isn't primitive, it's a pointer which is always passed as this-ptr
    .is_primitive: resq 1
    .print: resq 1
    .println: resq 1
    ; OUTPUT:
    ; * EFLAGS: set accordingly
    .cmp: resq 1
    ; INPUT:
    ; * rdi: this-ptr
    ; * rsi: (out) pointer to clone into
    ; only implemented for non-primitives
    .clone_into: resq 1
    .destroy: resq 1
endstruc

; ARGS:
; * Type-Name
%macro gen_Rtti 1
    section .rodata
    %defstr gen_Rtti_name %1
    %1 %+ _Rtti_name: db gen_Rtti_name
    %1 %+ _Rtti_name_len: equ $ - %1 %+ _Rtti_name
    align 8
    %1 %+ _Rtti:
        istruc Rtti
            at .name, istruc String
                at .rtti, dq String_Rtti
                at .ptr, dq %1 %+ _Rtti_name
                at .len, dq %1 %+ _Rtti_name_len
                at .capacity, dq %1 %+ _Rtti_name_len
            iend
            at .size, dq %1 %+ _size
            at .is_primitive, dq %1 %+ __is_primitive
            at .print, dq %1 %+ __print
            at .println, dq %1 %+ __println
            at .cmp, dq %1 %+ __cmp
            at .clone_into, dq %1 %+ __clone_into
            at .destroy, dq %1 %+ __destroy
        iend
%endmacro

%macro define_struct 2-*
    %push
    %defstr %$name_str %1
    %assign __%1__num_fields__ %0-1
    %assign %$index 0
    %rep %0-1
        %defstr %$index_str %$index
        %strcat %$var_name "__", %$name_str, "__field_", %$index_str, "__"
        %deftok %$var_name %$var_name
        %defstr %[%$var_name] %2
        %rotate 1
        %assign %$index %$index + 1
    %endrep
    %rotate 1

    %strcat %$macro_name "__", %$name_str, "__create_fields__"
    %deftok %$macro_name %$macro_name

    ; type name str, variable name str
    %macro %[%$macro_name] 2
        %strcat num_fields "__", %1, "__num_fields__"
        %deftok num_fields num_fields
        %assign index 0
        %rep num_fields
            %defstr index_str index
            %strcat field_name "__", %1, "__field_", index_str, "__"
            %deftok field_name field_name
            %strcat var_name %2, ".", field_name
            %deftok var_name var_name
            %strcat value "[", %2, " + ", %1, ".", field_name, "]"
            %deftok value value
            %xdefine %[var_name] value
            %assign index index + 1
        %endrep
        %undef index
        %undef index_str
        %undef field_name
        %undef var_name
        %undef value
        %undef num_fields
    %endmacro

    struc %1
    %rep %0-1
        .%2: resq 1
        %rotate 1
    %endrep
    %rotate 1
    endstruc

    gen_Rtti %1
    %pop
%endmacro
