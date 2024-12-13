; u64 is a primitive
; u64 doesn't contain the Rtti itself

; INPUT:
; * rdi: u64
; * rsi: radix
; * rdx: alphabet -- must have $rsi bytes
; * rcx: prefix
; * r8: prefix_len
fn u64__print_radix(number: u64 = reg, radix: u64 = reg, alphabet: ptr = reg, prefix: ptr = rcx, prefix_len: u64 = r8)
    ; 64bit integers have up to 19 decimal digits
    ; 8-byte stack alignment -> 24 bytes
    vars
        local first: u64
        local second: u64
        local third: u64
    endvars
    %define %$len rcx
    %define %$content rbp

    ; print prefix
    write_all(STDOUT, %$prefix, %$prefix_len)

    ; convert

    mov rax, %$number
    mov %$len, 0
    .loop:
        xor edx, edx
        div %$radix
        mov dl, [%$alphabet + rdx]
        inc %$len
        mov rdi, %$len
        neg rdi
        mov [%$content + rdi], dl
        test rax, rax
        jnz .loop

    mov rdi, %$len
    neg rdi
    lea rsi, [%$content + rdi]
    write_all(STDOUT, rsi, %$len)
endfn

fn u64__print(this: u64 = rdi):
    rodata_cstring .decbytes, `0123456789`
    mov rsi, 10
    mov rdx, .decbytes
    mov rcx, 0
    mov r8, 0
    u64__print_radix(%$this, 10, .decbytes, NULL, 0)
endfn

fn u64__printhex(this: u64 = rdi)
    rodata_cstring .hexprefix, `0x`
    rodata_cstring .hexbytes, `0123456789abcdef`
    u64__print_radix(%$this, 16, .hexbytes, .hexprefix, 2)
endfn

fn u64__println(this: u64 = rdi):
    u64__print(%$this)
    print_newline()
endfn

fn u64__printhexln(this: u64 = rdi):
    u64__printhex(%$this)
    print_newline()
endfn

fn u64__cmp(this: u64 = rdi, other: u64 = rsi):
    cmp %$this, %$other
endfn

fn u64__clone_into(this: u64 = rdi):
    panic `clone_into not applicable for u64`
endfn

fn u64__destroy(this: u64 = rdi):
    panic `destroy not applicable for u64`
endfn
