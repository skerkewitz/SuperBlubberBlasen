;
; Contains the definition of all SNES hardware register



.define JOYWR       $4016 		; Joypad Output (W)
                                ;
                                ;  7-3  Not used
                                ;  2    OUT2, Output on CPU Pin 39 (seems to be not connected) (1=High)
                                ;  1    OUT1, Output on CPU Pin 38 (seems to be not connected) (1=High)
                                ;  0    OUT0, Output on CPU Pin 37 (Joypad Strobe) (both gameports, pin 3)
                                ;
                                ; Out0-2 are found on CPU Pins 37-39, of which only Out0 seems to be connected.
                                ; Note: The NSS (arcade cabinet) uses OUT2 to signalize Game Over to the Z80 coprocessor.


.define JOYA        $4016 		; Joypad Input Register A (R)
                                ;
                                ;  7-2  Not used
                                ;  1    Input on CPU Pin 33, connected to gameport 1, pin 5 (JOY3) (1=Low)
                                ;  0    Input on CPU Pin 32, connected to gameport 1, pin 4 (JOY1) (1=Low)
                                ;
                                ; Reading from this register automatically generates a clock pulse on CPU Pin 35, which is connected to gameport 1, pin 2.


.define JOYB        $4017 		; Joypad Input Register B (R)
                                ;
                                ;  7-5  Not used
                                ;  4    Input on CPU Pin 31, connected to GND (always 1=LOW)       (1=Low)
                                ;  3    Input on CPU Pin 30, connected to GND (always 1=LOW)       (1=Low)
                                ;  2    Input on CPU Pin 29, connected to GND (always 1=LOW)       (1=Low)
                                ;  1    Input on CPU Pin 28, connected to gameport 2, pin 5 (JOY4) (1=Low)
                                ;  0    Input on CPU Pin 27, connected to gameport 2, pin 4 (JOY2) (1=Low)
                                ;
                                ; Reading from this register automatically generates a clock pulse on CPU Pin 36, which is connected to gameport 2, pin 2.


.define WRIO        $4201 		; Joypad Programmable I/O Port (Open-Collector Output) (W)
                                ;
                                ;  7-0   I/O PORT  (0=Output Low, 1=HighZ/Input)
                                ;  7     Joypad 2 Pin 6 / PPU Lightgun input (should be usually always 1=Input)
                                ;  6     Joypad 1 Pin 6
                                ;  5-0   Not connected (except, used by SFC-Box; see Hotel Boxes)
                                ;
                                ; Note: Due to the weak high-level, the raising "edge" is raising rather slowly, for sharper transitions one may need external pull-up resistors.

.define RDIO        $4213 		; Joypad Programmable I/O Port (Input) (R)
                                ;
                                ;  7-0   I/O PORT  (0=Low, 1=High)
                                ;
                                ; When used as Input via 4213h, set the corresponding bits in 4201h to HighZ.

.define JOY1L       $4218       ; Joypad 1 lo byte (gameport 1, pin 4) (R)
.define JOY1H       $4219       ; Joypad 1 hi byte (gameport 1, pin 4) (R)
.define JOY2L       $421A       ; Joypad 2 lo byte (gameport 2, pin 4) (R)
.define JOY2H       $421B       ; Joypad 2 hi byte (gameport 2, pin 4) (R)
                                ;
                                ;  Register    Serial     Default
                                ;  Bit         Transfer   Purpose
                                ;  Number______Order______(Joypads)_____
                                ;   15          1st        Button B          (1=Low=Pressed)
                                ;   14          2nd        Button Y
                                ;   13          3rd        Select Button
                                ;   12          4th        Start Button
                                ;   11          5th        DPAD Up
                                ;   10          6th        DPAD Down
                                ;   9           7th        DPAD Left
                                ;   8           8th        DPAD Right
                                ;   7           9th        Button A
                                ;   6           10th       Button X
                                ;   5           11th       Button L
                                ;   4           12th       Button R
                                ;   3           13th       0 (High)
                                ;   2           14th       0 (High)
                                ;   1           15th       0 (High)
                                ;   0           16th       0 (High)
                                ;
                                ; Before reading above ports, set Bit 0 in port 4200h to request automatic reading, then wait until Bit 0
                                ; of port 4212h gets set-or-cleared? Once 4200h enabled, seems to be automatically read on every retrace?
                                ;
                                ; Be sure that Out0 in Port 4016h is zero (otherwise the shift register gets stuck on the first bit, ie.
                                ; all 16bit will be equal to the B-button state.
                                ;
                                ; AUTO JOYPAD READ
                                ; ----------------
                                ; When enabled, the SNES will read 16 bits from each of the 4 controller port data lines into registers
                                ; $4218-f. This begins between H=32.5 and H=95.5 of the first V-Blank scanline, and ends 4224 master cycles
                                ; later. Register $4212 bit 0 is set during this time. Specifically, it begins at H=74.5 on the first frame,
                                ; and thereafter some multiple of 256 cycles after the start of the previous read that falls within the observed
                                ; range.
                                ;
                                ; Reading $4218-f during this time will read back incorrect values. The only reliable value is that no buttons
                                ; pressed will return 0 (however, if buttons are pressed 0 could still be returned incorrectly). Presumably
                                ; reading $4016/7 or writing $4016 during this time will also screw things up.


;
; Enable automatic reading for both joypads
.MACRO _sns_controller_io__enable_automatic_joypad_read
    lda     #%11000000	        ; have the automatic read of the SNES read the first pair of JoyPads
	sta     WRIO		        ; IO Port Write Register

    lda     #%10000001	        ; Enable NMI and JoyPad $81		
	sta     $4200   	        ; Interrupt Enable Flags
.ENDM
