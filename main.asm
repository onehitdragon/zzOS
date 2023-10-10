[bits 16]
[org 0x7C00]

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
push switchProtectedMode
mov AX, ES
shl AX, 4
push AX
jmp printString

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

switchProtectedMode:
cli
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:start_protected_mode

[bits 32]
start_protected_mode:
mov AL, 'A'
mov AH, 0x0f
mov [0xb8000], ax
jmp $

;data
greetStr db "Hello zz OS", 0x0D, 0xA, 0
readDiskOkStr db "Reading sector 1.. OK", 0x0D, 0xA, 0
switchProtectedModeStr db 0x0D, 0xA, "Switch to projected mode(segment)..", 0x0D, 0xA, 0

;gdt
gdt_start:

gdt_null:
dd 0x0
dd 0x0
gdt_code:
dw 0xFFFF
dw 0x0
db 0x0
db 0b10011010
db 0b11001111
db 0x0
gdt_data:
dw 0xFFFF
dw 0x0
db 0x0
db 0b10010010
db 0b11001111
db 0x0

gdt_end:

gdt_descriptor:
dw gdt_end - gdt_start
dw gdt_start

TIMES 510 - ($ - $$) db 0
DW 0xAA55
