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
    ; String has 32 bytes -> works here
    vars
        local dummy: String
    endvars
    %define %$len rcx
    %define %$content r9
    lea %$content, [%$dummy]

    ; print prefix
    write_all(STDOUT, %$prefix, %$prefix_len)

    ; convert

    ; We are dividing the number with modulo.
    ; As such, we need to write each digit from back to front.
    ; If we convert 1337 as decimal, we need have the following stack layout
    ; afterwards:
    ;        +--+--+--+--++--+--+--+--+
    ; rsp -> |00|00|00|00||00|00|00|00| <- content
    ;        |00|00|00|00||00|00|00|00|
    ;        |00|00|00|00||00|00|00|00|
    ;        |00|00|00|00||31|33|33|37|
    ;        +--+--+--+--++--+--+--+--+
    ; r14    |00|00|00|00||00|00|00|00|
    ; r13    |00|00|00|00||00|00|00|00|
    ; r12    |00|00|00|00||00|00|00|00|
    ;        +--+--+--+--++--+--+--+--+

    mov rax, %$number
    mov %$len, 0
    .loop:
        xor edx, edx
        div %$radix
        mov dl, [%$alphabet + rdx]
        inc %$len
        mov rdi, %$len
        neg rdi
        ; the byte from the back is content + 32 - len
        mov [%$content + 32 + rdi], dl
        test rax, rax
        jnz .loop

    mov rdi, %$len
    neg rdi
    lea rsi, [%$content + 32 + rdi]
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

fn u64__clone_into(this: u64 = rdi, other: out u64 = rsi):
    panic `clone_into not applicable for u64`
endfn

fn u64__destroy(this: u64 = rdi):
    panic `destroy not applicable for u64`
endfn
