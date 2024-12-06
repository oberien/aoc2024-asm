%macro min 2
    cmp %2, %1
    cmovb %1, %2
%endmacro

%macro imin 2
    cmp %2, %1
    cmovl %1, %2
%endmacro

%macro max 2
    cmp %2, %1
    cmova %1, %2
%endmacro

%macro imax 2
    cmp %2, %1
    cmovg %1, %2
%endmacro
