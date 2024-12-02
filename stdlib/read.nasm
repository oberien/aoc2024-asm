; INPUT:
; * rdi: file descriptor
; * rsi: buffer
; * rdx: num bytes
; OUTPUT:
; * rax: number of bytes read
section .text
global read
read:
    push rbp
    mov rbp, rsp

    mov rax, 0
    syscall
    call handleerror

    pop rbp
    ret

; INPUT:
; * rdi: file descriptor
; * rsi: buffer
; * rdx: num bytes
; OUTPUT:
; * rax: number of bytes read
global read_all
read_all:
    push rbp
    mov rbp, rsp
    push r12 ; file descriptor
    push r13
    push r14
    push r15
    %define fd r12
    %define buffer r13
    %define len r14
    mov fd, rdi
    mov buffer, rsi
    mov len, rdx
    mov r15, rdx

    .loop:
        mov rdi, fd
        mov rsi, buffer
        mov rdx, len
        call read
        sub len, rax
        add buffer, rax
        mov rdi, rax
        ; file end
        test rax, rax
        jz .done
        ; buffer full
        test len, len
        jz .done
        jmp .loop


    .done:
    sub r15, r14
    mov rax, r15

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; INPUT:
; * rdi: file path CString
; * rsi: (out) String
global read_file
read_file:
    push rbp
    mov rbp, rsp
    push r12 ; file descriptor
    push r13 ; file length
    push r14 ; String
    %define string r14
    mov string, rsi


    ; open file
    mov rsi, [O_RDONLY]
    xor edx, edx
    call open
    mov r12, rax

    ; seek to end of file to get file length
    mov rdi, r12
    mov rsi, 0
    mov rdx, [SEEK_END]
    call lseek
    mov r13, rax
    ; seek back to the beginning
    mov rdi, r12
    mov rsi, 0
    mov rdx, [SEEK_SET]
    call lseek
    mov rdi, rax
    mov rsi, 0
    call assert_eq

    ; calloc space
    mov rdi, string
    mov rsi, r13
    mov rdx, 1
    call calloc
    mov [string+0x8], r13

    ; read all
    mov rdi, r12
    mov rsi, [string]
    mov rdx, [string+0x8]
    call read_all
    mov rdi, rax
    mov rsi, r13
    call assert_eq

    ; TODO: close file

    pop r14
    pop r13
    pop r12
    pop rbp
    ret