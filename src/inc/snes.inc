;
; Contains the definition of all SNES hardware register


.include "snes_ppu_control.inc"
.include "snes_ppu_bg_control.inc"
.include "snes_vram_bg_tile_access.inc"     ; VRAM access for tiles and backgrounds
.include "snes_controller_io.inc"           ; SNES controller I/O port for manual reading
.include "snes_cgram.inc"                   ; SNES CGRAM access
.include "snes_dma.inc"                   ; SNES CGRAM access


;
; Use this macro to initialize the SNES
.MACRO Snes_Init
 	sei 	 	    ; Disabled interrupts
 	
	; switch to native mode
 	clc 	 	    ; clear carry to switch to native mode
 	xce 	 	    ; Xchange carry & emulation bit. native mode

 	rep 	#$18 	; Binary mode (decimal mode off), X/Y 16 bit
	ldx 	#$1FFF  ; set stack to $1FFF
	txs
 
	jsr Init
 .ENDM

.macro _useIndex16_					; Turn on 16bit mode on for X and Y, also let wla know using .index16
	.index 	16
	rep		#$10					; turn X flag in SR off
.endm

.macro _useIndex8_					; Turn on 8bit mode on for X and Y, also let wla know using .index8
	.index	8
	sep		#$10					; turn X flag in SR on
.endm

.macro _useAccu16_					; Turn on 16bit mode on for A, also let wla know using .accu16
	.accu 	16
	rep		#$20					; turn M flag in SR off
.endm

.macro _useAccu8_					; Turn on 8bit mode on for A, also let wla know using .accu8
	.accu	8
	sep		#$20					; turn M flag in SR on
.endm


