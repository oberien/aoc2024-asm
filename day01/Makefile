.PHONY: all run
all: day01
run: day01-input

.PHONY: clean
clean:
	rm day01 day01.o
	rm stdlib-day01.o

stdlib-day01.o: stdlib-day01.nasm $(wildcard stdlib-day01/*)
	nasm -f elf64 -o stdlib-day01.o stdlib-day01.nasm
.PHONY: day01 day01-sample
day01-input: day01 input.txt
	./day01 input.txt
day01-sample: day01 sample.txt
	./day01 sample.txt
day01.o: day01.nasm stdlib-day01.o
	nasm -f elf64 -o day01.o day01.nasm
day01: day01.o
	ld -o day01 day01.o stdlib-day01.o


