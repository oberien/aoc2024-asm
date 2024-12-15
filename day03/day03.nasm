%include "stdlib.nasm"


%undef this
%undef other


; try parsing `mul(\d{,3},\d{,3})`
; OUTPUT:
; * rsi: index after parse-try
; * rax: result of multiplication (0 if not parseable)
fn try_parse_mul(input: String = reg, index: u64 = reg):
    vars
        reg first: u64
        reg second: u64
        reg result: u64
    endvars
    mov %$result, 0

    consume_char_eq(%$input, %$index, 'm')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, 'u')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, 'l')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, '(')
    jne .end
    mov %$index, rsi
    atoi(%$input, %$index)
    cmp %$index, rsi
    je .end
    cmp rax, 1000
    jge .end
    mov %$index, rsi
    mov %$first, rax
    consume_char_eq(%$input, %$index, ',')
    jne .end
    mov %$index, rsi
    atoi(%$input, %$index)
    cmp %$index, rsi
    je .end
    cmp rax, 1000
    jge .end
    mov %$index, rsi
    mov %$second, rax
    consume_char_eq(%$input, %$index, ')')
    jne .end

    mov %$result, %$first
    imul %$result, %$second

    .end:
    mov rax, %$result
    mov rsi, %$index
endfn

fn part1(input: String = reg):
    vars
        reg index: u64
        reg sum: u64
    endvars
    rodata_cstring .s, "part1: "
    cstring__print(.s)

    mov %$index, 0
    while (%$index < %$input.len):
        try_parse_mul(%$input, %$index)
        add %$sum, rax
        if (%$index == rsi):
            add %$index, 1
        else:
            mov %$index, rsi
        endif
    endwhile
    u64__println(%$sum)
endfn

; try parsing `do()`
; OUTPUT:
; * rsi: index after parse-try
; * EFLAGS: EQ if matched
fn try_parse_do(input: String = reg, index: u64 = reg):
    consume_char_eq(%$input, %$index, 'd')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, 'o')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, '(')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, ')')
    jne .end
    mov %$index, rsi
    .end:
    mov rsi, %$index
endfn
; try parsing `don't()`
; OUTPUT:
; * rsi: index after parse-try
; * EFLAGS: EQ if matched
fn try_parse_dont(input: String = reg, index: u64 = reg):
    consume_char_eq(%$input, %$index, 'd')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, 'o')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, 'n')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, "'")
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, 't')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, '(')
    jne .end
    mov %$index, rsi
    consume_char_eq(%$input, %$index, ')')
    jne .end
    mov %$index, rsi
    .end:
    mov rsi, %$index
endfn

fn part2(input: String = reg):
    vars
        reg index: u64
        reg sum: u64
        ; 0 do parse, 1 don't parse
        reg state: u64
    endvars
    rodata_cstring .s, "part2: "
    cstring__print(.s)

    mov %$state, 0
    mov %$index, 0
    for (%$index = 0, %$index < %$input.len, inc %$index):
        if (%$state == 0):
            try_parse_mul(%$input, %$index)
            add %$sum, rax
            try_parse_dont(%$input, %$index)
            mov rax, 1
            cmovz %$state, rax
        else:
            try_parse_do(%$input, %$index)
            mov rax, 0
            cmovz %$state, rax
        endif
    endfor
    u64__println(%$sum)
endfn

fn main(args: Array = rdi):
    vars
        local file: File
        local content: String
    endvars
    Array__get(%$args, 1)
    File__open(lea %$file, rax)
    File__read_to_string(lea %$file, lea %$content)
    String__println(lea %$content)
    part1(lea %$content)
    part2(lea %$content)
    mov rax, 0
endfn

