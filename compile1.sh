#!/bin/bash

# log
echo "Start Compile"

# log
echo "=====[compile main.c to main.o]====="
#command
gcc -c -o ./test/compiled/main.o ./test/main.c
# log
ls -l ./test/compiled/main.o

# log
echo "=====[compile tools.c to tools.o]====="
#command
gcc -c -o ./test/compiled/tools.o ./test/tools.c
# log
ls -l ./test/compiled/tools.o

# log
echo "=====[linker]====="
#command
#ld -m elf_i386 -o ./test/build/main ./test/compiled/main.o
gcc -o ./test/build/main \
./test/compiled/main.o \
./test/compiled/tools.o
# log
ls -l ./test/build/main

# log
echo "End Compile"

./test/build/main