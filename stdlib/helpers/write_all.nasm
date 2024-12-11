; INPUT:
; * rdi: file descriptor
; * rsi: buffer-ptr
; * rdx: len
fn write_all(fd: u64, buffer: ptr, len: u64):
    .loop:
        syscall_write(%$fd, %$buffer, %$len)
        sub %$len, rax
        add %$buffer, rax
        cmp %$len, 0
        jnz .loop
endfn
