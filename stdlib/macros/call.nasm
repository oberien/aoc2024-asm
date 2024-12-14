%macro syscall_1 2
    mov rdi, %2
    call %1
%endmacro
%macro syscall_2 3
    mov rdi, %2
    mov rsi, %3
    call %1
%endmacro
%macro syscall_3 4
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    call %1
%endmacro
%macro syscall_4 5
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    call %1
%endmacro
%macro syscall_5 6
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8, %6
    call %1
%endmacro
%macro syscall_6 7
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8, %6
    mov r9, %7
    call %1
%endmacro

%macro call_0 1
    call %1
%endmacro
%macro call_1 2
    mov rdi, %2
    call %1
%endmacro
%macro call_2 3
    mov rdi, %2
    mov rsi, %3
    call %1
%endmacro
%macro call_3 4
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    call %1
%endmacro
%macro call_4 5
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov rcx, %5
    call %1
%endmacro
%macro call_5 6
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov rcx, %5
    mov r8, %6
    call %1
%endmacro
%macro call_6 7
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov rcx, %5
    mov r8, %6
    mov r9, %7
    call %1
%endmacro
