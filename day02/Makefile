.PHONY: all
all: day02

.PHONY: clean
clean:
	rm day02 day02.o

.PHONY: day02-sample day02-input
day02-sample: day02 sample.txt
	./day02 sample.txt
day02-input: day02 input.txt
	./day02 input.txt
day02: day02.o
	ld -o day02 day02.o
	strip -w -N '*.*' day02
day02.o: day02.nasm $(shell find ../stdlib/ -name '*.nasm')
	nasm -f elf64 -g -F dwarf -i ../stdlib/ -o day02.o day02.nasm
