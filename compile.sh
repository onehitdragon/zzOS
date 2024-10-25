#!/bin/bash

# log
echo "Start Compile"

# log
echo "=====[compile ./src/bootloader/index.s]====="
# command
nasm -f bin -o ./compiled/bootloader/index.bin ./src/bootloader/index.s
# log
ls -l ./compiled/bootloader/index.bin

# log
echo "=====[create floppy disk main.img]====="
# command
dd if=/dev/zero of=./build/main.img bs=512 count=2880
# log
ls -l ./build/main.img

# log
echo "=====[format floppy disk main.img to fat12]====="
# command
mkfs.fat -F 12 -n "FLOS" ./build/main.img
# log
ls -l ./build/main.img

# log
echo "=====[replace boot sector of floppy by ./compiled/bootloader/index.bin]====="
# command
dd if=./compiled/bootloader/index.bin of=./build/main.img conv=notrunc
# log
ls -l ./build/main.img




WCC16=/usr/bin/watcom/binl/wcc
WCCFLAGS="-s -ms -wx -zl -zq"
WLINK16=/usr/bin/watcom/binl/wlink

# log
echo "=====[compile kernel.s]====="
# command
nasm -f obj -o ./compiled/kernel/asm/kernel.o ./src/kernel/kernel.s
# log
ls -l ./compiled/kernel/asm/kernel.o

# log
echo "=====[compile print.s]====="
# command
nasm -f obj -o ./compiled/kernel/asm/print.o ./src/kernel/print.s
# log
ls -l ./compiled/kernel/asm/print.o

# log
echo "=====[compile kernel.c]====="
# command
$WCC16 $WCCFLAGS -fo=./compiled/kernel/c/kernel.o ./src/kernel/kernel.c
# log
ls -l ./compiled/kernel/c/kernel.o

# log
echo "=====[compile stdio.c]====="
# command
$WCC16 $WCCFLAGS -fo=./compiled/kernel/c/stdio.o ./src/kernel/stdio.c
# log
ls -l ./compiled/kernel/c/stdio.o

# log
echo "=====[linker]====="
# command
$WLINK16 NAME ./compiled/kernel/kernel.bin FILE \
./compiled/kernel/asm/print.o, \
./compiled/kernel/c/stdio.o, \
./compiled/kernel/c/kernel.o, \
./compiled/kernel/asm/kernel.o \
@./src/kernel/linker.lnk
# log
ls -l ./compiled/kernel/kernel.bin





# log
echo "=====[copy ./compiled/kernel/kernel.bin to floppy]====="
# command
# because fat12 auto convert filename to uppercase
mcopy -i ./build/main.img ./compiled/kernel/kernel.bin "::KERNEL.BIN"
# log
ls -l ./build/main.img
mdir -i ./build/main.img

# log
echo "End Compile"

# ghex ./build/main.img
# mdir -i ./build/main.img
# file ./build/main.img
# qemu-system-i386 -fda ./build/main.img