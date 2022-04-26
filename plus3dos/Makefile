ASM=z80asm
AFLAGS=-L
example1: example1.asm Makefile plus3dos_utils.asm
	$(ASM) $(AFLAGS) -o example1.bin example1.asm

example2: example2.asm Makefile plus3dos_utils.asm
	$(ASM) $(AFLAGS) -o example2.bin example2.asm

clean:
	erase *.bin
