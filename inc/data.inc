; Contains all the static file fata

.section "StaticFileData"
	;palette:	.INCBIN "data/palette.dat"	FSIZE size_of_palette
	;tiles:		.INCBIN "data/tile.dat"		FSIZE size_of_tiles

	palette:	.INCBIN "data/round01_palette.dat"	FSIZE size_of_palette
	tiles:		.INCBIN "data/round01_tile.dat"		FSIZE size_of_tiles
.ends
