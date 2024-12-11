; INPUT:
; * rdi: file descriptor
; * rsi: buffer
; * rdx: num bytes
; OUTPUT:
; * rax: number of bytes read
fn read_all(fd: u64, _buffer: ptr, num_bytes: u64):
    vars
        reg buffer: ptr
        reg left_to_read: u64
    endvars
    mov %$left_to_read, %$num_bytes
    mov %$buffer, %$_buffer

    .loop:
        syscall_read(%$fd, %$buffer, %$left_to_read)
        sub %$left_to_read, rax
        add %$buffer, rax
        mov rdi, rax
        ; file end
        test rax, rax
        jz .done
        ; buffer full
        test %$left_to_read, %$left_to_read
        jz .done
        jmp .loop

    .done:
    sub %$num_bytes, %$left_to_read
    mov rax, %$num_bytes
endfn
