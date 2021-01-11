;
; Contains the definition of SNES memory CGRAM access (Palette Memory)


.define CGADD       $2121 		; Palette CGRAM Address (Color Generator Memory) (W)
                                ;
                                ; Color index (0..255). This is a WORD-address (2-byte steps), allowing to access
                                ; 256 words (512 bytes). Writing to this register resets the 1st/2nd access flipflop
                                ; (for 2122h/213Bh) to 1st access.

.define CGDATA      $2122       ; Palette CGRAM Data Write (W)
.define RDCGRAM     $212D       ; Palette CGRAM Data Read (R)
                                ;
                                ; 1st Access: Lower 8 bits (even address)
                                ; 2nd Access: Upper 7 bits (odd address) (upper 1bit = PPU2 open bus)
                                ;
                                ; Reads and Writes to EVEN and ODD byte-addresses work as follows:
                                ;  Write to EVEN address  -->  set Cgram_Lsb = Data    ;memorize value
                                ;  Write to ODD address   -->  set WORD[addr-1] = Data*256 + Cgram_Lsb
                                ;  Read from ANY address  -->  return BYTE[addr]
                                ;
                                ; The address is automatically incremented after every read or write access.



;======================================================================================================================
; Reset the CGADD register to zero
;----------------------------------------------------------------------------
; In: None
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: nothing
; Requires: mem/A = 8 bit, X/Y = 16 bit
; Requires: VBlank active
;----------------------------------------------------------------------------
.macro _snes_cg_address_0_		
    stz     CGADD               ; set CDRAM address to color index 0
.endm

;======================================================================================================================
; Reset the CGADD register to zero
;----------------------------------------------------------------------------
; In: None
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: A
; Requires: mem/A = 8 bit, X/Y = 16 bit
; Requires: VBlank active
;----------------------------------------------------------------------------
.macro _snes_cg_address_i_ args color_index	
    lda     #color_index
    sta     CGADD               ; set CDRAM address to the given color index
.endm
