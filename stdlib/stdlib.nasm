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
%include "rodata_cstring.nasm"
%include "read_all.nasm"
%include "write_all.nasm"
%include "panic.nasm"
%include "malloc.nasm"
%include "memcpy.nasm"
%include "print_newline.nasm"
%include "assert.nasm"
%include "parse.nasm"

; Data Types
%include "types/Rtti.nasm"
%include "types/String.nasm"
gen_Rtti String
%include "types/u64.nasm"
gen_Rtti u64
%include "types/cstring.nasm"
gen_Rtti cstring
%include "types/File.nasm"
gen_Rtti File
%include "types/Array.nasm"
gen_Rtti Array

;%include "sortqwordarray.nasm"
