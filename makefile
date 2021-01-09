#
# Vars

ASM = wla-65816
ASM_INC = -I ./inc

LINKER = wlalink
LINKER-FLAGS = -s -S -A -v

OUT-NAME = sblubber
ROM-NAME = $(OUT-NAME).smc

#
# Rules

build: obj compile
	wlalink $(LINKER-FLAGS) -i sblubber.link $(ROM-NAME)

obj:
	mkdir ./obj

compile:
	$(ASM) -v $(ASM_INC) -o ./obj/main.obj main.asm

clean:
	rm -f *.smc
	rm -rf ./obj

round01:
	superfamiconv -v -W 8 -H 8 --color-zero 00000000 -i ./res/level/round01.png -p ./data/round01_palette.dat -D -F -t ./data/round01_tile.dat -B 4

