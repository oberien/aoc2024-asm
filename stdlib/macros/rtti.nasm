; ARGS:
; * Type-Name
%macro gen_Rtti 1
    section .rodata
    %defstr gen_Rtti_name %1
    %1 %+ _Rtti_name: db gen_Rtti_name
    %1 %+ _Rtti_name_len: equ $ - %1 %+ _Rtti_name
    %undef gen_Rtti_name
    align 8
    %1 %+ _Rtti:
        istruc Rtti
            at .rtti, dq Rtti_Rtti
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

; __<name>__create_fields__
%macro gen_create_fields_macro 1
    ; type name str, variable name str
    %macro %1 2
        %strcat num_fields "__", %1, "__num_fields__"
        %deftok num_fields num_fields
        %assign index 0
        %rep num_fields
            %defstr index_str index
            %strcat field_name "__", %1, "__field_", index_str, "__"
            %deftok field_name field_name
            %strcat var_name %2, ".", field_name
            %deftok var_name var_name
            %strcat value "qword [", %2, " + ", %1, ".", field_name, "]"
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
%endmacro

struc Rtti
    .rtti: resq 1
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
%define Rtti__is_primitive 0
Rtti_Rtti_name: db `Rtti`
Rtti_Rtti_name_len: equ $ - Rtti_Rtti_name
Rtti_Rtti:
    istruc Rtti
        at .rtti, dq Rtti_Rtti
        at .name, dq String_Rtti, Rtti_Rtti_name, Rtti_Rtti_name_len, Rtti_Rtti_name_len
        at .size, dq Rtti_size
        at .is_primitive, dq Rtti__is_primitive
        at .print, dq Rtti__print
        at .println, dq Rtti__println
        at .cmp, dq Rtti__cmp
        at .clone_into, dq Rtti__clone_into
        at .destroy, dq Rtti__destroy
    iend
%xdefine __Rtti__num_fields__ 9
%xdefine __Rtti__field_0__ "rtti"
%xdefine __Rtti__field_1__ "name"
%xdefine __Rtti__field_2__ "size"
%xdefine __Rtti__field_3__ "is_primitive"
%xdefine __Rtti__field_4__ "print"
%xdefine __Rtti__field_5__ "println"
%xdefine __Rtti__field_6__ "cmp"
%xdefine __Rtti__field_7__ "clone_into"
%xdefine __Rtti__field_8__ "destroy"
gen_create_fields_macro __Rtti__create_fields__

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

    gen_create_fields_macro %[%$macro_name]

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
