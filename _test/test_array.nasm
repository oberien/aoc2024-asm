fn test_array():
    vars
        local tmparray: Array
    endvars

    ; Test Array<u64>
    lea rdi, %$tmparray
    mov rsi, u64_Rtti
    mov rdx, 10
    call Array__with_capacity

    lea rdi, %$tmparray
    mov rsi, 1337
    call Array__push_u64

    lea rdi, %$tmparray
    mov rsi, 42
    call Array__push_u64

    lea rdi, %$tmparray
    call Array__println

    lea rdi, %$tmparray
    call Array__sort
    lea rdi, %$tmparray
    call Array__println

    lea rdi, %$tmparray
    call Array__sort_desc
    lea rdi, %$tmparray
    call Array__println

    lea rdi, %$tmparray
    call Array__destroy
endfn
