%define NULL 0

%define String__is_primitive 0
define_struct String, rtti, ptr, len, capacity

%define cstring__is_primitive 1
cstring_size equ 8
gen_Rtti cstring
%macro __cstring__create_fields__ 2
%endmacro

%define Array__is_primitive 0
define_struct Array, rtti, element_rtti, ptr, len, capacity

%define File__is_primitive 0
define_struct File, rtti, fd

%define u64__is_primitive 1
u64_size equ 8
gen_Rtti u64
%macro __u64__create_fields__ 2
%endmacro

%define ptr__is_primitive 1
ptr_size equ 8
gen_Rtti ptr
%macro __ptr__create_fields__ 2
%endmacro
