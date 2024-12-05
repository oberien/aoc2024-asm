; INPUT
; * rdi: number of bytes
section .text
malloc:
    ; we store the allocated length at the beginning of
    ; the allocated page to be used for munmap /free
    push rbp
    mov rbp, rsp
    push r12
    %define length r12
    add rdi, 8
    mov length, rdi

    mov rsi, length
    mov rdi, 0
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_ANONYMOUS | MAP_PRIVATE
    mov r8, -1
    mov r9, 0
    call syscall_mmap

    mov [rax], length
    add rax, 8

    pop r12
    pop rbp
    ret

; INPUT:
; * rdi: ptr to free (must have been created via malloc)
; * rsi: length of the allocation as requested to malloc
section .text
free:
    push rbp
    mov rbp, rsp

    sub rdi, 8
    test rdi, 0x0fff
    jz .next
    mov r12, rdi
    rodata_cstring .err, `free called with non-aligned pointer: `
    mov rdi, .err
    call cstring__print
    mov rdi, r12
    call u64__printhexln
    panic `aborting\n`

    .next:
    add rsi, 8
    call syscall_munmap

    pop rbp
    ret

extern _end
section .data
    brk_val: dq _end

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