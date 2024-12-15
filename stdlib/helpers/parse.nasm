; INPUT:
; * rdi: String-ptr
; * rsi: index
; OUTPUT:
; * rsi: new index after number
; * rax: u64 number
fn atoi(string: String = rdi, index: u64 = rsi):
    vars
        reg ptr: ptr
    endvars
    mov %$ptr, %$string.ptr

    xor eax, eax
    .loop:
        cmp %$index, %$string.len
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
endfn

; INPUT:
; * rdi: String-ptr
; * rsi: index
; OUTPUT:
; * rsi: index after whitespace
; * rax: number of newline characters skipped
fn skip_whitespace(string: String = rdi, index: u64 = rsi):
    vars
        reg ptr: ptr
    endvars
    mov %$ptr, %$string.ptr

    xor eax, eax
    .loop:
        cmp %$index, %$string.len
        mov r9, %$index
        mov dl, byte [%$ptr + r9]
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
endfn

; Parses a line with whitespace-separated numbers into an Array<u64>
; INPUT:
; * rdi: String-ptr
; * rsi: index
; * rdx: (out) Array<u64>
; OUTPUT:
; * rsi: index after the line
fn parse_line_as_u64_array(string: String = reg, index: u64 = reg, out_array: &out Array):
    .loop:
        cmp %$index, %$string.len
        jae .end

        skip_whitespace(%$string, %$index)
        mov %$index, rsi
        test rax, rax
        jnz .end

        atoi(%$string, %$index)
        mov %$index, rsi
        Array__push_u64(%$out_array, rax)

        jmp .loop

    .end:
    mov rsi, %$index
endfn

; Consume a char if it matches the provided char.
; OUTPUT:
; * rsi: index after line
; * EFLAGS are set to comparison between String-character and passed char.
fn consume_char_eq(string: String = rdi, index: u64 = rsi, char: u64 = rdx):
    mov rax, rsi
    lea rcx, [rsi + 1]
    mov rdi, %$string.ptr
    cmp [rdi + %$index], dl
    cmove rsi, rcx
endfn
