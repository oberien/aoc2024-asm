.PHONY: all
all: test

.PHONY: run
run: all
	./test

.PHONY: clean
	rm test test.o

test: test.o
	ld -o test test.o
	strip -w -N '*.*' test

test.o: test.nasm
	nasm -f elf64 -g -F dwarf -i ../stdlib/ -o test.o test.nasm