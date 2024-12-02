%include "stdlib/exit.nasm"
%include "stdlib/handleerror.nasm"
%include "stdlib/write.nasm"

%include "stdlib/strlen.nasm"
%include "stdlib/strlines.nasm"
%include "stdlib/skip_whitespace.nasm"
%include "stdlib/atoi.nasm"

%include "stdlib/print.nasm"
%include "stdlib/print_newline.nasm"
%include "stdlib/println.nasm"
%include "stdlib/printc.nasm"
%include "stdlib/printcln.nasm"
%include "stdlib/printnum.nasm"
%include "stdlib/printnumln.nasm"
%include "stdlib/printqwordarray.nasm"

%include "stdlib/sortqwordarray.nasm"

%include "stdlib/assert.nasm"

%include "stdlib/malloc.nasm"
%include "stdlib/open.nasm"
%include "stdlib/lseek.nasm"
%include "stdlib/read.nasm"

; Data Types:

; String: pointer to Array<byte>

; Array<T>: pointer to struct {
;     data-ptr: qword,
;     len: qword,
;     capacity: qword,
; }

; CString: pointer to nul-terminated c-style string

;
