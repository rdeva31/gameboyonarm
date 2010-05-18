#include <Base.h>
#include <Cartridge.h>
#include <Graphics.h>
#include <Memory.h>
#include <stdio.h>

extern void executeFrame();
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
	
	//Initializing special registers in RAM
	RAM[0xFF05] = 0x00;
	RAM[0xFF06] = 0x00;
	RAM[0xFF07] = 0x00;
	RAM[0xFF40] = 0x91;
	RAM[0xFF42] = 0x00;
	RAM[0xFF43] = 0x00;
	RAM[0xFF45] = 0x00;
	RAM[0xFF47] = 0xFC;
	RAM[0xFFF8] = 0xFF;
	RAM[0xFFF9] = 0xFF;
	RAM[0xFFFA] = 0x00;
	RAM[0xFF4B] = 0x00;
	RAM[0xFFFF] = 0x00;

	while(1)
	{
		executeFrame();
	
		/*
		printf("Registers:\n");
		printf("\tAF = 0x%04X\n", ProcessorState[0] & 0xFFFF);
		printf("\tBC = 0x%04X\n", (ProcessorState[0] >> 16) & 0xFFFF);
		printf("\tDE = 0x%04X\n", (ProcessorState[1] >> 16) & 0xFFFF);
		printf("\tHL = 0x%04X\n", ProcessorState[1] & 0xFFFF);
		printf("\tSP = 0x%04X\n", ProcessorState[2]);
		printf("\tPC = 0x%04X\n", ProcessorState[3]);
		*/
		
		gfx_canvas_info i;
		gfx_setup(&i);
		gfx_draw(&i);
	}

	return 0;
}
