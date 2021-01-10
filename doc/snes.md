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
