build: obj compile
	wlalink -s -S -A -v -i palette.link palette.smc

obj:
	mkdir ./obj

compile:
	wla-65816 -v -I ./inc -o ./obj/main.obj main.asm

clean:
	rm *.smc
	rm -r ./obj
