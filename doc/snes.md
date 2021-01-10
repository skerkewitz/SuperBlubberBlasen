# SNES Memory Map


## Banks
The 65816 of the SNES has a 24bit address bus and therefore can theoretically access up to 16MB of RAM.

A 24bit address is made up from 3 bytes:

| Byte | Bits | Describtion |
| ---- | -----| ------ |
| byte 3 | bits 16-23 | the bank byte |
| byte 2 | bits 8-15 | the high byte (also known as page byte) |
| byte 1 | bits 0-7 | the low byte |

So one pages consist of 256 bytes and one bank consist of 256 pages (or 65536 bytes). On the SNES banks are somestimes split into two 32Kbyte halves:

 * 0000h - 7FFFh = bottom bank
 * 8000h - FFFFh = top bank

### Bank handling on the 65816

The 65816 uses two special register to handle the bank part of an 24 bit address:
* `DBR` is the data bank register
* `PBR` is the progam bank register



## Overall Memory Map

The overall memory map of the SNES looks like this:

| Bank | Offset | Content | Speed |
| --- | --- | --- | --- |
| 00h-3Fh | 0000h-7FFFh | System Area (8K WRAM, I/O Ports, Expansion) | see below |
| 00h-3Fh | 8000h-FFFFh | WS1 LoROM (max 2048 Kbytes) (64x32K)        | 2.68MHz |
| 00h | FFE0h-FFFFh | CPU Exception Vectors (Reset,Irq,Nmi,etc.)  | 2.68MHz |
| 40h-7Dh | 0000h-FFFFh | WS1 HiROM (max 3968 Kbytes) (62x64K)        | 2.68MHz |
| 7Eh-7Fh | 0000h-FFFFh | WRAM (Work RAM, 128 Kbytes) (2x64K)         | 2.68MHz |
| 80h-BFh | 0000h-7FFFh | System Area (8K WRAM, I/O Ports, Expansion) | see below |
| 80h-BFh | 8000h-FFFFh | WS2 LoROM (max 2048 Kbytes) (64x32K)        | max 3.58MHz |
| C0h-FFh | 0000h-FFFFh | WS2 HiROM (max 4096 Kbytes) (64x64K)        | max 3.58MHz |


The system area (banks 00h-3Fh and 80h-BFh) look like this:
| Offset | Content | Speed |
| --- | --- | --- |
| 0000h-1FFFh | Mirror of 7E0000h-7E1FFFh (first 8Kbyte of WRAM)   |  2.68MHz |
| 2000h-20FFh | Unused                                             |  3.58MHz |
| 2100h-21FFh | I/O Ports (B-Bus)                                  |  3.58MHz |
| 2200h-3FFFh | Unused                                             |  3.58MHz |
| 4000h-41FFh | I/O Ports (manual joypad access)                   |  1.78MHz |
| 4200h-5FFFh | I/O Ports                                          |  3.58MHz |
| 6000h-7FFFh | Expansion                                          |  2.68MHz |

Internal memory regions are WRAM and memory mapped I/O ports.
External memory regions are LoROM, HiROM, and Expansion areas.

Additional memory (not mapped to CPU addresses) (accessible only via I/O):
 * OAM          (512+32 bytes) (256+16 words)
 * VRAM         (64 Kbytes)    (32 Kwords)
 * Palette      (512 bytes)    (256 words)
 * Sound RAM    (64 Kbytes)
 * Sound ROM    (64 bytes BIOS Boot ROM)


### A-Bus and B-Bus
Aside from the 24bit address bus (A-Bus), the SNES is having a second 8bit address bus (B-bus), used to access certain I/O ports. Both address busses are sharing the same data bus, but each bus is having its own read and write signals. The CPU can access the B-Bus at offset 2100h-21FFh within the System Area (ie. for CPU accesses, the B-Bus is simply a subset of the A-Bus). The DMA controller can access both B-Bus and A-Bus at once (ie. it can output source & destination addresses simultaneously to the two busses, allowing it to "read-and-write" in a single step, instead of using separate "read-then-write" steps).

## WRAM - Work ram
The SNES has 128kb of "work ram". This is what nowdays is just called ram. But because the SNES has special RAM for dedicated task the normal ram to work with is called work ram.

## CGRAM - Colors palettes
The color palette is store in `CGRAM`. Each color is a 15 bit RGB value in the format `0bbbbbgg gggrrrrr`. Note that the highest bit of the high byte is not used. The highest Change the palette you use `CGADD` to specify the address (index of the colors) and then write two bytes to `CGDATA` (lo byte, hi byte). This can only be done while `VBlank` is active.

* If you use 4bpp palettes a tile/sprite can have 16 different colors and the palettes need 32 bytes.
* If you use 2bpp palettes a tile/sprite can have 4 different colors and the palettes need 8 bytes.

## VRAM - Tilesset, tilemaps and sprites
The SNES has 64kb of VRAM. It is more or less up to you how you wanna layout the data in VRAM, but all your tilesset, tilemaps and sprite you wanna display has to fit into 64kb.

To display data the SNES offers serveral layer: one or more background layers and a single sprite layer. The selected display mode dictates the amount of background layer and the color depths (bpp) of the layer. The background layer can slected between a few size combination. The default size of a background layer is 32x32 tiles (called a screen). 

You can have a background layer in the size of:
* 1x1 screen
* 1x2 screens
* 2x1 screens
* 2x2 screens

By specifying an scroll offset per background layer you can do smooth scrolling.

## OAM - The "Object Attribute Memory"
This memory is used to defines sprites. Sprites are also called objects on the SNES. The size of the OAM is 512 + 32 bytes.

* Sprites are always 4bpp.
* Sprites can only access palette 0-7.

### OAM (Object Attribute Memory) layout
The OAM size is 512+32 bytesc and contains data for 128 OBJs. The first part (512 bytes) contains 128 4-byte entries for each OBJ:

| Byte | Describtion |
| ---- | ----------- |
| 0 | X-Coordinate (lower 8bit, upper 1bit at end of OAM) |
| 1 | Y-Coordinate (all 8bits) |
| 2 | Tile Number  (lower 8bit, upper 1bit within Attributes) |
| 3 | Attributes |

The attributes in byte 3 are defines as:

| Bits | Describtion |
| ---- | ----------- |
| 7 | Y-Flip (0=Normal, 1=Mirror Vertically) |
| 6 | X-Flip (0=Normal, 1=Mirror Horizontally) |
| 5-4 | Priority relative to BG (0=Low..3=High) |
| 3-1 | Palette number 0-7 (OBJ Palette 4-7 can use Color Math via CGADSUB) |
| 0 | Tile Number (upper 1bit) |


After above 512 bytes, additional 32 bytes follow, containing 2-bits per OBJ:

| Bits | Describtion |
| ---- | ----------- |
| 7 | OBJ 3 OBJ Size (0=Small, 1=Large) |
| 6 | OBJ 3 X-Coordinate (upper 1bit) |
| 5 | OBJ 2 OBJ Size     (0=Small, 1=Large) |
| 4 | OBJ 2 X-Coordinate (upper 1bit) |
| 3 | OBJ 1 OBJ Size     (0=Small, 1=Large) |
| 2 | OBJ 1 X-Coordinate (upper 1bit) |
| 1 | OBJ 0 OBJ Size     (0=Small, 1=Large) |
| 0 | OBJ 0 X-Coordinate (upper 1bit) |


And so on, next 31 bytes with bits for OBJ4..127.

> Note: The meaning of the OBJ Size bit (Small/large) can be defined in OBSEL register (port 2101h).

* Maximum onscreen objects (sprites): 128 (32 per line, up to 34 8x8 tiles per line).
* Maximum number of sprite pixels on one scanline: 256.

> Note: the renderer was designed such that it would drop the frontmost sprites instead of the rearmost sprites if a scanline exceeded the limit, allowing for creative clipping effects.
