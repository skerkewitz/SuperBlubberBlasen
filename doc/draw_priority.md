# Draw priority of tiles and sprites

The order of the background layer is always highest to lowest. Meaning BG4 is the layer which is drawn first (behind) and BG1 ist the layer drawn last (front).

However, tiles and sprites have a priority flag to change the priority of a single tile or sprite. The priority of the tile is not on set tileset tile itself but on the tile in the tilemap.

## Priority of tiles

Remember: a tile in the tilemap looks like this:

| High byte | Low byte | Legend |
| --- | --- | --- |
| `vhopppcc` | `cccccccc` |  `c`: Starting character (tile) number<br/> `h`: horizontal flip<br/> `v`: vertical flip<br/> `p`: palette number<br/>`o`: priority bit |

Priority of a tile is the single bit 13.

## Priority of sprites

A sprites on the SNES looks like this:

| Byte | Bit layout | Legend
| --- | --- | --- |
| Byte 1 | `xxxxxxxx` | `x`: X coordinate |
| Byte 2 | `yyyyyyyy` | `y`: Y coordinate |
| Byte 3 | `cccccccc` | `c`: starting character (tile) number <br/>
| Byte 4 | `vhoopppc` | `v`: vertical flip<br/> `h`: horizontal p: palette number flip<br/> `o`: priority bits<br/>`p`: palette number<br/>`c`: most significant bit (bit 9) of character <br/>

So on a tile you have two bits (bit 4 and 5 of byte 4) to specifiy a priority.

## Draw order

The also a priorty bit p on the Screen mode register (bit 4 on `BGMODE`/`$2105`)

The actual draw order depends on what priority is set for each tile/sprite:

| p (Priority) | 0 | 1 |
| --- | --- | --- |
| Drawn first | BG4, o=0 | BG4, o=0 |
| (Behind) | BG3, o=0 | BG3, o=0 |
| . | Sprites with OAM priority 0 (%00) ||
| . | BG4, o=1 | BG4, o=1 |
| . | BG3, o=1 | OAM pri. 1 |
| . | OAM pri. 1 | BG2, o=0 |
| . | BG2, o=0 | BG1, o=0 |
| . | BG1, o=0 | BG2, o=1 |
| . | Sprites with OAM priority 2 (%10) ||
| . | BG2, o=1 | BG1, o=1 |
| Drawn last | BG1, o=1 | OAM pri. 3 |
| (in front) | OAM pri. 3 | BG3, o=1 |

The p bit only works in Mode 1.  In all other modes, it is ignored (drawing is performed as if this bit were clear.)