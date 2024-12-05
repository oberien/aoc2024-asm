; INPUT:
; * rdi: Array<qword>
section .text
sortqwordarray:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    %define array r12
    %define endindex r13
    %define index r14
    mov array, rdi
    mov endindex, [array+0x8]

    ; bubblesort because it's easiest
    .loop:
        ; check we are done iterating
        cmp endindex, 1
        jbe .end
        mov index, 0
        .loop2:
            ; check if we reached the end (+1 because we bubble forwards)
            lea rdi, [index + 1]
            cmp rdi, endindex
            jae .loop2end
            ; read current and next
            mov rdx, [array]
            mov rdi, [rdx + index * 8]
            mov rsi, [rdx + (index+1) * 8]
            ; check if we need to bubble
            cmp rdi, rsi
            jbe .loop2cont
            ; bubble
            mov [rdx + index * 8], rsi
            mov [rdx + (index+1) * 8], rdi
        .loop2cont:
            inc index
            jmp .loop2
        .loop2end:
            dec endindex
            jmp .loop

    .end:
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
