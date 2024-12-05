struc Array
    .rtti: resq 1
    .element_rtti: resq 1
    .ptr: resq 1
    .len: resq 1
    .capacity: resq 1
endstruc

; doesn't modify any registers
%macro Array__check_rtti 0
    cmp qword [rdi], Array_Rtti
    je %%end
    panic `Array operation called without a Array`
    %%end:
%endmacro

; INPUT:
; * rdi: (out) this-pointer
; * rsi: element RTTI
; * rdx: capacity
section .text
Array__with_capacity:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    %define this r12
    %define capacity r13
    mov this, rdi
    mov capacity, rdx

    mov qword [this + Array.rtti], Array_Rtti
    mov [this + Array.element_rtti], rsi

    mov rdi, capacity
    imul rdi, [rsi + Rtti.size]

    call malloc
    mov qword [this + Array.ptr], rax
    mov qword [this + Array.len], 0
    mov qword [this + Array.capacity], capacity

    pop r13
    pop r12
    pop rbp
    ret

; INPUT
; * rdi: this-ptr
; * rsi: u64 to push
section .text
Array__push_u64:
    push rbp
    mov rbp, rsp
    Array__check_rtti
    assert_eq [rdi + Array.element_rtti], u64_Rtti

    mov rcx, [rdi + Array.len]
    add rcx, 1
    cmp rcx, [rdi + Array.capacity]
    jbe .next
    panic `Array__push_u64 not enough capacity`

    .next:
    mov rcx, [rdi + Array.len]
    mov rdi, [rdi + Array.ptr]
    mov [rdi + rcx * 8], rsi
    add qword [rdi + Array.len], 1

    pop rbp
    ret

section .text
Array__print:
    push rbp
    mov rbp, rsp
    Array__check_rtti
    %define this r12
    %define len_left r13
    %define rtti r14
    %define ptr r15
    push r12
    push r13
    push r14
    push r15
    mov this, rdi
    mov len_left, [this + Array.len]
    mov ptr, [this + Array.ptr]
    mov rtti, [rdi + Array.element_rtti]

    rodata_cstring .open, `[`
    rodata_cstring .comma, `, `
    mov rdi, .open
    call cstring__print

    .loop:
        test len_left, len_left
        jz .end
        mov rdi, ptr
        mov rax, [rtti + Rtti.print]
        call rax

        mov rdi, .comma
        call cstring__print

        add ptr, [rtti + Rtti.size]
        dec len_left
        jmp .loop

    .end:
    rodata_cstring .close, `]`
    mov rdi, .close
    call cstring__print

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

section .text
Array__println:
    push rbp
    mov rbp, rsp
    call Array__print
    call print_newline
    pop rbp
    ret

section .text
Array__equals:
    push rbp
    mov rbp, rsp
    Array__check_rtti
    ud2 ; TODO
    pop rbp
    ret

section .text
Array__cmp:
    push rbp
    mov rbp, rsp
    Array__check_rtti
    ud2 ; TODO
    pop rbp
    ret

section .text
Array__destroy:
    push rbp
    mov rbp, rsp
    Array__check_rtti
    mov rsi, [rdi + Array.element_rtti]
    mov rsi, [rsi + Rtti.size]
    imul rsi, [rdi + Array.capacity]
    mov rdi, [rdi + Array.ptr]
    call free
    pop rbp
    ret
