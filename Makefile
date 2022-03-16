all: ParaPF.out

ParaPF.out: main.o ParaPF.o
	gcc -no-pie Objects/main.o Objects/ParaPF.o -o Objects/ParaPF.out

main.o: main.c
	gcc -c -g main.c -o Objects/main.o

ParaPF.o: ParaPF.s
	nasm -f elf64 -g ParaPF.s -o Objects/ParaPF.o

run:
	Objects/ParaPF.out

clean:
	rm Objects/main.o Objects/ParaPF.o Objects/ParaPF.out
