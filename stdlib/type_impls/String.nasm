; INPUT:
; * rdi: (out) this-pointer
; * rsi: capacity
fn String__with_capacity(this: &out String, capacity: u64):
    malloc(%$capacity)
    mov rdi, %$this
    mov rsi, %$capacity
    mov qword [rdi + String.rtti], String_Rtti
    mov qword [rdi + String.ptr], rax
    mov qword [rdi + String.len], 0
    mov qword [rdi + String.capacity], rsi
endfn

; INPUT
; * rdi: this-ptr
; * rsi: buffer to copy from
; * rdx: num-bytes
fn String__append_raw(this: String = rdi, buffer: ptr = rsi, num_bytes: u64 = rdx):
    mov rcx, [%$this + String.len]
    add rcx, %$num_bytes
    cmp rcx, [%$this + String.capacity]
    jbe .next
    panic `String__append_raw not enough capacity`

    .next:
    mov rax, [%$this + String.ptr]
    add rax, [%$this + String.len]
    mov [%$this + String.len], rcx
    memcpy(rax, %$buffer, %$num_bytes)
endfn

; INPUT:
; * rdi: this-ptr
; * rsi: 1-byte char
; OUTPUT:
; * rax: index of needle or -1 if not found
fn String__index_of(this: String = rdi, needle: u64 = rsi):
    mov rdx, %$needle
    for (rcx = 0, rcx < %$this.len, inc rcx):
        mov rax, %$this.ptr
        if ([rax + rcx] == dl):
            mov rax, rcx
            jmp .end
        endif
    endfor

    .fail:
        mov rax, -1
    .end:
endfn


; INPUT:
; * rdi: this-ptr
; OUTPUT:
; * rax: number of lines
fn String__count_lines(this: String = rdi):
    mov rsi, [rdi + String.len]
    mov rdi, [rdi + String.ptr]

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
endfn

fn String__print(this: String = rdi):
    mov rsi, [%$this + String.ptr]
    mov rdx, [%$this + String.len]
    mov rdi, STDOUT
    write_all(rdi, rsi, rdx)
endfn

fn String__println(this: String = rdi):
    String__print(%$this)
    print_newline()
endfn

fn String__cmp(this: String = rdi, other: String = rsi):
    mov rdx, [%$other + String.ptr]
    mov rcx, [%$other + String.len]
    mov rsi, [%$this + String.len]
    mov rdi, [%$this + String.ptr]
    memcmp_with_lens(rdi, rsi, rdx, rcx)
endfn

fn String__clone_into(this: String = reg, other: out String = reg):
    String__with_capacity(%$other, %$this.capacity)
    memcpy(%$other.ptr, %$this.ptr, %$this.len)

    mov rdi, %$this.len
    mov %$other.len, rdi
endfn

fn String__destroy(this: String = rdi):
    mov rsi, [%$this + String.capacity]
    mov rdi, [%$this + String.ptr]
    free(rdi, rsi)
endfn
