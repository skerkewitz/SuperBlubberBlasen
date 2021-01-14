; Include all the header
.include "header.inc"
.include "snes.inc"

; Include all the static date
;.include "data.inc"

.include "src/game_inc/game_map_const.inc"

.define player_x_start        	112      ; The height of the level in 8 pixel tiles
.define player_y_start			64

; Declare global zero pages var
.RAMSECTION "ZeroPlage_PlayerVars" BANK 0 SLOT 0
	; Player sprite position in screen space
	player_x:		db
	player_y:		db
.ENDS

.bank 0 slot 1
.section "GamePlayerCode"
 
;----------------------------------------------------------------------------------------------------------------------
; Init the player vars for each level
GamePlayer_BeforeStartLevel:
	;
	; Init player sprite vars
	lda		#player_x_start
	sta		player_x
	lda		#player_y_start
	sta		player_y	
	rts 

;----------------------------------------------------------------------------------------------------------------------
; The top main game loop, does not much at the moment
GamePlayer_HandleInput:
@begin:
	_useIndex16_
;
;	lda		JOY1L
	lda		JOY1H					; load full 16bit joypad 1 state into X
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


	lda		player_x
	clc
	adc		#16
	tax
	lda		player_y
	clc
;	adc     #16
	tay
	game_map_content_at_screen_pos
	lda.w	tilemap, x	
	cmp		#16
	bne		@on_floor
	inc		player_y

@on_floor:
    rts

.ends

