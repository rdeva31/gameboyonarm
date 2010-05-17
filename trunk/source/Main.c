#include <Base.h>
#include <Cartridge.h>
#include <Graphics.h>
#include <Memory.h>
#include <stdio.h>

extern void executeFrame(); //TODO: Put this in a processor.h later

extern volatile u8 RAM[64 * 1024];
extern volatile u32 ProcessorState[8];

int main()
{
	consoleDemoInit();
	
	printf("Gameboy on ARM Emulator\n");

	ctg_init(NULL);

	printf("Cartridge Initialized...\n");

	gfx_init();

	printf("Graphics Initialized...\n");
	
	while(1)
	{
		executeFrame();
	
		//printf("Registers:\n");
		//printf("\tAF = 0x%04X\n", ProcessorState[0] & 0xFFFF);
		//printf("\tBC = 0x%04X\n", (ProcessorState[0] >> 16) & 0xFFFF);
		//printf("\tDE = 0x%04X\n", (ProcessorState[1] >> 16) & 0xFFFF);
		//printf("\tHL = 0x%04X\n", ProcessorState[1] & 0xFFFF);
		//printf("\tSP = 0x%04X\n", ProcessorState[2]);
		//printf("\tPC = 0x%04X\n", ProcessorState[3]);
		
		gfx_canvas_info i;
		gfx_setup(&i);
		gfx_draw(&i);
	}

	return 0;
}
