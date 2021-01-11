; Include all the header
.include "header.inc"
.include "snes.inc"

; Include all the static date
.include "data.inc"

; Declare global zero pages var
.RAMSECTION "ZeroPageVars" BANK 0 SLOT 0
	color_count:	db			; blah

	;
	; Player sprite position in screen space
	player_x:		db
	player_y:		db
.ENDS

.bank 0 slot 1
.section "MainCode" FORCE 
 
.macro _useIndex16_					; Turn on 16bit mode on for X and Y, also let wla know using .index16
	.index 	16
	rep		#$10					; turn X flag in SR off
.endm

.macro _useIndex8_					; Turn on 8bit mode on for X and Y, also let wla know using .index8
	.index	8
	sep		#$10					; turn X flag in SR on
.endm

.macro _useAccu16_					; Turn on 16bit mode on for A, also let wla know using .accu16
	.index 	16
	rep		#$20					; turn M flag in SR off
.endm

.macro _useAccu8_					; Turn on 8bit mode on for A, also let wla know using .accu8
	.index	8
	sep		#$20					; turn M flag in SR on
.endm



Start:
	; Initialize the SNES.
	Snes_Init
 
	; Set the background color to green.
	sep		#$20        ; Set the A register to 8-bit.
	
	
	_sns_controller_io__enable_automatic_joypad_read
	
	
	lda     #%10000000  ; Force VBlank by turning off the screen.
	sta     $2100

@set_palette_red:
	_useIndex16_
	_snes_cg_address_i_ 0 

          ; gggrrrrr
	lda     #%00011111  ; Load the low byte of the green color.
	sta     CGDATA
     
  ;         0bbbbbgg
	lda     #%00000000  ; Load the high byte of the green color.
	sta     CGDATA

/*
_start_blub:
	lda		#$FF
	pha
	lda		#$00
	lda     1,s
	dea
	sta     1,s
	lda		#$00
	pla		
	*/

	;
	; Init player sprite vars
@init_player_sprite_vars:
	stz		player_x
	lda		#100
	sta		player_y	

	; 
	; Load tileset data into vram
	_useIndex16_
	stz     $2116       ; set VRAM Adress to zero
	stz	    $2117
	_snes_load_tiles_into_vram_a8i16vb_ tiles size_of_tiles
	_snes_load_tiles_into_vram_a8i16vb_ spr_bubblun_tiles size_of_bubblun_tiles

	;
	; Load color palettes into cgram
	_useIndex16_
	_snes_cg_address_0_												; set CGRAM addr to zero
	_snes_load_palette_into_vram_a8i16vb_ palette size_of_palette	; load via DMA channel 0
	_snes_cg_address_i_	144										; set CGRAM addr to zero
	;_snes_cg_address_0_												; set CGRAM addr to zero
	_snes_load_palette_into_vram_a8i16vb_ spr_bubblun_pal size_of_bubblun_palette	; load via DMA channel 0


	;
	; Load tilemap data into vram
	_useIndex16_
	jsr		LoadTilemapDataIntoVram

	lda     #%00001111  ; End VBlank, setting brightness to 15 (100%).
	sta     $2100

	; Init is done, jump into main game loop.
	jmp		MainGameLoop
 

;----------------------------------------------------------------------------------------------------------------------
; The top main game loop, does not much at the moment
MainGameLoop:
@begin:

;
;	lda		JOY1L
	lda		JOY1H					; load full 16bit joypad 1 state into X
.sym tralla	
	tax								; Check button R
	and 	#1						
	beq		@joy1_skip_dpad_r

	inc		player_x

@joy1_skip_dpad_r:
	txa
	lsr		
	tax
	and		#1
	beq		@joy1_skip_dpad_l

	dec		player_x


@joy1_skip_dpad_l:
	txa
	lsr		
	tax
	and		#1
	beq		@joy1_skip_dpad_d

	inc		player_y

@joy1_skip_dpad_d:
	txa
	lsr		
	tax
	and		#1
	beq		@joy1_skip_dpad_u

	dec		player_y

@joy1_skip_dpad_u:

	wai								; Wait for vblank
	jmp		@begin



;----------------------------------------------------------------------------------------------------------------------
; Needed to satisfy interrupt definition in "Header.inc".
VBlank:
	php
	pha


	;
	; Clear OAM
	; Setup VRAM target
	;stz		$2101					; reset obj
	stz		$2102					; reset target addr in OAM
	stz		$2103

	;
	; Fill first to rows with empty tile
	ldy		#128					; first to rows of tiles are empty

@clear_sprites_loop:
	stz		$2104					; clear one sprite
	stz		$2104
	stz		$2104
	stz		$2104
	dey	
	bne 	@clear_sprites_loop
	lda		#2						; make sprite 0 alway 16x16
	stz		$2104

	;
	; Setup Bubblun
	; Setup VRAM target
	stz		$2102					; reset target addr in OAM
	stz		$2103

	;lda		#100					; sprite x
	lda		player_x
	sta		$2104					;
	;lda 	#110					; sprite y
	lda		player_y
	sta		$2104

	lda		#18						; tile number
	sta		$2104
	
	lda		#%110010						; palette is wrong
	sta		$2104



/*
	inc     color_count

	stz     $2121       ; set CGRAM addr to zero

          ; gggrrrrr
	lda     color_count
	and 	#%00011111  ; Load the low byte of the green color.
	sta     $2122
     
  ;         0bbbbbgg
;	lda     #%00000000  ; Load the high byte of the green color.
	stz     $2122 */

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

@header_loop:
	sta		VMDATAL
	stz		VMDATAH
	dey	
	bne 	@header_loop

	;
	; fill remaining rows with actual map data
	ldy		#size_of_tilemap		; setup counter
	ldx		#0

@mapdata_loop:
	lda.l	tilemap, x				; load tilemap data
	sta		VMDATAL
	stz		VMDATAH
	inx
	dey	
	bne 	@mapdata_loop

	rts

.ends

