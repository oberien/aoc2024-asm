; INPUT:
; * rdi: String-ptr
; * rsi: index
; OUTPUT:
; * rdi: String-ptr
; * rsi: new index after number
; * rax: u64 number
fn atoi(string: &String, _index: u64):
    vars
        reg ptr: ptr
        reg len: u64
        reg index: u64
    endvars
    mov rdi, %$string
    mov %$ptr, [rdi + String.ptr]
    mov %$len, [rdi + String.len]
    mov %$index, %$_index

    xor eax, eax
    .loop:
        cmp %$index, %$len
        jae .end
        xor ecx, ecx
        mov cl, [%$ptr + %$index]
        cmp cl, `0`
        jb .end
        cmp cl, `9`
        ja .end
        imul rax, 10
        sub cl, `0`
        add rax, rcx
        inc %$index
        jmp .loop

    .end:
    mov rdi, %$string
    mov rsi, %$index
endfn

; INPUT:
; * rdi: String-ptr
; * rsi: index
; OUTPUT:
; * rdi: String-ptr (not clobbered)
; * rsi: index after whitespace
; * rax: number of newline characters skipped
fn skip_whitespace(string: &String, index: u64):
    vars
        reg ptr: ptr
        reg len: u64
    endvars
    mov rdi, %$string
    mov %$ptr, [rdi + String.ptr]
    mov %$len, [rdi + String.len]

    xor eax, eax
    .loop:
        cmp %$index, %$len
        mov rdi, %$index
        mov dl, byte [%$ptr + rdi]
        jae .end
        cmp dl, ` `
        je .continue
        cmp dl, `\t`
        je .continue
        cmp dl, `\r`
        je .continue
        cmp dl, `\n`
        je .line
        cmp dl, `\v`
        je .continue
        cmp dl, `\f`
        je .continue
        jmp .end
        .line:
        inc rax
        .continue:
        inc %$index
        jmp .loop

    .end:
    mov rdi, %$string
    mov rsi, %$index
endfn

; INPUT:
; * rdi: String-ptr
; * rsi: index
; * rdx: (out) Array<u64>
; OUTPUT:
; * rdi: String-ptr (not clobbered)
; * rsi: index after the line
fn parse_line_as_u64_array(_string: &String, _index: u64, out_array: &out Array):
    vars
        reg string: ptr
        reg index: u64
    endvars
    mov %$string, %$_string
    mov %$index, %$_index

    .loop:
        cmp %$index, [%$string + String.len]
        jae .end

        skip_whitespace(%$string, %$index)
        mov %$index, rsi
        test rax, rax
        jnz .end

        atoi(%$string, %$index)
        mov %$index, rsi

        mov rdi, %$out_array
        mov rsi, rax
        call Array__push_u64

        jmp .loop

    .end:
    mov rdi, %$string
    mov rsi, %$index
endfn
