#include "Base.h"

#include "Cartridge.h"
#include "Graphics.h"
#include "Memory.h"

extern void executeFrame(); //TODO: Put this in a processor.h later

int main()
{
	consoleDemoInit();
 
	printf("Gameboy on ARM Emulator\n");

	executeFrame();
	
	gfx_init();
	gfx_draw();
	return 0;
}
