%include "stdlib-day01/exit.nasm"
%include "stdlib-day01/handleerror.nasm"
%include "stdlib-day01/write.nasm"

%include "stdlib-day01/strlen.nasm"
%include "stdlib-day01/strlines.nasm"
%include "stdlib-day01/skip_whitespace.nasm"
%include "stdlib-day01/atoi.nasm"

%include "stdlib-day01/print.nasm"
%include "stdlib-day01/print_newline.nasm"
%include "stdlib-day01/println.nasm"
%include "stdlib-day01/printc.nasm"
%include "stdlib-day01/printcln.nasm"
%include "stdlib-day01/printnum.nasm"
%include "stdlib-day01/printnumln.nasm"
%include "stdlib-day01/printqwordarray.nasm"

%include "stdlib-day01/sortqwordarray.nasm"

%include "stdlib-day01/assert.nasm"

%include "stdlib-day01/malloc.nasm"
%include "stdlib-day01/open.nasm"
%include "stdlib-day01/lseek.nasm"
%include "stdlib-day01/read.nasm"

; Data Types:

; String: pointer to Array<byte>

; Array<T>: pointer to struct {
;     data-ptr: qword,
;     len: qword,
;     capacity: qword,
; }

; CString: pointer to nul-terminated c-style string

;
