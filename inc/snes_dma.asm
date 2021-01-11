;
; Contains the definition of SNES memory CGRAM access (Palette Memory)

.include "snes.inc"

;.bank 0 slot 0
.section "SnesLibDmaCode" 


;============================================================================
; DMAPalette -- Load entire palette using DMA channel 0
;----------------------------------------------------------------------------
; In: A:X  -- points to the data
;      Y   -- Size of data
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: none
;----------------------------------------------------------------------------
SnesDma0LoadPaletteIntoVram_a8i16vb:
    phb
    php         			; push registers to stack

    stx $4302				; Store data offset into DMA source offset
	sta $4304				; Store data bank into DMA source bank
    sty $4305				; Store size of data block

    stz DMAP0				; Set DMA mode (cpu -> io, a-bus increment, transfer 1 byte)

    lda #BBAD_DT_CGRAM		; Set b-bus destination register ($2122 - CGRAM Write)
    sta BBAD0
    
	lda #$01				; Initiate DMA transfer for channel 0
    sta MDMAEN		

    plp
    plb
    rts    			 	    ; return from subroutine


;============================================================================
; DMAPalette -- Load entire palette using DMA channel 0
;----------------------------------------------------------------------------
; In: A:X  -- points to the data
;      Y   -- Size of data
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: none
;----------------------------------------------------------------------------
SnesDma1LoadTilesIntoVram_a8i16vb:
    phb
    php         		; push registers to stack

    stx $4312			; Store data offset into DMA source offset
	sta $4314			; Store data bank into DMA source bank
    sty $4315			; Store size of data block

    lda #1
	sta DMAP1			; Set DMA mode (cpu -> io, a-bus increment, transfer 2 byte)

    lda #BBAD_DT_VRAM	; Set b-bus destination register VRRAM
    sta BBAD1
    
	lda #$02			; Initiate DMA transfer for channel 1
    sta MDMAEN		

    plp
    plb
    rts     	    	; return from subroutine



.ends
