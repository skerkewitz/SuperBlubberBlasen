;
; Contains the definition of all SNES hardware register


.include "snes_ppu_control.inc"
.include "snes_ppu_bg_control.inc"
.include "snes_vram_bg_tile_access.inc"     ; VRAM access for tiles and backgrounds
.include "snes_controller_io.inc"           ; SNES controller I/O port for manual reading

.define CGADD	$2121		; CGRAM address register
.define CGDATA	$2122		; CGRAM data write register

