#
# Vars

ASM = ../wla-dx/build/binaries/wla-65816
LINKER = ../wla-dx/build/binaries/wlalink

SRC-DIR = ./src
INC-DIR = $(SRC-DIR)/inc

OUT-DIR = ./out
OBJ-OUT-DIR = $(OUT-DIR)/obj
LIB-OUT-DIR = $(OUT-DIR)/lib

ASM-INC = -I $(INC-DIR)
LINKER-FLAGS = -S -A -v

OUT-NAME = sblubber
ROM-NAME = $(OUT-NAME).smc


SF-TILE16x16 = --tile-width 16 --tile-height 16
SF-NODISCARD = --no-discard --no-flip 
#
# Rules

build: data lib obj
	mkdir -p $(OUT-DIR)
	$(LINKER) $(LINKER-FLAGS) -i sblubber.link $(ROM-NAME)

obj:
	mkdir -p $(OBJ-OUT-DIR)
	$(ASM) -v $(ASM-INC) -i -o $(OBJ-OUT-DIR)/main.obj $(SRC-DIR)/main.asm
	$(ASM) -v $(ASM-INC) -i -o $(OBJ-OUT-DIR)/game_player.obj $(SRC-DIR)/game_player.asm

lib:
	mkdir -p $(LIB-OUT-DIR)

	# SNES code
	$(ASM) -v $(ASM-INC) -i -l $(LIB-OUT-DIR)/snes_init.lib $(SRC-DIR)/snes_init.asm
	$(ASM) -v $(ASM-INC) -i -l $(LIB-OUT-DIR)/snes_dma.lib $(SRC-DIR)/snes_dma.asm
	


clean:
	rm -rf $(OUT-DIR)
	rm -f *.sym
	rm -f *.smc
	rm -rf ./obj
	rm -rf ./lib
	rm -rf ./data
	find . -name '*.lst' -delete

data: round01 bubblun zanchan

round01:
	mkdir -p data
	superfamiconv -v -W 8 -H 8 --color-zero 00000000 -i ./res/level/round01.png -p ./data/round01_palette.dat -D -F -t ./data/round01_tile.dat -B 4

bubblun:
	mkdir -p data
	superfamiconv --verbose --no-remap --color-zero FF00FF --sprite-mode $(SF-TILE16x16) $(SF-NODISCARD) --bpp 4  -i ./res/sprite/bubblun.png -p ./data/bubblun_palette.dat --out-tiles ./data/bubblun_tile.dat 

zanchan:
	mkdir -p data
	superfamiconv --verbose --no-remap --color-zero FF00FF --sprite-mode $(SF-TILE16x16) $(SF-NODISCARD) --bpp 4  -T 3 -i ./res/sprite/sprites.png -p ./data/sprites_palette.dat --out-tiles ./data/sprites_tile.dat