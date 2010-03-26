#include <Base.h>
#include <Graphics.h>

//static void gfx_memcpy(void *, void *, int);
/*
	Draw appropriate image onto the screen. 
	Returns -1 if info == NULL or if any of the pointers inside info are NULL
	Returns <-1 if something I assumed didn't hold
	Returns 0 otherwise
*/
int gfx_draw(gfx_canvas_info * info)
{
	int counter;
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


	/*u8 redTile[64] = 
	{
		1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1
	};
	 
	//create a tile called greenTile
	u8 greenTile[64] = 
	{
		2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2
	};
	 
	swiCopy(redTile, TILE_DATA, 32);
	swiCopy(greenTile, ((char *)TILE_DATA) + 64, 32);
	for(counter = 0; counter < 32 * 32; counter++)
		TILE_MAP[counter] = counter & 1;
	return 0;
	*/
	//XXX: Since the specs are shitty as hell, the data below has been derived based on the examples seen
	//each entry in a given row of the the tile map is 16 bits.  This allows us to have 2^16 tiles.
	//from what i've seen each tile is 8x8 pixels, with each pixel using 1 byte to represent its color
	//the color is determined by indexing the byte into the palette map
	
	//copy the map.  Note that we can't use a straight up memcpy because the indexes in a gameboy map
	//is 1 byte long..whereas the index are 2 bytes long in the NDS
	for (counter = 0; counter < 32*32; ++counter)
	{
		u16 * nds_map_ptr = TILE_MAP;
		u8 * gb_map_ptr = info->tile_map;
		nds_map_ptr[counter] = (u16)gb_map_ptr[counter];
		//FIXME need to sign extend depending on tile_map_type
		//if (nds_map_ptr[counter] != 0)
		//printf(" %x:%d \n", &nds_map_ptr[counter], nds_map_ptr[counter]);
	}
	
	//copy the tiles.  The dimensions of the tiles are the same in the GB and the NDS
	//however, the sizes vary since the GB uses 2 bits per pixel since pallet size is 4
	//NDS uses 8 bits per pixel since palette size of 256
	//also GB stores the tile data in a strange way:
	//FTM: 
	//	Each Tile occupies 16 bytes, where each 2 bytes represent a line:
	//	Byte 0-1  First Line (Upper 8 pixels)
	//	Byte 2-3  Next Line
	//	etc.
	//e.g
	//Image:                                     Stored as:

	//.33333..						.33333.. -> 01111100 -> $7C }=>1 line = 2 bytes
	//22...22.									01111100 -> $7C }
	//11...11.						22...22. -> 00000000 -> $00 }=>1 line
	//2222222. <-- digits						11000110 -> $C6 }
	//33...33.     represent		11...11. -> 11000110 -> $C6
	//22...22.     color						00000000 -> $00
	//11...11.     numbers			2222222. -> 00000000 -> $00
	//........									11111110 -> $FE
	//								33...33. -> 11000110 -> $C6
	//											11000110 -> $C6
	//								22...22. -> 00000000 -> $00
	//											11000110 -> $C6
	//								11...11. -> 11000110 -> $C6
	//											00000000 -> $00
	//								........ -> 00000000 -> $00
	//											00000000 -> $00
	//TODO optimise this
	
	for (counter = 0; counter < 192; ++counter) //each bank of the GB holds 192 tiles, and only
												//one bank is active at any time
	{
		const int num_lines = 8; //8 lines in a 8x8 tile
		int temp_counter = 0;
		u8 * gb_tile = (u8 *)&(info->tile_data_table[counter * 8]);
		u8 ds_tile[8][8] = {0};
		
		//convert the tile from gameboy format to ds format
		int row = 0, col = 0;
		for (row = 0; row < num_lines;++row)
		{
			u16 curr_line = ((u16 *)gb_tile)[row];
			
			for (col = 0; col < num_lines; ++col)
			{
				u16 mask = 0x101;
				switch ((curr_line >> (8 - col - 1)) & mask)
				{
					case 0x101:
						ds_tile[row][col] = 3; //COLOR_3
						break;
					case 0x001:
						ds_tile[row][col] = 2; //COLOR_2
						break;
					case 0x100:
						ds_tile[row][col] = 1; //COLOR_1
						break;
					case 0x000:
						ds_tile[row][col] = 0; //COLOR_0
						break;
					default:
						return -2;
				}
				
			}
			
		}
		
		//now the tile is in ds_tile, write that into memory
		swiCopy(ds_tile, &(TILE_DATA[counter]), 64);
		
	}
	
	
	
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
	*DISPLAY_CONTROL_REG |= BACKGROUND_MODE_2D; 
	*DISPLAY_CONTROL_REG |= BG0_ENABLE;	
	
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


