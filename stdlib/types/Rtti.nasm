struc Rtti
    .name: resb String_size
    .size: resq 1
    ; given a pointer to the type, return whatever represents the type
    ; used by primitives to convert a pointer to the actual primitive value
    ; OUTPUT:
    ; * rax: element to be used as argument for other function calls
    .extract_value: resq 1
    .print: resq 1
    .println: resq 1
    ; OUTPUT:
    ; * EFLAGS: set accordingly
    .cmp: resq 1
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
            at .extract_value, dq %1 %+ __extract_value
            at .print, dq %1 %+ __print
            at .println, dq %1 %+ __println
            at .cmp, dq %1 %+ __cmp
            at .destroy, dq %1 %+ __destroy
        iend
%endmacro
