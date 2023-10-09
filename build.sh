nasm -f bin -o main.bin main.asm

dd if=/dev/zero of=floppy.img bs=512 count=2880

dd if=main.bin of=floppy.img

echo -n "Vinh" > test.txt

dd if=test.txt of=floppy.img oflag=append conv=notrunc

rm test.txt
