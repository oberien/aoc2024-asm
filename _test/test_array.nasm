fn test_array():
    vars
        local tmparray: Array
    endvars

    ; Test Array<u64>
    Array__with_capacity(lea %$tmparray, u64_Rtti, 10)
    Array__push_u64(lea %$tmparray, 1337)
    Array__push_u64(lea %$tmparray, 42)
    Array__println(lea %$tmparray)
    Array__sort(lea %$tmparray)
    Array__println(lea %$tmparray)
    Array__sort_desc(lea %$tmparray)
    Array__println(lea %$tmparray)
    Array__destroy(lea %$tmparray)
endfn
