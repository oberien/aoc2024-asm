; INPUT:
; * rdi: number of bytes
; OUTPUT:
; * rax: ptr
fn malloc(num_bytes: u64):
    ; we store the allocated length at the beginning of
    ; the allocated page to be used for munmap /free
    add %$num_bytes, 8

    syscall_mmap(0, %$num_bytes, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0)

    mov rdi, %$num_bytes
    mov [rax], rdi
    add rax, 8
endfn

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
    panic `aborting`

    .next:
    add rsi, 8
    syscall_munmap(rdi, rsi)

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
