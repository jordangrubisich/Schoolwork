.phony all:
all: pman inf args

pman: PMan.c
	gcc -Wall PMan.c -lreadline -o PMan -g -w
inf: inf.c
	gcc -Wall inf.c -lreadline -o inf -g
args: args.c
	gcc -Wall args.c -lreadline -o args -g

.PHONY clean:
clean:
	-rm -rf *.o *.exe
