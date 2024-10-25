BITS 16

SECTION _TEXT class=CODE
global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
    PUSH bp
    MOV bp, sp
    PUSH ax
    PUSH bx

    MOV al, [bp+4];Bios interrupt
    MOV bh, [bp+6]
    MOV ah, 0x0E 
    INT 0x10 ;Bios interrupt

    POP bx
    POP ax
    POP bp
    RET