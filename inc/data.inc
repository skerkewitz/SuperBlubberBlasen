; Contains all the static file fata


.macro filtermacro_tilemap    ; the input byte is \1, the output byte is in "_out"
	.if \1 == 0
		.redefine _out \1+16
	.else
		.redefine _out \1
	.endif
.endm


.section "StaticFileData"
	;palette:	.INCBIN "data/palette.dat"	FSIZE size_of_palette
	;tiles:		.INCBIN "data/tile.dat"		FSIZE size_of_tiles

	palette:			.INCBIN "data/round01_palette.dat"				FSIZE size_of_palette
	tiles:				.INCBIN "data/round01_tile.dat"					FSIZE size_of_tiles

	spr_bubblun_pal:	.INCBIN "data/bubblun_palette.dat"				FSIZE size_of_bubblun_palette
	spr_bubblun_tiles:	.INCBIN "data/bubblun_tile.dat"					FSIZE size_of_bubblun_tiles

	tilemap:			.incbin "res/level/round01.map"		READ 832	FSIZE size_of_tilemap	FILTER filtermacro_tilemap
.ends

