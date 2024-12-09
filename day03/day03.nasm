%include "stdlib.nasm"


%undef this
%undef other


fn main(this: Array):

endfn

fn foo(_this: Array, _other: cstring, _next: String):
    vars
        local foo: Array
        local bar: Array
        local baz: Array
        reg this: u64
        reg other: Array
        reg next: Array
        reg quux: Array
        reg corge: Array
    endvars
    mov %$this, %$_this
    mov %$other, %$_other
    mov %$next, %$_next
    lea rdi, [%$foo]
    lea rsi, [%$bar]
    lea rdx, [%$baz]
endfn

foo(5, 3, 7)
