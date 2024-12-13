; INPUT:
; * rdi: (out) this-pointer
; * rsi: cstring filename
fn File__open(this: out File = reg, filename: cstring = rsi):
    syscall_open(%$filename, O_RDONLY, 0)
    mov %$this.rtti, File_Rtti
    mov %$this.fd, rax
endfn

; INPUT:
; * rdi: this-ptr
; * rsi: offset
; * rdx: whence (SEEK_SET, SEEK_CUR, SEEK_END)
; OUTPUT:
; * rax: new position
fn File__seek(this: File = rdi, offset: u64 = rsi, whence: u64 = rdx):
    syscall_lseek(%$this.fd, %$offset, %$whence)
endfn

; INPUT:
; * rdi: this-ptr
; OUTPUT:
; * rax: total length of file
; * rdi: left to read
fn File__len(this: File = reg):
    vars
        reg current: u64
        reg len: u64
    endvars

    ; get current position
    File__seek(%$this, 0, SEEK_CUR)
    mov %$current, rax

    ; get maximum position = length
    File__seek(%$this, 0, SEEK_END)
    mov %$len, rax

    ; seek back to previous position
    File__seek(%$this, %$current, SEEK_SET)

    mov rax, %$len
    mov rdi, %$len
    sub rdi, %$current
endfn

; INPUT:
; * rdi: this-ptr
; * rsi: (out) String
fn File__read_to_string(this: File = reg, string: out String = reg):
    vars
        reg to_read: u64
    endvars

    ; get number of bytes left to read
    File__len(%$this)
    mov %$to_read, rdi

    ; create string
    String__with_capacity(%$string, %$to_read)

    ; read all
    read_all(%$this.fd, %$string.ptr, %$to_read)
    assert_eq rax, %$to_read

    mov %$string.len, %$to_read
endfn

fn File__print(this: File = reg):
    rodata_cstring .s, `File with fd=`
    cstring__print(.s)
    u64__print(%$this.fd)
endfn

fn File__println(this: File = rdi):
    File__print(%$this)
    print_newline()
endfn

fn File__cmp(this: File = rdi, other: File = rsi):
    panic `File is not comparable`
endfn

fn File__clone_into(this: File = rdi, other: out File = rsi):
    mov %$other.rtti, File_Rtti
    mov rdx, %$this.fd
    mov %$other.fd, rdx
endfn

fn File__destroy(this: File = rdi)
    syscall_close(%$this.fd)
endfn
