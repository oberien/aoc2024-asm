; cstring is a primitive
; cstring doesn't contain the Rtti itself
; cstring is a pointer to a nul-terminated string

; keyword for searching: strlen
; OUTPUT:
; * rax: length without the trailing nul-byte
fn cstring__len(this: cstring = rdi):
    mov rsi, %$this

    xor ecx, ecx
    dec rcx
    xor eax,eax
    repne scasb

    sub rdi, rsi
    dec rdi
    mov rax, rdi
endfn

fn cstring__print(this: cstring = reg):
    cstring__len(%$this)
    write_all(STDOUT, %$this, rax)
endfn

fn cstring__println(this: cstring = rdi):
    cstring__print(%$this)
    print_newline()
endfn

fn cstring__cmp(this: cstring = reg, other: cstring = reg):
    vars
        reg this_len: u64
        reg other_len: u64
    endvars

    cstring__len(%$this)
    mov %$this_len, rax

    cstring__len(%$other)
    mov %$other_len, rax

    memcmp_with_lens(%$this, %$this_len, %$other, %$other_len)
endfn

fn cstring__clone_into(this: cstring = rdi):
    panic `clone_into not applicable for cstring`
endfn

fn cstring__destroy(this: cstring = rdi):
    panic `destroy not applicable for cstring`
endfn
