; Contains all the static file fata

.section "StaticFileData"
	palette:	.INCBIN "res/palette.dat"	FSIZE size_of_palette
	tiles:		.INCBIN "res/tile.dat"		FSIZE size_of_tiles
.ends
