#include "Base.h"

#include "Graphics.h"
void gfx_draw()
{
	int i;
	
	for(i=0; i < 20057; ++i)
		VRAM_A[i] = i & 0xff;
}

/*
	Initalizes the screen by setting the top and bottom screens to appropriate modes.
	Call this before invoking other gfx_* functions.
	
	This might interfere with other procedures that utilize the screen.
*/
void gfx_init()
{

	//set up the display
	*DISPLAY_CONTROL_REG = (*DISPLAY_CONTROL_REG & ~(3<<16)) | BITMAP_MODE; //sets the mode of Engine A to bitmap mode
																			//, which is controlled by bits 16 and 17
	*DISPLAY_CONTROL_REG = (*DISPLAY_CONTROL_REG & ~(3<<18)) | BITMAP_DATA_BLOCK;	//in bitmap_mode 2 we can specify which block
																					//to read data from, which is bits 18 and 19
	
	//map VRAM A to a specific physical memory
	*VRAM_A_CONTROL_REG = VRAM_A_ENABLE | VRAM_A_OFFSET | VRAM_A_MST;																		
}
