struc File
    .rtti: resq 1
    .fd: resq 1
endstruc

; doesn't modify any registers
%macro File__check_rtti 0
    cmp qword [rdi], File_Rtti
    je %%end
    panic `File operation called without a File`
    %%end:
%endmacro

; INPUT:
; * rdi: (out) this-pointer
; * rsi: cstring filename
section .text
File__open:
    push rbp
    mov rbp, rsp
    %define this r12
    push r12
    mov this, rdi

    mov rdi, rsi
    mov rsi, O_RDONLY
    xor edx, edx
    call syscall_open
    mov qword [this + File.rtti], File_Rtti
    mov [this + File.fd], rax

    pop r12
    pop rbp
    ret

; INPUT:
; * rdi: this-ptr
; OUTPUT:
; * rax: total length of file
; * rdi: left to read
section .text
File__len:
    push rbp
    mov rbp, rsp
    File__check_rtti
    %define this r12
    %define current r13
    %define len r14
    push r12
    push r13
    push r14
    mov this, rdi

    ; get current position
    mov rdi, this
    mov rsi, 0
    mov rdx, SEEK_CUR
    call File__seek
    mov current, rax

    ; get maximum position = length
    mov rdi, this
    mov rsi, 0
    mov rdx, SEEK_END
    call File__seek
    mov len, rax

    ; seek back to previous position
    mov rdi, this
    mov rsi, current
    mov rdx, SEEK_SET
    call File__seek

    mov rax, len
    mov rdi, rax
    sub rdi, current

    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; INPUT:
; * rdi: this-ptr
; * rsi: (out) String
section .text
File__read_to_string:
    push rbp
    mov rbp, rsp
    File__check_rtti
    %define this r12
    %define string r13
    %define to_read r14
    push r12
    push r13
    push r14
    mov this, rdi
    mov string, rsi

    ; get number of bytes left to read
    mov rdi, this
    call File__len
    mov to_read, rdi

    ; create string
    mov rdi, string
    mov rsi, to_read
    call String__with_capacity

    ; read all
    mov rdi, [this + File.fd]
    mov rsi, [string + String.ptr]
    mov rdx, to_read
    call read_all
    assert_eq rax, to_read

    mov [string + String.len], to_read

    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; INPUT:
; * rdi: this-ptr
; * rsi: offset
; * rdx: whence (SEEK_SET, SEEK_CUR, SEEK_END)
; OUTPUT:
; * rax: new position
section .text
File__seek:
    push rbp
    mov rbp, rsp
    File__check_rtti

    mov rdi, [rdi + File.fd]
    call syscall_lseek

    pop rbp
    ret

section .text
File__extract_value:
    push rbp
    mov rbp, rsp
    mov rax, rdi
    pop rbp
    ret

section .text
File__print:
    push rbp
    mov rbp, rsp
    File__check_rtti
    %define this r12
    push r12
    mov this, rdi

    rodata_cstring .s, `File with fd=`
    mov rdi, .s
    call cstring__print
    mov rdi, [this + File.fd]
    call u64__print

    pop r12
    pop rbp
    ret

section .text
File__println:
    push rbp
    mov rbp, rsp
    call File__print
    call print_newline
    pop rbp
    ret

File__cmp equ 0

section .text
File__destroy:
    push rbp
    mov rbp, rsp
    File__check_rtti
    mov rdi, [rdi + File.fd]
    call syscall_close
    pop rbp
    ret
