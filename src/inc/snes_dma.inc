;
; Contains the definition of SNES memory CGRAM access (Palette Memory)


; === DMA start/stop register ===

.define MDMAEN      $420B 		; Select General Purpose DMA Channel(s) and Start Transfer (W)
                                ;
								;  7-0   General Purpose DMA Channel 7-0 Enable (0=Disable, 1=Enable)
								;
								; When writing a non-zero value to this register, general purpose DMA will be started
								; immediately (after a few clock cycles). The CPU is paused during the transfer. The
								; transfer can be interrupted by H-DMA transfers. If more than 1 bit is set in MDMAEN,
								; then the separate transfers will be executed in order channel 0=first through 7=last.
								; The MDMAEN bits are cleared automatically at transfer completion.
								;
								; Do not use channels for GP-DMA which are activated as H-DMA in HDMAEN.


.define HDMAEN      $420C       ; Select H-Blank DMA (H-DMA) Channel(s) (W)
                                ;
                                ;  7-0   H-DMA Channel 7-0 Enable (0=Disable, 1=Enable)


; === DMA channel channel register  ===

.define DMAP0       $4300 		; DMA/HDMA channel 0 parameters (R/W)
.define DMAP1       $4310 		; DMA/HDMA channel 1 parameters (R/W)
.define DMAP2       $4320 		; DMA/HDMA channel 2 parameters (R/W)
.define DMAP3       $4330 		; DMA/HDMA channel 3 parameters (R/W)
.define DMAP4       $4340 		; DMA/HDMA channel 4 parameters (R/W)
.define DMAP5       $4350 		; DMA/HDMA channel 5 parameters (R/W)
.define DMAP6       $4360 		; DMA/HDMA channel 6 parameters (R/W)
.define DMAP7       $4370 		; DMA/HDMA channel 7 parameters (R/W)
                                ;
                                ;  7     Transfer Direction		(0=A:CPU to B:I/O, 1=B:I/O to A:CPU)
								;  6     Addressing Mode    	(0=Direct Table, 1=Indirect Table)		(HDMA only)
								;  5     Not used (R/W)			(unused and unchanged by all DMA and HDMA)
								;  4-3   A-BUS Address Step		(0=Increment, 2=Decrement, 1/3=Fixed)	(DMA only)
								;  2-0   Transfer Unit Select	(0-4=see below, 5-7=Reserved)
								;
								; DMA Transfer Unit Selection:
								;  Mode  Bytes              B-Bus 21xxh Address   ;Usage Examples...
								;  0  =  Transfer 1 byte    xx                    ;eg. for WRAM (port 2180h)
								;  1  =  Transfer 2 bytes   xx, xx+1              ;eg. for VRAM (port 2118h/19h)
								;  2  =  Transfer 2 bytes   xx, xx                ;eg. for OAM or CGRAM
								;  3  =  Transfer 4 bytes   xx, xx,   xx+1, xx+1  ;eg. for BGnxOFS, M7x
								;  4  =  Transfer 4 bytes   xx, xx+1, xx+2, xx+3  ;eg. for BGnSC, Window, APU..
								;  5  =  Transfer 4 bytes   xx, xx+1, xx,   xx+1  ;whatever purpose, VRAM maybe
								;  6  =  Transfer 2 bytes   xx, xx                ;same as mode 2
								;  7  =  Transfer 4 bytes   xx, xx,   xx+1, xx+1  ;same as mode 3
								;
								; A HDMA transfers ONE unit per scanline (=max 4 bytes). General Purpose DMA has a
								; 16bit length counter, allowing to transfer up to 10000h bytes (ie. not 10000h units).



.define BBAD0     	$4301 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
.define BBAD1     	$4311 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
.define BBAD2     	$4321 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
.define BBAD3     	$4331 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
.define BBAD4     	$4341 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
.define BBAD5     	$4351 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
.define BBAD6     	$4361 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
.define BBAD7     	$4371 		; DMA/HDMA B-Bus Address channel 0 (I/O Bus aka PPU-Bus aka B-Bus) (R/W)
								;
								; For both DMA and HDMA:
								;   7-0   B-Bus Address (selects an I/O Port which is mapped to 2100h-21FFh)
								;
								; For normal DMA this should be usually 04h=OAM, 18h=VRAM, 22h=CGRAM, or 80h=WRAM.
								; For HDMA it should be usually some PPU register (eg. for changing scroll offsets midframe).


.define BBAD_DT_OAM		$04		; BBus DMA target Object attribute memory
.define BBAD_DT_VRAM	$18		; BBus DMA target VRAM
.define BBAD_DT_CGRAM	$22		; BBus DMA target CGRAM
.define BBAD_DT_WRAM	$80		; BBus DMA target WRAM




;============================================================================
; LoadPalette - Macro that loads palette information into CGRAM
;----------------------------------------------------------------------------
; In:	source_addr				24 bit address of source data,
;		size_in_bytes			amount of bytes(!) to copy
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: A,X
; Requires: mem/A = 8 bit, X/Y = 16 bit
;----------------------------------------------------------------------------
.MACRO _snes_load_palette_into_vram_a8i16vb_ args source_addr size_in_bytes
    lda #:source_addr        	; Using : before the parameter gets its bank.
    ldx #source_addr         	; Not using : gets the offset address (16bit)
    ldy #size_in_bytes			; amount of bytes, 2 bytes for every color
    
	; Call the actual channel 0 subroutine
	jsr SnesDma0LoadPaletteIntoVram_a8i16vb
.ENDM

;============================================================================
; LoadPalette - Macro that loads palette information into CGRAM
;----------------------------------------------------------------------------
; In:	source_addr				24 bit address of source data,
;		size_in_bytes			amount of bytes(!) to copy
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: A,X
; Requires: mem/A = 8 bit, X/Y = 16 bit
;----------------------------------------------------------------------------
.MACRO _snes_load_tiles_into_vram_a8i16vb_ args source_addr size_in_bytes
    lda #:source_addr        	; Using : before the parameter gets its bank.
    ldx #source_addr         	; Not using : gets the offset address (16bit)
    ldy #size_in_bytes			; amount of bytes, 2 bytes for every color
    
	; Call the actual channel 0 subroutine
	jsr SnesDma1LoadTilesIntoVram_a8i16vb
.ENDM

