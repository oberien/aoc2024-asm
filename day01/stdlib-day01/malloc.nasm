; INPUT
; * rdi: number of bytes
extern _end
section .data
    brk_val: dq _end
    PROT_READ: dq 0x1
    PROT_WRITE: dq 0x2
    PROT_EXEC: dq 0x4
    MAP_SHARED: dq 0x01
    MAP_PRIVATE: dq 0x02
    MAP_ANONYMOUS: dq 0x20

section .text
global malloc
malloc:
    push rbp
    mov rbp, rsp
    push r12
    %define length r12
    mov length, rdi

    mov rsi, rdi
    ; length stored on the page for munmap / free
    add rsi, 8
    mov rax, 9
    mov rdi, 0
    mov rdx, [PROT_READ]
    or rdx, [PROT_WRITE]
    mov r10, [MAP_ANONYMOUS]
    or r10, [MAP_PRIVATE]
    mov r8, -1
    mov r9, 0
    syscall
    call handleerror

    mov [rax], length
    add rax, 8

    pop r12
    pop rbp
    ret

global brkmalloc
brkmalloc:
    push rbp
    mov rbp, rsp
    push r12

    mov r12, [brk_val]

    add rdi, [brk_val]
    add rdi, 4095
    and rdi, 0xffffffffffffe000
    mov [brk_val], rdi
    mov rax, 12
    syscall
    call handleerror

    mov rax, r12

    pop r12
    pop rbp
    ret

; INPUT:
; * rdi: (out) Array<T> where sizeof(T) == rdx
; * rsi: number of elements
; * rdx: size of each element
global calloc
calloc:
    push rbp
    mov rbp, rsp
    push r12
    %define array r12
    mov array, rdi

    mov qword [array+0x8], 0
    mov [array+0x10], rsi

    mov r12, rdi
    mov rdi, rsi
    imul rdi, rdx
    call malloc
    mov [array], rax

    pop r12
    pop rbp
    ret