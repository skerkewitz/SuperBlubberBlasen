; Include all the header
.include "header.inc"
.include "snes.inc"
.include "snes_Init.asm"

; Include all the static date
.include "data.inc"

; Declare global zero pages var
.RAMSECTION "ZeroPageVars" BANK 0 SLOT 0
	color_count:	db
.ENDS

.bank 0 slot 1
.section "MainCode" FORCE 
 
.macro _useIndex16_					; Turn on 16bit mode on X and Y, also let wla knwo using .index16
	.index 	16
	rep		#$10					; turn X flag in SR off
.endm

.macro _useIndex8_					; Turn on 8bit mode on X and Y, also let wla knwo using .index8
	.index	8
	sep		#$10					; turn X flag in SR on
.endm



Start:
	; Initialize the SNES.
	Snes_Init
 
	; Set the background color to green.
	sep		#$20        ; Set the A register to 8-bit.
	
	
	_sns_controller_io__enable_automatic_joypad_read
	
	
	lda     #%10000000  ; Force VBlank by turning off the screen.
	sta     $2100

set_palette_red:
	_snes_cg_address_i_ 0 

          ; gggrrrrr
	lda     #%00011111  ; Load the low byte of the green color.
	sta     CGDATA
     
  ;         0bbbbbgg
	lda     #%00000000  ; Load the high byte of the green color.
	sta     CGDATA

_start_blub:
	lda		#$FF
	pha
	lda		#$00
	lda     1,s
	dea
	sta     1,s
	lda		#$00
	pla		

	; Copy palette as palette two
	stz     $2116       ; set CGRAM addr to zero
	stz	    $2117

	_useIndex16_
	ldy		#size_of_tiles
	ldx		#0

loop_tile:
	lda.l	tiles, x
	sta		$2118
	inx
	dey	
	lda.l	tiles, x
	sta		$2119
	inx
	dey	

	bne 	loop_tile

	;
	; Load tiles patte into color palette 0
	_useIndex16_
	_snes_cg_address_0_												; set CGRAM addr to zero
	_snes_load_palette_into_vram_a8i16vb_ palette size_of_palette	; load via DMA channel 0
	_snes_load_palette_into_vram_a8i16vb_ spr_bubblun_pal size_of_bubblun_palette	; load via DMA channel 0


	_useIndex16_
	jsr		LoadTilemapDataIntoVram

	lda     #%00001111  ; End VBlank, setting brightness to 15 (100%).
	sta     $2100

	; Init is done, jump into main game loop.
	jmp		MainGameLoop
 

;----------------------------------------------------------------------------------------------------------------------
; The top main game loop, does not much at the moment
MainGameLoop:
_mainGameLoop_begin:
	lda		JOY1H
	lda		JOY1L

	jmp		_mainGameLoop_begin



;----------------------------------------------------------------------------------------------------------------------
; Needed to satisfy interrupt definition in "Header.inc".
VBlank:
	php
	pha

	inc     color_count

	stz     $2121       ; set CGRAM addr to zero

          ; gggrrrrr
	lda     color_count
	and 	#%00011111  ; Load the low byte of the green color.
	sta     $2122
     
  ;         0bbbbbgg
;	lda     #%00000000  ; Load the high byte of the green color.
	stz     $2122

	pla
	plp
	rti


;======================================================================================================================
; Load the tilemap map data into VRAM.
;----------------------------------------------------------------------------
; In: None
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: A, X, Y
; Requires: mem/A = 8 bit, X/Y = 16 bit
; Requires: VBlank active
;----------------------------------------------------------------------------
LoadTilemapDataIntoVram:

	;
	; Setup VRAM target
	lda  	#<2048
	sta		VMADDL
	lda  	#>2048
	sta		VMADDH
	
	;
	; Fill first to rows with empty tile
	ldy		#64						; first to rows of tiles are empty
	lda		#16						; index of the empty file

_load_tilemap_date_into_vram__header_loop:
	sta		VMDATAL
	stz		VMDATAH
	dey	
	bne 	_load_tilemap_date_into_vram__header_loop

	;
	; fill remaining rows with actual map data
	ldy		#size_of_tilemap		; setup counter
	ldx		#0

_load_tilemap_date_into_vram__mapdata_loop:
	lda.l	tilemap, x				; load tilemap data
	sta		VMDATAL
	stz		VMDATAH
	inx
	dey	
	bne 	_load_tilemap_date_into_vram__mapdata_loop

	rts

.ends

