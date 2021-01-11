#
# Vars

ASM = ../wla-dx/build/binaries/wla-65816
ASM_INC = -I ./inc

LINKER = ../wla-dx/build/binaries/wlalink

LINKER-FLAGS = -S -A -v

OUT-NAME = sblubber
ROM-NAME = $(OUT-NAME).smc

SF-TILE16x16 = --tile-width 16 --tile-height 16
SF-NODISCARD = --no-discard --no-flip 
#
# Rules

build: data lib obj
	$(LINKER) $(LINKER-FLAGS) -i sblubber.link $(ROM-NAME)

obj:
	mkdir ./obj
	$(ASM) -v $(ASM_INC) -i -o obj/main.obj main.asm

lib:
	mkdir ./lib
	$(ASM) -v $(ASM_INC) -i -l lib/snes_dma.lib snes_dma.asm

clean:
	rm -f *.smc
	rm -rf ./obj
	rm -rf ./lib
	rm -rf ./data
	find . -name '*.lst' -delete

data: round01 bubblun

round01:
	mkdir -p data
	superfamiconv -v -W 8 -H 8 --color-zero 00000000 -i ./res/level/round01.png -p ./data/round01_palette.dat -D -F -t ./data/round01_tile.dat -B 4

bubblun:
	mkdir -p data
	superfamiconv --verbose --no-remap --color-zero FF00FF --sprite-mode $(SF-TILE16x16) $(SF-NODISCARD) --bpp 4  -i ./res/sprite/bubblun.png -p ./data/bubblun_palette.dat --out-tiles ./data/bubblun_tile.dat 