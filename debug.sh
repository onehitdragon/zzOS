#!/bin/bash

# gdb -ex 'target remote localhost:1234' \
#     -ex 'set architecture i8086' \
#     -ex 'layout asm' \
#     -ex 'fs cmd' \
#     -ex 'break *0x7c00' \
#     -ex 'continue'

gdb -ex 'target remote localhost:1234' \
    -ex 'layout asm' \
    -ex 'fs cmd' \
    -ex 'break *0x7c00' \
    -ex 'continue'