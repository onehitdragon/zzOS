bits 16
org 0x7C00

;set up 4kb stack
mov AX, 0x7C0
add AX, 288
mov SS, AX
mov SP, 4096

;setup extra segment
add AX, 256
mov ES, AX

main:
jmp printGreetStr

loop:
jmp $

printGreetStr:
push readDisk
push greetStr
jmp printString

printCharacter:
mov AH, 0x0E
mov BH, 0x00
mov BL, 0x07
int 0x10
ret

printString:
pop SI

next_character:
mov AL, [SI]
cmp AL, 0
je exit_character
call printCharacter
inc SI
jmp next_character

exit_character:
ret

readDisk:
mov AH, 0x02
mov AL, 1
mov CH, 0
mov CL, 2
mov DH, 0
mov BX, 0x0
int 0x13
cmp AH, 0x0
je printReadDiskOkStr
jmp loop

printReadDiskOkStr:
push debugCC
push readDiskOkStr
jmp printString

debugCC:
push loop
mov AX, ES
shl AX, 4
push AX
jmp printString

;data
greetStr db "Hello zz OS", 0x0D, 0xA, 0
readDiskOkStr db "Reading sector 1.. OK", 0x0D, 0xA, 0

TIMES 510 - ($ - $$) db 0
DW 0xAA55
