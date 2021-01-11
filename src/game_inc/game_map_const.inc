

.define GAME_LEVEL_WIDTH          32      ; The width of the level in 8 pixel tiles
.define GAME_LEVEL_HEIGHT         26      ; The height of the level in 8 pixel tiles


;
; Load the tile for the screen pos in register X, Y into A
.MACRO game_map_content_at_screen_pos
    
    txa
    clc
    lsr             ; div 2
    lsr             ; div 4
    lsr             ; div 8
    
    pha             ; Push two times as it A is 8bit but plx at the end is 16 bit
    pha
    
    tya             ; Transfer Y screen position into A
    clc
    lsr             ; div 2
    lsr             ; div 4
    lsr             ; div 8

    clc
    rol             ; time 2
    rol             ; time 4
    rol             ; time 8
    rol             ; time 16
    rol             ; time 32
    
    clc
    adc     1,s
    tax
    ;lda     tilemap,x
    ply  
 .ENDM
