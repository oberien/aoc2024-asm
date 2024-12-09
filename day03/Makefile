.PHONY: all
all: day03

.PHONY: clean
clean:
	rm day03 day03.o

.PHONY: day03-sample day03-input
day03-sample: day03 sample.txt
	./day03 sample.txt
day03-input: day03 input.txt
	./day03 input.txt
day03: day03.o
	ld -o day03 day03.o
	strip -w -N '*.*' day03
day03.o: day03.nasm $(shell find ../stdlib/ -name '*.nasm')
	nasm -f elf64 -g -F dwarf -i ../stdlib/ -o day03.o day03.nasm
