BANKM:		equ 0x5B5C	; Copy of last byte sent to 0x7FFD
MEM_PORT_1:	equ 0x7FFD	; Memory-control port
DOS_OPEN:	equ 0x0106	; +3DOS file-open routine
DOS_CLOSE:	equ 0x0109	; +3DOS close-file routine
DOS_READ:	equ 0x0112	; +3DOS file-read routine
	
	org 0x8000

	jp EXAMPLE_4

include "plus3dos_utils.asm"
	
	;; -------------------------------------------------------------
	;; Example of loading a screen into memory.
	;; 
	;; On entry, system is assumed to be in +3BASIC memory
	;; configuration -- e.g., as when calling with USR()
	;; -------------------------------------------------------------
EXAMPLE_4:	
	;; Move stack into middle of address range, for +3DOS
	di
	ld (OLD_SP),sp		; Save Stack Pointer
	ld sp, 0xbfde		; Just below pageable RAM
	ei

	;; Switch to +3DOS memory configuration
	call SWAP_MEM_CONFIG

	;; Open file
	ld bc, 0x0001		; File #00 / exclusive-read
	ld de, 0x0001		; Open file and read header,
	 			; error if file does not exist
	ld hl, FILENAME		; Points to filename
	
	call DOS_OPEN		; Call +3DOS

	jr nc, EXIT_1		; Skip forward if error

	;; Read data into screen memory
	ld b, 0x00		; File #00
	ld c, 0x07		; Put RAM0 at top of memory
	ld de, 0x1B00		; Length of screen buffer
	ld hl, 0xC000		; Address to read to

	call DOS_READ

	jr nc, EXIT_1		; Skip forward if error

	ld b, 0x00		; File #00

	call DOS_CLOSE

	jr nc, EXIT_1		; Skip forward if error

	;; Display alternative screen
	ld a, (BANKM)		; Retrieve current mem config
	xor %00001000		; Switch screen
	ld (BANKM), a		; Save it

	ld bc, MEM_PORT_1	; Make change
	di
	out (c), a
	ei

	;; Pause to admire the screen
	ld bc, 500 		; Will be roughly 10 seconds
LOOP:	dec bc
	halt 
	ld a,b
	or c
	jr nz, LOOP

	;; Restore primary screen
	ld a, (BANKM)		; Retrieve current mem config
	xor %00001000		; Switch screen
	ld (BANKM), a		; Save it

	ld bc, MEM_PORT_1	; Make change
	di
	out (c), a
	ei

	scf

	ld bc, 0x0000		; Indicates success
	
EXIT_1:
	;; Save flags
	push af
	push bc
	
	;; Restore BASIC memory configuration
	call SWAP_MEM_CONFIG

	;; Restore flags
	pop bc
	pop af
	
	;; Check for error; skip forward if not
	jr c, EXIT_2

	;; Error handling
	ld c, a			; Move error code into BC
	ld b, 0xFF		; Set B to indicate error
	
EXIT_2:	;; Restore stack pointer
	di
	ld sp,(OLD_SP)
	ei
	
	;; Done
	ret

	;; Local storage for stack pointer and filename
OLD_SP:	dw 0x0000
	
FILENAME:
	db "jetpac.scr", 0xFF	; Loading screen

END_EXAMPLE_4:	
