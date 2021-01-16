; Include all the header
.include "header.inc"
.include "snes.inc"

; Include all the static date
;.include "data.inc"

.include "src/game_inc/game_map_const.inc"

.define kPLAYER_X_START        		1; 112      ; The height of the level in 8 pixel tiles
.define kPLAYER_Y_START				1; 64

.define kPLAYER_JUMP_COUNT			40       	; The jump height

.define kSPRITE_FLIP_X_BITMASK		%01000000	; Sprite is fliped on X bit mask	

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
	lda		#kPLAYER_X_START
	sta		player_screen_x
	lda		#kPLAYER_Y_START
	sta		player_screen_y	
    lda     #1
    stz     player_on_ground
    stz     player_injump_count
	rts 

;----------------------------------------------------------------------------------------------------------------------
; The top main game loop, does not much at the moment
GamePlayer_HandleInput:
@begin:
	
	; Clear all 16 bits of A
    lda     #0
    xba
    lda     #0
	_useIndex16_
;
;	lda		JOY1L
	lda		JOY1H							; load full 16bit joypad 1 state into X
	tax										; Store it to X so we can restore it quickly
	bit		#kDPAD_RIGHT					; Check button R
	beq		@joy1_skip_dpad_r

	inc		player_screen_x
	stz		player_flip_mask

@clamp_sprite_x_max
	lda		#kMAX_X_SCREEN_POS				; make sure we do not run out of screen on the left
	cmp		player_screen_x
	bcs		@skip_set_max_x					; clear if A >= M
	sta		player_screen_x					; adjust x position	to 16

@skip_set_max_x:
	txa										; restore DPAD data in A

@joy1_skip_dpad_r:
	bit		#kDPAD_LEFT						; is left dpad pressed
	beq		@joy1_skip_dpad_l

@move_sprite_left
	dec		player_screen_x					; yes, move sprite left
	
@clamp_sprite_x_min
	lda		#kMIN_X_SCREEN_POS				; make sure we do not run out of screen on the left
	cmp		player_screen_x
	bcc		@skip_set_min_x					; clear if A >= M
	sta		player_screen_x					; adjust x position	to 16

@skip_set_min_x:
	lda		#kSPRITE_FLIP_X_BITMASK
	sta		player_flip_mask

@joy1_skip_dpad_l:
	txa										; Restore DPAD value in A
	bit		#kDPAD_DOWN
	beq		@joy1_skip_dpad_d

	inc		player_screen_y

@joy1_skip_dpad_d:

    ; We can only jump if we are on the ground
    lda     player_on_ground
    beq     @joy1_skip_dpad_u

    ; Handle dpad up
	txa
	bit		#kDPAD_UP
	beq		@joy1_skip_dpad_u

    stz     player_on_ground
    lda     #kPLAYER_JUMP_COUNT
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

