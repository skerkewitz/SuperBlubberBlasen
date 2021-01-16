

.define GAME_LEVEL_WIDTH        32      ; The width of the level in 8 pixel tiles
.define GAME_LEVEL_HEIGHT       26      ; The height of the level in 8 pixel tiles

.define kMIN_X_SCREEN_POS       16                          ; left of sprite screen position can not be smaller
.define kMAX_X_SCREEN_POS       (GAME_LEVEL_WIDTH-4) * 8    ; left of sprite screen position can not be bigger

;
; Load the tile for the screen pos in register X, Y into A
; We could use a bit array here instead byte array.
.MACRO game_map_content_at_screen_pos
    
    _useAccu16_
    txa
    and     #$FF    ; clear higher 8 bit garbage
    clc
    lsr             ; div 2
    lsr             ; div 4
    lsr             ; div 8
    
    pha             ; Push one time as it A is 16bit
    
    tya             ; Transfer Y screen position into A
    and     #$FF    ; clear higher 8 bit garbage
    clc
    lsr             ; div 2
    lsr             ; div 4
    lsr             ; div 8

    clc
    rol             ; time 2
    clc
    rol             ; time 4
    clc
    rol             ; time 8
    clc
    rol             ; time 16
    clc
    rol             ; time 32
    
    clc
    adc     1,s
    tax
    lda     #0
    _useAccu8_
    ;lda     tilemap,x
    ply  
 .ENDM
