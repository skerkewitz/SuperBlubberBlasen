; Include all the header
.include "header.inc"
.include "snes.inc"

; Include all the static date
;.include "data.inc"

.include "src/game_inc/game_map_const.inc"

.define player_x_start        	1; 112      ; The height of the level in 8 pixel tiles
.define player_y_start			1; 64

.define k_player_jump_count     40       ; The jump height

; Declare global zero pages var
.RAMSECTION "ZeroPlage_PlayerVars" BANK 0 SLOT 0
	; Player sprite position in screen space
	player_screen_x:		db
	player_screen_y:		db
    player_on_ground:       db      ; zero if not not on ground
    player_injump_count:    db      ; if the player is in an up jump this is the reamining up count
	player_flip_mask:		db		; set bit 6 to flip x
.ENDS

.bank 0 slot 1
.section "GamePlayerCode"
 
;----------------------------------------------------------------------------------------------------------------------
; Init the player vars for each level
GamePlayer_BeforeStartLevel:
	;
	; Init player sprite vars
	lda		#player_x_start
	sta		player_screen_x
	lda		#player_y_start
	sta		player_screen_y	
    lda     #1
    stz     player_on_ground
    stz     player_injump_count
	rts 

;----------------------------------------------------------------------------------------------------------------------
; The top main game loop, does not much at the moment
GamePlayer_HandleInput:
@begin:
    lda     #0
    xba
    lda     #0
	_useIndex16_
;
;	lda		JOY1L
	lda		JOY1H					; load full 16bit joypad 1 state into X
	tax								; Check button R
	and 	#1						
	beq		@joy1_skip_dpad_r

	inc		player_screen_x
	stz		player_flip_mask

@joy1_skip_dpad_r:
	txa
	lsr		
	tax
	and		#1
	beq		@joy1_skip_dpad_l

	dec		player_screen_x
	lda		#%01000000
	sta		player_flip_mask


@joy1_skip_dpad_l:
	txa
	lsr		
	tax
	and		#1
	beq		@joy1_skip_dpad_d

	inc		player_screen_y

@joy1_skip_dpad_d:

    ; We can only jump if we are on the ground
    lda     player_on_ground
    beq     @joy1_skip_dpad_u

    ; Handle dpad up
	txa
	lsr		
	tax
	and		#1
	beq		@joy1_skip_dpad_u

    stz     player_on_ground
    lda     #k_player_jump_count
    sta     player_injump_count
	dec		player_screen_y

@joy1_skip_dpad_u:

    ;
    ; Check the jump count
    lda     player_injump_count                 
    beq     @ground_check                   ; if we are not in a jump do ground check

@handle_jump:
    dec     player_injump_count
    dec     player_screen_y
    stz     player_on_ground
    jmp     @end

    ;
    ; Load player screen position into x and y
@ground_check:
	lda		player_screen_x
	clc
	adc		#8
	tax
	lda		player_screen_y

;	sec                                     ; Y position is 16 screen pixel to low, but the map is
                                            ; also move by 16 pixel down - so the balance out
;	sbc     #16
	tay
    stz     player_on_ground
	game_map_content_at_screen_pos
	lda.w	tilemap, x	
	cmp		#16
	bne		@on_floor

@off_floor:
	inc		player_screen_y
	jmp		@end

@on_floor:
    lda     #1
    sta     player_on_ground

@end
    rts

.ends

