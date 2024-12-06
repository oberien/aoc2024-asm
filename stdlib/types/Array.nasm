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
    inc qword [rdi + Array.len]
    mov rdi, [rdi + Array.ptr]
    mov [rdi + rcx * 8], rsi

    pop rbp
    ret

; INPUT:
; * rdi: this-ptr
; * rsi: pointer to element to push
section .text
Array__push:
    push rbp
    mov rbp, rsp
    Array__check_rtti

    mov r8, [rdi + Array.len]
    mov rcx, r8
    add rcx, 1
    cmp rcx, [rdi + Array.capacity]
    jbe .next
    panic `Array__push not enough capacity`

    .next:
    inc qword [rdi + Array.len]

    mov rdx, [rdi + Array.element_rtti]
    mov rdx, [rdx + Rtti.size]
    imul r8, rdx
    mov rdi, [rdi + Array.ptr]
    lea rdi, [rdi + r8]
    call memcpy

    pop rbp
    ret

; INPUT:
; * rdi: this-ptr
section .text
Array__sort:
    push rbp
    mov rbp, rsp
    mov rsi, 1
    call Array__sort_direction
    pop rbp
    ret
; INPUT:
; * rdi: this-ptr
section .text
Array__sort_desc:
    push rbp
    mov rbp, rsp
    mov rsi, -1
    call Array__sort_direction
    pop rbp
    ret

; INPUT:
; * rdi: this-ptr
; * rsi: direction (-1 descending, 1 ascending)
section .text
Array__sort_direction:
    push rbp
    mov rbp, rsp
    %define this r12
    %define endindex r13
    %define index r14
    %define tmp r15
    %define direction rbx
    multipush r12, r13, r14, r15, rbx
    mov this, rdi
    mov endindex, [this + Array.len]
    mov direction, rsi

    ; bubblesort
    .loop:
        ; check if we are done
        cmp endindex, 1
        jbe .end
        mov index, 0
        .loop2:
            ; check if we reached the end (+1 because we compare current with next)
            lea rdi, [index + 1]
            cmp rdi, endindex
            jae .loop2end
            ; read current
            mov rax, [this + Array.element_rtti]
            mov rax, [rax + Rtti.size]
            mov rdi, [this + Array.ptr]
            imul rax, index
            add rdi, rax
            mov rax, [this + Array.element_rtti]
            mov rax, [rax + Rtti.extract_value]
            call rax
            mov tmp, rax

            ; read next
            mov rax, [this + Array.element_rtti]
            mov rax, [rax + Rtti.size]
            mov rdi, [this + Array.ptr]
            add rdi, rax ; one element further
            imul rax, index
            add rdi, rax
            mov rax, [this + Array.element_rtti]
            mov rax, [rax + Rtti.extract_value]
            call rax

            ; compare
            mov rdi, tmp
            mov rsi, rax
            mov rax, [this + Array.element_rtti]
            mov rax, [rax + Rtti.cmp]
            call rax
            ; check if the comparison matches the requested direction
            mov rax, 1
            mov rcx, -1
            cmovg rax, rcx
            cmp direction, rax
            je .loop2cont
            ; swap
            mov rdx, [this + Array.element_rtti]
            mov rdx, [rdx + Rtti.size]
            mov rcx, rdx
            imul rcx, index
            mov rdi, [this + Array.ptr]
            add rdi, rcx
            mov rsi, rdi
            add rsi, rdx
            call memxchg

            .loop2cont:
            inc index
            jmp .loop2
        .loop2end:
        dec endindex
        jmp .loop

    .end:
    multipop r12, r13, r14, r15, rbx
    pop rbp
    ret

section .text
Array__extract_value:
    push rbp
    mov rbp, rsp
    mov rax, rdi
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
        mov rax, [rtti + Rtti.extract_value]
        call rax

        mov rdi, rax
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
Array__cmp:
    push rbp
    mov rbp, rsp
    Array__check_rtti
    %define this r8
    %define other r9
    mov this, rdi
    mov other, r9

    mov rdi, [this + Array.ptr]
    mov rsi, [this + Array.len]
    mov rdx, [other + Array.ptr]
    mov rcx, [other + Array.len]
    call memcmp_with_lens

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
