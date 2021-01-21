; Include all the header
.include "header.inc"
.include "snes.inc"

; Include all the static date
;.include "data.inc"

.include "src/game_inc/game_map_const.inc"

.define kPLAYER_X_START        		64      ; The height of the level in 8 pixel tiles
.define kPLAYER_Y_START				64

.define kPLAYER_JUMP_COUNT			40       	; The jump height

.define kSPRITE_FLIP_X_BITMASK		%01000000	; Sprite is fliped on X bit mask	

.struct entity
	screen_x		db				; screen position in x
	screen_y		db				; screen position in y
    on_ground 	    db     			; zero if not not on ground
    in_jump_count 	db      		; if in an up jump this is the reamining up count
	flip_mask		db				; set bit 6 to flip x
.endst


; Declare global zero pages var
.RAMSECTION "ZeroPlage_PlayerVars" BANK 0 SLOT 0

	player INSTANCEOF entity			;  [optional, the number of structures]
	enemy  INSTANCEOF entity

.ENDS

.bank 0 slot 1
.section "GamePlayerCode"
 
;----------------------------------------------------------------------------------------------------------------------
; Init the player vars for each level
GamePlayer_BeforeStartLevel:
	;
	; Init player sprite vars
	lda		#kPLAYER_X_START
	sta		player.screen_x
	lda		#kPLAYER_Y_START
	sta		player.screen_y	
    lda     #1
    stz     player.on_ground
    stz     player.in_jump_count

	; Init enemy sprite vars
	lda.w	enemymap + 4 + 3
	clc										; times 8
	rol
	rol
	rol
	and		#%11111100
	sta		enemy.screen_x

	lda.w	enemymap + 4 + 4 + 3
	clc										; times 8
	rol
	rol
	rol
	and		#%11111100
	sta		enemy.screen_y	
    lda     #1
    stz     enemy.on_ground
    stz     enemy.in_jump_count

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

	inc		player.screen_x
	stz		player.flip_mask

@clamp_sprite_x_max
	lda		#kMAX_X_SCREEN_POS				; make sure we do not run out of screen on the left
	cmp		player.screen_x
	bcs		@skip_set_max_x					; clear if A >= M
	sta		player.screen_x					; adjust x position	to 16

@skip_set_max_x:
	txa										; restore DPAD data in A

@joy1_skip_dpad_r:
	bit		#kDPAD_LEFT						; is left dpad pressed
	beq		@joy1_skip_dpad_l

@move_sprite_left
	dec		player.screen_x					; yes, move sprite left
	
@clamp_sprite_x_min
	lda		#kMIN_X_SCREEN_POS				; make sure we do not run out of screen on the left
	cmp		player.screen_x
	bcc		@skip_set_min_x					; clear if A >= M
	sta		player.screen_x					; adjust x position	to 16

@skip_set_min_x:
	lda		#kSPRITE_FLIP_X_BITMASK
	sta		player.flip_mask

@joy1_skip_dpad_l:
	txa										; Restore DPAD value in A
	bit		#kDPAD_DOWN
	beq		@joy1_skip_dpad_d

	inc		player.screen_y

@joy1_skip_dpad_d:

    ; We can only jump if we are on the ground
    lda     player.on_ground
    beq     @joy1_skip_dpad_u

    ; Handle dpad up
	txa
	bit		#kDPAD_UP
	beq		@joy1_skip_dpad_u

    stz     player.on_ground
    lda     #kPLAYER_JUMP_COUNT
    sta     player.in_jump_count
	dec		player.screen_y

@joy1_skip_dpad_u:

    ;
    ; Check the jump count
    lda     player.in_jump_count                 
    beq     @ground_check                   ; if we are not in a jump do ground check

@handle_jump:
    dec     player.in_jump_count
    dec     player.screen_y
    stz     player.on_ground
    jmp     @end

    ;
    ; Load player screen position into x and y
@ground_check:
	lda		player.screen_x
	clc
	adc		#8
	tax
	lda		player.screen_y

;	sec                                     ; Y position is 16 screen pixel to low, but the map is
                                            ; also move by 16 pixel down - so the balance out
;	sbc     #16
	tay
    stz     player.on_ground
	game_map_content_at_screen_pos
	lda.w	tilemap, x	
	cmp		#16
	bne		@on_floor

@off_floor:
	inc		player.screen_y
	jmp		@end

@on_floor:
    lda     #1
    sta     player.on_ground

@end
    rts








;----------------------------------------------------------------------------------------------------------------------
; The top main game loop, does not much at the moment
GameEnemy_Move:
@begin:
	
	; Clear all 16 bits of A
    lda     #0
    xba
    lda     #0
	_useIndex16_
;

	;
	; Enemies alway fall straight  XXX Fix me, this will break jumping
	lda		enemy.on_ground
	bne		@move_left_right
	jmp 	@joy1_skip_dpad_u



@move_left_right
;	lda		JOY1L
	lda		enemy.flip_mask					; load the facing direction
	tax										; Store it to X so we can restore it quickly
	bit		#kSPRITE_FLIP_X_BITMASK			; Check button R
	bne		@joy1_skip_dpad_r

	inc		enemy.screen_x

@clamp_sprite_x_max
	lda		#kMAX_X_SCREEN_POS				; make sure we do not run out of screen on the left
	cmp		enemy.screen_x
	bcs		@skip_set_max_x					; clear if A >= M
	sta		enemy.screen_x					; adjust x position	to 16
	lda		#kSPRITE_FLIP_X_BITMASK
	sta		enemy.flip_mask


@skip_set_max_x:
	jmp		@joy1_skip_dpad_u

@joy1_skip_dpad_r:
	;bit		#kDPAD_LEFT						; is left dpad pressed
	;beq		@joy1_skip_dpad_l

@move_sprite_left
	dec		enemy.screen_x					; yes, move sprite left
	
@clamp_sprite_x_min
	lda		#kMIN_X_SCREEN_POS				; make sure we do not run out of screen on the left
	cmp		enemy.screen_x
	bcc		@skip_set_min_x					; clear if A >= M
	sta		enemy.screen_x					; adjust x position	to 16
	lda		#kSPRITE_FLIP_X_BITMASK
	stz		enemy.flip_mask

@skip_set_min_x:


/* @joy1_skip_dpad_d:

    ; We can only jump if we are on the ground
    lda     player.on_ground
    beq     @joy1_skip_dpad_u

    ; Handle dpad up
	txa
	bit		#kDPAD_UP
	beq		@joy1_skip_dpad_u

    stz     player.on_ground
    lda     #kPLAYER_JUMP_COUNT
    sta     player.in_jump_count
	dec		player.screen_y
 */
@joy1_skip_dpad_u:

    ;
    ; Check the jump count
    lda     enemy.in_jump_count                 
    beq     @ground_check                   ; if we are not in a jump do ground check

@handle_jump:
    dec     enemy.in_jump_count
    dec     enemy.screen_y
    stz     enemy.on_ground
    jmp     @end

    ;
    ; Load player screen position into x and y
@ground_check:
	lda		enemy.screen_x
	clc
	adc		#8
	tax
	lda		enemy.screen_y

;	sec                                     ; Y position is 16 screen pixel to low, but the map is
                                            ; also move by 16 pixel down - so the balance out
;	sbc     #16
	tay
    stz     enemy.on_ground
	
	; Hack if entity is to close to upper map edge
	;cmp		#32
	;bcc		@off_floor						; clear if A >= M

	game_map_content_at_screen_pos
	lda.w	tilemap, x	
	cmp		#16
	bne		@on_floor

@off_floor:
	inc		enemy.screen_y
	jmp		@end

@on_floor:
    lda     #1
    sta     enemy.on_ground

@end
    rts



.ends

