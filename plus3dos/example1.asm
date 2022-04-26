BANKM:		equ 0x5B5C	; Copy of last byte sent to 0x7FFD
MEM_PORT_1:	equ 0x7FFD	; Memory-control port
DOS_VERSION:	equ 0x0103	; +3DOS routine to confirm DOS version
	
		org 0x8000		; 32,768d

	jp EXAMPLE_1

include "plus3dos_utils.asm"

	;; -------------------------------------------------------------
	;; Example of calling +3DOS to check version
	;; 
	;; On entry, system is assumed to be in +3BASIC memory
	;; configuration -- e.g., as when calling with USR()
	;; -------------------------------------------------------------
EXAMPLE_1:	
	;; Move stack into middle of address range, for +3DOS
	di
	ld (OLD_SP),sp		; Save Stack Pointer
	ld sp, 0xBFDE		; Just below pageable RAM
	ei

	;; Switch to +3DOS memory configuration
	call SWAP_MEM_CONFIG

	;; Retrieve version details
	call DOS_VERSION
	
	;; Restore BASIC memory configuration
	call SWAP_MEM_CONFIG

	;; Move version info into BC ready for return to BASIC
	ld b,d
	ld c,e
	
	;; Restore stack pointer
	di
	ld sp,(OLD_SP)
	ei
	
	;; Done
	ret

OLD_SP:	dw 0x0000		; Space to store previous SP

END_EXAMPLE_1:	
