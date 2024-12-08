struc Array
    .rtti: resq 1
    .element_rtti: resq 1
    .ptr: resq 1
    .len: resq 1
    .capacity: resq 1
endstruc

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
    check_rtti rdi, Array
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
    check_rtti rdi, Array

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
    check_rtti rdi, Array
    %define this r12
    %define endindex r13
    %define index r14
    %define rtti r15
    %define direction rbx
    multipush r12, r13, r14, r15, rbx
    mov this, rdi
    mov rtti, [this + Array.element_rtti]
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
            mov rax, [rtti + Rtti.size]
            mov rdi, [this + Array.ptr]
            imul rax, index
            add rdi, rax
            mov rax, [rtti + Rtti.is_primitive]
            test rax, rax
            cmovnz rdi, [rdi]

            ; read next
            mov rax, [rtti + Rtti.size]
            mov rsi, [this + Array.ptr]
            add rsi, rax ; one element further
            imul rax, index
            add rsi, rax
            mov rax, [rtti + Rtti.is_primitive]
            test rax, rax
            cmovnz rsi, [rsi]

            ; compare
            mov rax, [rtti + Rtti.cmp]
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

; INPUT:
; * rdi: this-ptr
; * rsi: index
; OUTPUT:
; * rax: element
section .text
Array__get:
    push rbp
    mov rbp, rsp
    check_rtti rdi, Array
    %define this rdi

    cmp rsi, [this + Array.len]
    jb .next
    panic `Array__get index out of bounds`

    .next:
    mov rax, [this + Array.rtti]
    mov rcx, [rax + Rtti.is_primitive]
    mov rax, [rax + Rtti.size]
    imul rax, rsi
    add rax, [this + Array.ptr]
    test rcx, rcx
    cmova rax, [rax]

    pop rbp
    ret

; INPUT:
; * rdi: this-ptr
section .text
Array__remove:
    push rbp
    mov rbp, rsp
    check_rtti rdi, Array
    %define this r12
    %define element_ptr r13
    %define element_rtti r14
    multipush r12, r13, r14
    mov this, rdi
    mov element_rtti, [this + Array.element_rtti]

    mov element_ptr, [this + Array.ptr]
    imul rsi, [element_rtti + Rtti.size]
    add element_ptr, rsi

    mov rax, [element_rtti + Rtti.is_primitive]
    test rax, rax
    ja .shift_rest

    ; destroy
    mov rax, [element_rtti + Rtti.destroy]
    mov rdi, element_ptr
    call rax

    .shift_rest:
    mov rdi, element_ptr
    mov rsi, element_ptr
    add rsi, [element_rtti + Rtti.size]
    mov rdx, [this + Array.len]
    imul rdx, [element_rtti + Rtti.size]
    add rdx, [this + Array.ptr]
    sub rdx, rsi
    call memcpy

    sub qword [this + Array.len], 1

    multipop r12, r13, r14
    pop rbp
    ret

Array__is_primitive equ 0

section .text
Array__print:
    push rbp
    mov rbp, rsp
    check_rtti rdi, Array
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
        mov rax, [rtti + Rtti.is_primitive]
        test rax, rax
        cmovnz rdi, [rdi]

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
    check_rtti rdi, Array
    check_rtti rsi, Array
    %define this r12
    %define other r13
    %define compare r14
    %define size r15
    %define len rbx
    multipush r12, r13, r14, r15, rbx
    mov this, rdi
    mov other, rsi

    mov rax, [this + Array.element_rtti]
    mov rdx, [other + Array.element_rtti]


    mov rax, [rax + Rtti.is_primitive]
    test rax, rax
    jz .not_primitive

    mov rdi, [this + Array.ptr]
    mov rsi, [this + Array.len]
    mov rdx, [other + Array.ptr]
    mov rcx, [other + Array.len]
    call memcmp_with_lens
    jmp .end

    .not_primitive:
    mov size, [rax + Rtti.size]
    mov compare, [rax + Rtti.cmp]
    mov len, [this + Array.len]
    min len, [other + Array.len]
    ; `this` and `other` are now ptr
    mov this, [this + Array.ptr]



    .end:
    multipop r12, r13, r14, r15, rbx
    pop rbp
    ret

section .text
Array__clone_into:
    push rbp
    mov rbp, rsp
    %define ptr r12
    %define other_ptr r13
    %define len r14
    %define size r15
    %define clone_into rbx
    multipush r12, r13, r14, r15, rbx
    push rsi
    mov ptr, [rdi + Array.ptr]
    mov len, [rdi + Array.len]
    mov rsi, [rdi + Array.element_rtti]
    mov size, [rsi + Rtti.size]
    mov clone_into, [rsi + Rtti.clone_into]
    mov rax, [rsi + Rtti.is_primitive]
    push rax

    mov rdx, [rdi + Array.capacity]
    mov rdi, [rsp + 0x8]
    call Array__with_capacity
    pop rax
    pop rsi
    mov other_ptr, [rsi + Array.ptr]
    mov [rsi + Array.len], len

    test rax, rax
    jz .non_primitive

    ; primitive -> memcpy
    mov rdi, other_ptr
    mov rsi, ptr
    mov rdx, len
    imul rdx, size
    call memcpy
    jmp .end

    .non_primitive:
        test len, len
        jz .end

        mov rdi, ptr
        mov rsi, other_ptr
        call clone_into

        sub len, 1
        add ptr, size
        add other_ptr, size
        jmp .non_primitive

    .end:
    multipop r12, r13, r14, r15, rbx
    pop rbp
    ret

section .text
Array__destroy:
    push rbp
    mov rbp, rsp
    check_rtti rdi, Array
    mov rsi, [rdi + Array.element_rtti]
    mov rsi, [rsi + Rtti.size]
    imul rsi, [rdi + Array.capacity]
    mov rdi, [rdi + Array.ptr]
    call free
    pop rbp
    ret
