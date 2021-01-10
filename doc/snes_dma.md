# SNES DMA Transfers

The SNES includes eight direct memory access (`DMA`) channels, which can be used for "horizontal blank DMA" (`H-DMA`) or "general purpose DMA" (`GP-DMA`).

## The GP-DMA (general purpose DMA)
The GP-DMA (general purpose DMA) can manually invoked by software, allowing to transfer larger amounts of data (max 10000h bytes). This is commonly used to transfer WRAM or ROM (on A-Bus side) to/from WRAM, OAM, VRAM, CGRAM (on B-Bus side). Note that you can not tranfer memory from WRAM to WRAM.

Keep in mind that a DMA transfer does not run parallel to normal CPU exceution. While DMA transfer is running the CPU will be halted. DMA transfer is much faster then copying data in a CPU loop! You can setup 8 DMA transfers, they will run one after another.

## The H-DMA (H-Blank DMA)
The H-DMA (H-Blank DMA) transfers are automatically invoked on H-Blank, each H-DMA is limited to a single unit (max 4 bytes) per scanline. This is commonly used to manipulate PPU I/O ports (eg. to change scroll offsets). |