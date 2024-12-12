%define cstring__is_primitive 1
cstring_size equ 8

%define Array__is_primitive 0
struc Array
    .rtti: resq 1
    .element_rtti: resq 1
    .ptr: resq 1
    .len: resq 1
    .capacity: resq 1
endstruc

%define File__is_primitive 0
struc File
    .rtti: resq 1
    .fd: resq 1
endstruc

%define String__is_primitive 0
struc String
    .rtti: resq 1
    .ptr: resq 1
    .len: resq 1
    .capacity: resq 1
endstruc

%define u64__is_primitive 1
u64_size equ 8

%define ptr__is_primitive 1
ptr_size equ 8
