#
# Vars

ASM = wla-65816
ASM_INC = -I ./inc

LINKER = wlalink
LINKER-FLAGS = -s -S -A -v

OUT-NAME = sblubber
ROM-NAME = $(OUT-NAME).smc

SF-TILE16x16 = --tile-width 16 --tile-height 16
SF-NODISCARD = --no-discard --no-flip 
#
# Rules

build: lib obj
	wlalink $(LINKER-FLAGS) -i sblubber.link $(ROM-NAME)

obj:
	mkdir ./obj
	$(ASM) -v $(ASM_INC) -o ./obj/main.obj main.asm

lib:
	mkdir ./lib
	$(ASM) -v $(ASM_INC) -l ./lib/snes_dma.lib snes_dma.asm

clean:
	rm -f *.smc
	rm -rf ./obj
	rm -rf ./lib
	rm -rf ./data

round01:
	superfamiconv -v -W 8 -H 8 --color-zero 00000000 -i ./res/level/round01.png -p ./data/round01_palette.dat -D -F -t ./data/round01_tile.dat -B 4

bubblun:
	superfamiconv --verbose --sprite-mode $(SF-TILE16x16) $(SF-NODISCARD) --bpp 4 --color-zero FF00FF -i ./res/sprite/bubblun.png -p ./data/bubblun_palette.dat --out-tiles ./data/bubblun_tile.dat 