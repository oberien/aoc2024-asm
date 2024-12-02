.PHONY: all
all: day01

.PHONY: clean
clean:
	rm day01/day01 day01/day01.o
	rm stdlib.o

stdlib.o: stdlib.nasm $(wildcard stdlib/*)
	nasm -f elf64 -o stdlib.o stdlib.nasm

.PHONY: day01 day01-sample
day01: day01/day01 day01/input.txt
	./day01/day01 day01/input.txt
day01-sample: day01/day01 day01/sample.txt
	./day01/day01 day01/sample.txt
day01/day01.o: day01/day01.nasm stdlib.o
	nasm -f elf64 -o day01/day01.o day01/day01.nasm
day01/day01: day01/day01.o
	ld -o day01/day01 day01/day01.o stdlib.o


