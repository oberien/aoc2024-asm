; INPUT:
; * rdi: (out) this-pointer
; * rsi: element RTTI
; * rdx: capacity
fn Array__with_capacity(this: out Array = reg, element_rtti: Rtti = rsi, capacity: u64 = reg):
    mov %$this.rtti, Array_Rtti
    mov %$this.element_rtti, %$element_rtti

    mov rdi, %$capacity
    imul rdi, %$element_rtti.size
    malloc(rdi)

    mov %$this.ptr, rax
    mov %$this.len, 0
    mov %$this.capacity, %$capacity
endfn

; INPUT
; * rdi: this-ptr
; * rsi: u64 to push
fn Array__push_u64(this: Array = rdi, element: u64 = rsi):
    assert_eq %$this.element_rtti, u64_Rtti

    mov rcx, %$this.len
    add rcx, 1
    cmp rcx, %$this.capacity
    jbe .next
    panic `Array__push_u64 not enough capacity`

    .next:
    mov rcx, %$this.len
    inc %$this.len
    mov rdi, %$this.ptr
    mov [rdi + rcx * 8], rsi
endfn

; INPUT:
; * rdi: this-ptr
; * rsi: pointer to element to push
fn Array__push(this: Array = rdi, element_ptr: ptr = rsi):
    mov r8, %$this.len
    mov rcx, r8
    add rcx, 1
    cmp rcx, %$this.capacity
    jbe .next
    panic `Array__push not enough capacity`

    .next:
    inc %$this.len

    mov rdx, %$this.element_rtti
    mov rdx, [rdx + Rtti.size]
    imul r8, rdx
    mov rdi, %$this.ptr
    lea rdi, [rdi + r8]
    memcpy(rdi, %$element_ptr, rdx)
endfn

; INPUT:
; * rdi: this-ptr
; * rsi: index
; OUTPUT:
; * rax: element
section .text
fn Array__get(this: Array = rdi, index: u64 = rsi):
    cmp %$index, %$this.len
    jb .next
    panic `Array__get index out of bounds`

    .next:
    mov rax, %$this.element_rtti
    mov rcx, [rax + Rtti.is_primitive]
    mov rax, [rax + Rtti.size]
    imul rax, %$index
    add rax, %$this.ptr
    test rcx, rcx
    cmova rax, [rax]
endfn

; INPUT:
; * rdi: this-ptr
; * rsi: direction (-1 descending, 1 ascending)
fn Array__sort_direction(this: Array = reg, direction: u64 = reg):
    vars
        reg endindex: u64
        reg index: u64
        reg rtti: Rtti
    endvars
    mov %$rtti, %$this.element_rtti
    mov %$endindex, %$this.len

    ; bubblesort
    .loop:
        ; check if we are done
        cmp %$endindex, 1
        jbe .end
        mov %$index, 0
        .loop2:
            ; check if we reached the end (+1 because we compare current with next)
            lea rdi, [%$index + 1]
            cmp rdi, %$endindex
            jae .loop2end
            ; read current
            Array__get(%$this, %$index)
            push rax
            ; read next
            mov rsi, %$index
            add rsi, 1 ; next element
            Array__get(%$this, rsi)
            mov rsi, rax
            pop rdi

            ; compare
            mov rax, %$rtti.cmp
            call rax
            ; check if the comparison matches the requested direction
            mov rax, 1
            mov rcx, -1
            cmovg rax, rcx
            cmp %$direction, rax
            je .loop2cont
            ; swap
            mov rdx, %$rtti.size
            mov rcx, rdx
            imul rcx, %$index
            mov rdi, %$this.ptr
            add rdi, rcx
            mov rsi, rdi
            add rsi, rdx
            memxchg(rdi, rsi, rdx)

            .loop2cont:
            inc %$index
            jmp .loop2
        .loop2end:
        dec %$endindex
        jmp .loop

    .end:
endfn


; INPUT:
; * rdi: this-ptr
fn Array__sort(this: Array = rdi):
    Array__sort_direction(%$this, 1)
endfn

; INPUT:
; * rdi: this-ptr
fn Array__sort_desc(this: Array = rdi):
    Array__sort_direction(%$this, -1)
endfn

; INPUT:
; * rdi: this-ptr
; * rsi: index
fn Array__remove(this: Array = reg, index: u64 = rsi):
    vars
        reg element_ptr: ptr
        reg element_rtti: Rtti
    endvars
    mov %$element_rtti, %$this.element_rtti
    mov %$element_ptr, %$this.ptr
    imul rsi, %$element_rtti.size
    add %$element_ptr, %$index

    mov rax, %$element_rtti.is_primitive
    test rax, rax
    ja .shift_rest

    ; destroy
    mov rax, %$element_rtti.destroy
    mov rdi, %$element_ptr
    call rax

    .shift_rest:
    mov rsi, %$element_ptr
    add rsi, %$element_rtti.size
    mov rdx, %$this.len
    imul rdx, %$element_rtti.size
    add rdx, %$this.ptr
    sub rdx, rsi
    memcpy(%$element_ptr, rsi, rdx)

    sub %$this.len, 1
endfn

fn Array__print(this: Array = reg):
    vars
        reg index: u64
        reg rtti: Rtti
    endvars
    mov %$rtti, %$this.element_rtti

    rodata_cstring .open, `[`
    rodata_cstring .comma, `, `
    cstring__print(.open)

    mov %$index, 0
    .loop:
        cmp %$index, %$this.len
        jae .end
        Array__get(%$this, %$index)
        mov rdi, rax
        mov rax, %$rtti.print
        call rax
        cstring__print(.comma)
        add %$index, 1
        jmp .loop

    .end:
    rodata_cstring .close, `]`
    cstring__print(.close)
endfn

fn Array__println(this: Array = rdi):
    Array__print(%$this)
    print_newline()
endfn

fn Array__cmp(this: Array = reg, other: Array = reg):
    vars
        reg compare: ptr
        reg size: u64
        reg len: u64
    endvars

    Rtti__cmp(%$this.element_rtti, %$other.element_rtti)
    je .rtti_matches
    panic `Array__cmp called with different element-Rtti`

    .rtti_matches:
    mov rax, %$this.element_rtti
    mov %$size, [rax + Rtti.size]
    mov %$compare, [rax + Rtti.cmp]

    mov rax, [rax + Rtti.is_primitive]
    test rax, rax
    jz .not_primitive


    mov rsi, %$this.len
    imul rsi, %$size
    mov rcx, %$other.len
    imul rcx, %$size
    memcmp_with_lens(%$this.ptr, rsi, %$other.ptr, rcx)
    jmp .end

    .not_primitive:
    mov %$len, %$this.len
    min %$len, %$other.len
    ; `%$this` and `%$other` are now ptr
    mov %$this, %$this.ptr
    mov %$other, %$other.ptr
    .loop:
        test %$len, %$len
        jz .equals
        mov rdi, %$this
        mov rsi, %$other
        call %$compare
        jne .end
        add rdi, %$size
        add rsi, %$size
        jmp .loop

    .equals:
    cmp eax, eax
    .end:
endfn

fn Array__clone_into(this: Array = rdi, other: &out Array):
    vars
        reg ptr: ptr
        reg other_ptr: ptr
        reg len: u64
        reg size: u64
        reg clone_into: ptr
        local is_primitive: u64
    endvars
    mov %$ptr, %$this.ptr
    mov %$len, %$this.len
    mov rsi, %$this.element_rtti
    mov %$size, [rsi + Rtti.size]
    mov %$clone_into, [rsi + Rtti.clone_into]
    mov rax, [rsi + Rtti.is_primitive]
    mov %$is_primitive, rax

    mov rdx, %$this.capacity
    Array__with_capacity(%$other, rsi, rdx)
    mov rsi, %$other
    mov %$other_ptr, [rsi + Array.ptr]
    mov [rsi + Array.len], %$len

    mov rax, %$is_primitive
    test rax, rax
    jz .non_primitive

    ; primitive -> memcpy
    mov rdx, %$len
    imul rdx, %$size
    memcpy(%$other_ptr, %$ptr, rdx)
    jmp .end

    .non_primitive:
        test %$len, %$len
        jz .end

        mov rdi, %$ptr
        mov rsi, %$other_ptr
        call %$clone_into

        sub %$len, 1
        add %$ptr, %$size
        add %$other_ptr, %$size
        jmp .non_primitive

    .end:
endfn

fn Array__destroy(this: Array = reg):
    vars
        reg rtti: Rtti
        reg destroy: ptr
    endvars
    mov %$rtti, %$this.rtti
    mov %$destroy, %$rtti.destroy

    cmp %$rtti.is_primitive, 1
    je .end

    ; destroy non-primitive elements starting from the end
    .loop:
        cmp %$this.len, 0
        je .end
        sub %$this.len, 1
        Array__get(%$this, %$this.len)
        mov rdi, rax
        call %$destroy
        jmp .loop

    .end:
    mov rsi, %$rtti.size
    imul rsi, %$this.capacity
    free(%$this.ptr, rsi)
endfn
