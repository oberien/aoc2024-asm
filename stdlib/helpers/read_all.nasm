; INPUT:
; * rdi: file descriptor
; * rsi: buffer
; * rdx: num bytes
; OUTPUT:
; * rax: number of bytes read
read_all:
    push rbp
    mov rbp, rsp
    push r12 ; file descriptor
    push r13
    push r14
    push r15
    %define fd r12
    %define buffer r13
    %define left_to_read r14
    %define len r15
    mov fd, rdi
    mov buffer, rsi
    mov left_to_read, rdx
    mov len, rdx

    .loop:
        syscall_read(fd, buffer, left_to_read)
        sub left_to_read, rax
        add buffer, rax
        mov rdi, rax
        ; file end
        test rax, rax
        jz .done
        ; buffer full
        test left_to_read, left_to_read
        jz .done
        jmp .loop

    .done:
    sub len, left_to_read
    mov rax, len

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
