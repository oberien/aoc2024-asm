; simple helper macros
%include "macros/macro_string_ops.nasm"
%include "macros/parse_condition.nasm"
%include "macros/macro_array_ops.nasm"
%include "macros/if.nasm"
%include "macros/call.nasm"
%include "macros/rtti.nasm"
%include "macros/types.nasm"
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
%include "helpers/mem.nasm"
%include "helpers/print_newline.nasm"
%include "helpers/assert.nasm"

; Data Types
%include "type_impls/String.nasm"
%include "type_impls/u64.nasm"
%include "type_impls/ptr.nasm"
%include "type_impls/cstring.nasm"
%include "type_impls/Rtti.nasm"
%include "type_impls/File.nasm"
%include "type_impls/Array.nasm"

; late helpers requiring fn calls to types
%include "helpers/parse.nasm"

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
