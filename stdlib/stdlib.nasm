; simple helper macros
%include "macros/__is_primitive.nasm"
%include "macros/fn.nasm"
%include "macros/rodata_cstring.nasm"
%include "macros/panic.nasm"
%include "macros/check_rtti.nasm"
%include "macros/dbg.nasm"
%include "macros/min_max.nasm"
%include "macros/multi_push_pop.nasm"

; syscalls
%include "syscalls/handleerror.nasm" ; helper
%include "syscalls/read.nasm" ; 0
%include "syscalls/write.nasm" ; 1
%include "syscalls/open.nasm" ; 2
%include "syscalls/close.nasm" ; 3
%include "syscalls/lseek.nasm" ; 8
%include "syscalls/mmap.nasm" ; 9
%include "syscalls/munmap.nasm" ; 11
%include "syscalls/exit.nasm" ; 60

; syscall wrappers / helpers
%include "helpers/read_all.nasm"
%include "helpers/write_all.nasm"
%include "helpers/malloc.nasm"
%undef ptr
%include "helpers/mem.nasm"
%include "helpers/print_newline.nasm"
%include "helpers/assert.nasm"
%include "helpers/parse.nasm"

; Data Types
%include "types/Rtti.nasm"
%include "types/String.nasm"
gen_Rtti String
%include "types/u64.nasm"
gen_Rtti u64
%undef ptr
%include "types/ptr.nasm"
gen_Rtti ptr
%include "types/cstring.nasm"
gen_Rtti cstring
%include "types/File.nasm"
gen_Rtti File
%include "types/Array.nasm"
gen_Rtti Array

section .text
global _start
_start:
    push rbp
    mov rbp, rsp
    %define args rbp - Array_size
    %define argc r12
    %define argv r13
    sub rsp, Array_size

    ; create Array<cstring> from arguments
    mov argc, [rbp + 0x8]
    lea argv, [rbp + 0x10]
    mov qword [args + Array.rtti], Array_Rtti
    mov qword [args + Array.element_rtti], Array_Rtti
    mov qword [args + Array.ptr], argv
    mov qword [args + Array.len], argc
    mov qword [args + Array.capacity], argc

    lea rdi, [args]
    call main

    syscall_exit(rax)

    ; no stack cleanup needed
    ; we are using the ultimate garbage collector -- the kernel
