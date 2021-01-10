; Include all the header
.include "header.inc"
.include "snes.inc"
.include "snes_Init.asm"

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
     
	stz     CGADD       ; set CGRAM addr to zero

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

	_useIndex8_

;.index 8
	; Upload tileset
	stz     CGADD       ; set CGRAM addr to zero
	ldy		#size_of_palette
	ldx		#0

loop_palette:
	lda.l	palette, x
	sta		CGDATA
	inx
	dey	
	bne 	loop_palette

_load_map_tiledate_into_vram:

	_useIndex16_

	lda  	#<2048					; setup VRAM target
	sta		VMADDL
	lda  	#>2048
	sta		VMADDH

	ldy		#size_of_tilemap		; setup counter
	ldx		#0

_load_map_tiledate_into_vram_loop:
	lda.l	tilemap, x				; load tilemap data
	sta		VMDATAL
	stz		VMDATAH
	inx
	dey	
	bne 	_load_map_tiledate_into_vram_loop

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




;============================================================================
;LoadPalette - Macro that loads palette information into CGRAM
;----------------------------------------------------------------------------
; In: SRC_ADDR -- 24 bit address of source data,
;     START -- Color # to start on,
;     SIZE -- # of COLORS to copy
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: A,X
; Requires: mem/A = 8 bit, X/Y = 16 bit
;----------------------------------------------------------------------------
.MACRO LoadPalette
    lda #\2
    sta $2121       ; Start at START color
    lda #:\1        ; Using : before the parameter gets its bank.
    ldx #\1         ; Not using : gets the offset address.
    ldy #(\3 * 2)   ; 2 bytes for every color
    jsr DMAPalette
.ENDM


;============================================================================
; DMAPalette -- Load entire palette using DMA
;----------------------------------------------------------------------------
; In: A:X  -- points to the data
;      Y   -- Size of data
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: none
;----------------------------------------------------------------------------
DMAPalette:
    phb
    php         ; Preserve Registers

    stx $4302   ; Store data offset into DMA source offset
    sta $4304   ; Store data bank into DMA source bank
    sty $4305   ; Store size of data block

    stz $4300   ; Set DMA Mode (byte, normal increment)
    lda #$22    ; Set destination register ($2122 - CGRAM Write)
    sta $4301
    lda #$01    ; Initiate DMA transfer
    sta $420B

    plp
    plb
    rts         ; return from subroutine

.ends

; Include all the static date
.include "data.inc"
