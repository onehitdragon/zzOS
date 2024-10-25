BITS 16

SECTION _ENTRY class=CODE
extern _cstart_

global entry
entry:
    CLI
    MOV ax, dx
    MOV ss, dx
    MOV sp, 0
    MOV bp, 0
    STI

    CALL _cstart_

    CLI
    HLT