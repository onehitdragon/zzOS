ORG 0x7C00
BITS 16

JMP SHORT main ;This is 2 bytes
NOP ;Needed to make 3 bytes at the beginning total

;FAT12 header
DB "MSDOS5.0"   ;OEM Identifier (8 bytes)
byte_per_sector: DW 512
                ;Bytes per sector (2 bytes)
sector_per_cluster: DB 1
                ;Sectors per cluster (1 bytes)
number_of_reserved_sector: DW 1
                ;Reserved sectors (2 bytes) (1 for boot sector)
nunber_of_fat: DB 2
                ;Number of FATs (1 bytes) (2 fat)
number_of_root_dir_entries: DW 224
                ;Max root directory entries (2 bytes) (224 entries * 32bytes ~ 7168 bytes)
DW 2880         ;Total sectors (2 bytes) (2880 * 512 ~ 1474560 bytes ~ 1.44mb)
DB 0xF0         ;Media descriptor (1 bytes) (3.5" Floppy disk, 2-sided, 80 tracks, 18 sectors per track 1.44MB)
sector_per_fat: DW 9
                ;Sectors per FAT (2 bytes) (fat size ~ (2880cluster * 12(~1.5bytes)) / 8 ~ 4320 bytes ~ 9 sector)
sector_per_track: DW 18
                ;Sectors per track (2 bytes) (Floppy disk)
number_of_head: DW 2
                ;Number of heads (2 bytes) (Floppy disk)
DD 0            ;Hidden sectors (4 bytes)
DD 0            ;Total sectors (Large) (4 bytes) (not used for FAT12)

                ;FAT32 Flags ( bytes) (not used for FAT12)
                ;FAT Version ( bytes) (should be 0 for FAT12)
                ;Root Cluster ( bytes) (not used in FAT12)
                ;FS Info Sector ( bytes) (not used in FAT12)
                ;Backup Boot Sector ( bytes) (usually 6)
                ;Reserved (12 bytes) (12 bytes, typically all zeros)
                ;Boot signature ( bytes) (2 bytes)

;main
main:
    MOV ax, 0
    MOV ds, ax
    MOV es, ax
    MOV ss, ax
    MOV sp, 0x7C00

    MOV si, hello_msg ;print hello msg
    CALL print

    ;lba root directory ~ number_of_reserved_sector + (sector_per_fat * nunber_of_fat) ~ 19
    MOV ax, [sector_per_fat]
    XOR bh, bh
    MOV bl, [nunber_of_fat]
    MUL bx
    ADD ax, [number_of_reserved_sector]
    PUSH ax
    ;total sector of root directory ~ (number_of_root_dir_entries * 32) / byte_per_sector ~ 14
    MOV ax, [number_of_root_dir_entries]
    SHL ax, 5
    XOR dx, dx
    DIV WORD [byte_per_sector]
    CMP dx, 0
    JE after_get_root_dir
    INC ax
after_get_root_dir:
    ;read (total sector of root directory) at lba root directory
    MOV bx, buffer
    MOV cl, al
    POP ax
    CALL start_read
    MOV di, bx
    MOV bx, 0
search_kernel:
    MOV cx, 11
    MOV si, name_kernel_bin
    PUSH di
    REPE CMPSB
    POP di
    JE search_done
    INC bx
    CMP bx, [number_of_root_dir_entries]
    JE search_fail
    ADD di, 32
    JMP search_kernel
search_fail:
    MOV si, search_kernel_fail_msg
    CALL print
    HLT
    JMP hlt
search_done:
    MOV ax, [di + 26]
    MOV [kernel_cluster], ax
    ;read fat
    MOV bx, buffer
    MOV ax, [number_of_reserved_sector]
    MOV cl, [sector_per_fat]
    CALL start_read
    MOV di, bx
    PUSH 0 ;counter
load_kernel:
    ;bytes per cluster ~ sector_per_cluster * byte_per_sector
    MOV ax, [byte_per_sector]
    MOV bl, [sector_per_cluster]
    XOR bh, bh
    MUL bx
    POP bx ;counter
    MUL bx
    INC bx
    PUSH bx
    ADD ax, kernel_load_offset
    ;es:bx
    MOV bx, ax
    MOV ax, kernel_load_segment
    MOV es, ax

    MOV ax, [kernel_cluster]
    ADD ax, 31
    MOV cl, [sector_per_cluster]
    CALL start_read

    ;find fat entry
    MOV ax, [kernel_cluster]
    MOV bx, 3
    MUL bx
    MOV bx, 2
    XOR dx, dx
    DIV bx ;ax ~ (kernel_cluster * 3)/2
    PUSH di
    ADD di, ax
    MOV ax, [di] ;ax ~ [di + ax]
    POP di
    MOV bx, [kernel_cluster]
    TEST bx, 1
    JZ even
    JMP odd
even:
    AND ax, 0x0FFF
    JMP after_find_fat_entry
odd:
    SHR ax, 4
after_find_fat_entry:
    CMP ax, 0xFF8
    JAE load_kernel_done
    MOV [kernel_cluster], ax
    JMP load_kernel
load_kernel_done:
    MOV si, hello_msg
    CALL print
    MOV ax, kernel_load_segment
    MOV ds, ax
    MOV es, ax
    MOV ss, ax
    MOV sp, 0x0
    JMP kernel_load_segment:kernel_load_offset
hlt:
    JMP hlt

;print
print:
    ;save register
    PUSH ax
    PUSH bx
    JMP print_loop
print_loop:
    LODSB
    CMP al, 0
    JE end_print
    MOV ah, 0x0E ;Bios interrupt
    MOV bh, 0
    INT 0x10 ;Bios interrupt
    JMP print_loop
end_print:
    ;restore register
    POP bx
    POP ax
    RET

;read_disk
;input: ax -> lba sector number
;       cl -> number of sector to read
start_read:
    PUSH ax
    PUSH cx
    PUSH dx
    PUSH di
    MOV di, 4
    JMP read
read:
    PUSH cx
    CALL start_lba_to_chs
    POP ax ;number of sector to read
    MOV dl, 0 ;specify driver number
    MOV ah, 0x02 ;Bios interrupt
    STC
    INT 0x13 ;Bios interrupt
    JNC done_read
    DEC di
    CMP di, 0
    JE fail_read
    CALL start_reset_disk
    JC fail_read
    JMP read
;lba_to_chs
;input: ax (sector index in LBA)
;output: ch (cylinder number in CHS)
;        cl (sector number in CHS)
;        dh (head number in CHS)
start_lba_to_chs:
    PUSH ax
    JMP lba_to_chs
lba_to_chs:
    ;LBA % sector_per_track + 1 = sector number
    XOR dx,dx
    DIV WORD [sector_per_track]
    INC dx
    MOV cl, dl
    ;LBA / sector_per_track / number_of_head = cylinder number
    ;LBA / sector_per_track % number_of_head = head number
    XOR dx,dx
    DIV WORD [number_of_head]
    MOV ch, al
    MOV dh, dl
    JMP end_lba_to_chs
end_lba_to_chs:
    POP ax
    RET
done_read:
    MOV si, done_read_msg
    CALL print
    JMP end_read
fail_read:
    MOV si, fail_read_msg
    CALL print
    HLT
    JMP hlt
;output: cf = 1(fail), cf = 0(success)
start_reset_disk:
    PUSH ax
    JMP reset_disk
reset_disk:
    MOV si, try_read_msg
    CALL print
    MOV ah, 0x0 ;Bios interrupt
    STC
    INT 0x13 ;Bios interrupt
    JMP end_reset_disk
end_reset_disk:
    POP ax
    RET
end_read:
    POP di
    POP dx
    POP cx
    POP ax
    RET

;data
hello_msg: DB "Welcome this is bootloader...", 0x0D, 0x0A, 0
done_read_msg: DB "Done read...", 0x0D, 0x0A, 0
fail_read_msg: DB "Fail read!!!", 0x0D, 0x0A, 0
try_read_msg: DB "Try read...", 0x0D, 0x0A, 0
search_kernel_fail_msg: DB "Dont find kernel!!!", 0x0D, 0x0A, 0

name_kernel_bin: DB "KERNEL  BIN" ;11 bytes
kernel_cluster: DW 0;2 bytes

kernel_load_segment EQU 0x2000
kernel_load_offset EQU 0

TIMES 510-($-$$) DB 0
DW 0xAA55

;buffer address (0x7C00 + 512)
buffer: