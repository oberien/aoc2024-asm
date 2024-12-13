fn Rtti__print(this: Rtti = reg):
    rodata_cstring .a, `Rtti<`
    rodata_cstring .b, `>`
    cstring__print(.a)
    String__print(%$this.name)
    cstring__print(.b)
endfn

fn Rtti__println(this: Rtti = rdi):
    Rtti__print(%$this)
    print_newline()
endfn

fn Rtti__cmp(this: Rtti = rdi, other: Rtti = rsi):
    cmp rdi, rsi
endfn

fn Rtti__clone_into(this: Rtti = rdi, other: out Rtti = rsi):
    panic `clone_into not applicable for Rtti`
endfn

fn Rtti__destroy(this: Rtti = rdi):
    panic `destroy not applicable for Rtti`
endfn
