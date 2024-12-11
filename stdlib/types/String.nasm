struc String
    .rtti: resq 1
    .ptr: resq 1
    .len: resq 1
    .capacity: resq 1
endstruc

; INPUT:
; * rdi: (out) this-pointer
; * rsi: capacity
section .text
String__with_capacity:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    %define this r12
    %define capacity r13
    mov this, rdi
    mov capacity, rsi

    mov rdi, capacity
    malloc(capacity)
    mov qword [this + String.rtti], String_Rtti
    mov qword [this + String.ptr], rax
    mov qword [this + String.len], 0
    mov qword [this + String.capacity], capacity

    pop r13
    pop r12
    pop rbp
    ret

; INPUT
; * rdi: this-ptr
; * rsi: buffer to copy from
; * rdx: num-bytes
section .text
String__append_raw:
    push rbp
    mov rbp, rsp
    check_rtti rdi, String

    mov rcx, [rdi + String.len]
    add rcx, rdx
    cmp rcx, [rdi + String.capacity]
    jbe .next
    panic `String__append_raw not enough capacity`

    .next:
    mov [rdi + String.len], rcx
    sub rcx, rdx
    mov rdi, [rdi + String.ptr]
    add rdi, rcx
    memcpy(rdi, rsi, rdx)

    pop rbp
    ret


; INPUT:
; * rdi: this-ptr
; OUTPUT:
; * rax: number of lines
section .text
String__count_lines:
    push rbp
    mov rbp, rsp
    check_rtti rdi, String
    %define string rdi

    mov rsi, [string + String.len]
    mov rdi, [string + String.ptr]

    ; number of newlines + 1
    mov rax, 1
    xor ecx, ecx
    .loop:
        cmp rcx, rsi
        jge .end
        cmp byte [rdi + rcx], `\n`
        ; don't set flags
        lea rcx, [rcx + 1]
        jne .loop
        inc rax
        jmp .loop

    .end:
    pop rbp
    ret

section .text
String__print:
    push rbp
    mov rbp, rsp
    check_rtti rdi, String
    mov rsi, [rdi + String.ptr]
    mov rdx, [rdi + String.len]
    mov rdi, STDOUT
    write_all(rdi, rsi, rdx)
    pop rbp
    ret

section .text
String__println:
    push rbp
    mov rbp, rsp
    call String__print
    print_newline()
    pop rbp
    ret

section .text
String__cmp:
    push rbp
    mov rbp, rsp
    check_rtti rdi, String
    check_rtti rsi, String
    %define this r8
    %define other r9
    mov this, rdi
    mov other, rsi

    mov rdi, [this + String.ptr]
    mov rsi, [this + String.len]
    mov rdx, [other + String.ptr]
    mov rcx, [other + String.len]
    memcmp_with_lens(rdi, rsi, rdx, rcx)

    pop rbp
    ret

section .text
String__clone_into:
    push rbp
    mov rbp, rsp
    check_rtti rdi, String
    %define this r12
    %define other r13
    multipush r12, r13
    mov this, rdi
    mov other, rsi

    mov rdi, other
    mov rsi, [this + String.capacity]
    call String__with_capacity

    mov rdi, [other + String.ptr]
    mov rsi, [this + String.ptr]
    mov rdx, [this + String.len]
    memcpy(rdi, rsi, rdx)

    mov rdi, [this + String.len]
    mov [other + String.len], rdi

    multipop r12, r13
    pop rbp
    ret

section .text
String__destroy:
    push rbp
    mov rbp, rsp
    check_rtti rdi, String
    mov rsi, [rdi + String.capacity]
    mov rdi, [rdi + String.ptr]
    free(rdi, rsi)
    pop rbp
    ret
