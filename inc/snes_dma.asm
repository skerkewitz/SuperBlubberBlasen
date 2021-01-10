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
SnesDmaLoadPaletteIntoVram_a8i16vb:
    phb
    php         	; push registers to stack

    stx $4302		; Store data offset into DMA source offset
	sta $4304		; Store data bank into DMA source bank
    sty $4305		; Store size of data block

    stz DMAP0		; Set DMA mode (cpu -> io, a-bus increment, transfer 1 byte)

    lda #$22		; Set b-bus destination register ($2122 - CGRAM Write)
    sta BBAD0
    
	lda #$01		; Initiate DMA transfer for channel 0
    sta MDMAEN		

    plp
    plb
    rts     	    ; return from subroutine

.ends
