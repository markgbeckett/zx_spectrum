	;; -------------------------------------------------------------
	;; Routine to switch between BASIC (ROM3 and RAM0) and +3DOS 
	;; (ROM2 and RAM7) memory configurations (both ways). You should
	;; ensure machine stack is between 0x4000 and 0xC000 before
	;; calling.
	;; -------------------------------------------------------------
SWAP_MEM_CONFIG:
	ld a,(BANKM)		; Retrieve current ROM/ RAM configuration
	xor %00010111		; Swap ROM2 for ROM 3, and RAM0 for RAM7,
				; or vice versa
	
	ld (BANKM), a		; Remember new value
	
	ld bc, MEM_PORT_1	; Port for horizontal ROM switching
				; and RAM paging

	di			; Must disable interupts before paging
	
	out (c),a		; Make change

	ei			; Safe to reenable interupts

	ret
