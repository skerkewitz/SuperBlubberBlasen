;
; Contains the definition of all SNES hardware register


.include "snes_ppu_control.inc"
.include "snes_ppu_bg_control.inc"
.include "snes_vram_bg_tile_access.inc"     ; VRAM access for tiles and backgrounds
.include "snes_controller_io.inc"           ; SNES controller I/O port for manual reading
.include "snes_cgram.inc"                   ; SNES CGRAM access
.include "snes_dma.inc"                   ; SNES CGRAM access


;.include "snes_dma.asm"                   ; SNES CGRAM access