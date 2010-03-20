#include <Base.h>
#include <Graphics.h>

static void gfx_memcpy(void *, void *, int);
/*
	Draw appropriate image onto the screen. 
	Returns -1 if 
*/
int gfx_draw(gfx_canvas_info * info)
{
	if (!info)
		return -1; //nothing to do
	
	if (info->background_enabled) //FIXME: background should become while if bg_enable == 0
		//*VRAM_A_CONTROL_REG |= VRAM_A_ENABLE;
		*DISPLAY_CONTROL_REG |= BG0_ENABLE;		//not sure which one these is the correct/better way
	else
		//*VRAM_A_CONTROL_REG &= ~VRAM_A_ENABLE;
		*DISPLAY_CONTROL_REG &= ~BG0_ENABLE;
	
	*BG0_OFFSET_X_REG = info->scroll_x;
	*BG0_OFFSET_Y_REG = info->scroll_y;
	
	//XXX: Since the specs are shitty as hell, the data below has been derived based on the examples seen
	//each entry in a given row of the the tile map is 16 bits.  This allows us to have 2^16 tiles.
	//from what i've seen each tile is 8x8 pixels, with each pixel using 1 byte to represent its color
	//the color is determined by indexing the byte into the palette map
	gfx_memcpy(info->tile_map, TILE_MAP, 32*32*16); //32 tiles across and down by 16 bytes per tile
	gfx_memcpy(info->tile_data_table, TILE_DATA, 0x1000); // the tile data in GB is 4kb long
	
	//TODO what the fuck do I do about the window
	//TODO shit with sprites
	
	
	return 0;
}

/*
	Initalizes the screen by setting the top and bottom screens to appropriate modes.
	Call this before invoking other gfx_* functions.
	
	This might interfere with other procedures that utilize the screen.
*/
void gfx_init()
{

	//set up the display
	*DISPLAY_CONTROL_REG |= BACKGROUND_MODE_2D; //sets the mode of Engine A to bitmap mode
												//, which is controlled by bits 16 and 17
	*DISPLAY_CONTROL_REG |= BG0_ENABLE;	//in bitmap_mode 2 we can specify which block
										//to read data from, which is bits 18 and 19
	
	//map VRAM A to a specific physical memory
	*VRAM_A_CONTROL_REG = VRAM_A_ENABLE | VRAM_A_OFFSET | VRAM_A_MST;	
	
	//set up background 0 control register
	*BG0_CONTROL_REG = BG0_PRIORITY | BG0_CHAR_BASE_BLOCK | BG0_MOSAIC | BG0_COLORS_PALETTES | BG0_SCREEN_BASE_BLOCK | BG0_DISPLAY_OVERFLOW | BG0_SCREEN_SIZE;
	
	//set up the pallete with 4 colours
	PALETTE_MAP[0] = COLOR_0;
	PALETTE_MAP[1] = COLOR_1; 
	PALETTE_MAP[2] = COLOR_2;
	PALETTE_MAP[3] = COLOR_3;
}


/*
	 Copies n bytes from the object pointed to by a into the object pointed to by b. If copying takes place between objects that overlap, the behaviour is undefined.
*/
static void gfx_memcpy(void * a, void * b, int n)
{
	while (n --> 0)
    	*(char *)b++ = *(char *)a++;
}
