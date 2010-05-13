#include <Base.h>
#include <Graphics.h>
#include "nds.h"

extern u8 * RAM;

static int is_set(u8 * array, int index) 
{
	int offset = index & 7; //same as % 8
	index = index / 8;
	
	return array[index] & (1 << offset);
}


static int convert_tile_gb_to_nds(u8 * gb_tile, u8 ds_tile[8][8])
{
	const int num_lines = 8; //8 lines in a 8x8 tile
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
	
	return 0;
}
//static void gfx_memcpy(void *, void *, int);
/*
	Draw appropriate image onto the screen. 
	Returns -1 if info == NULL or if any of the pointers inside info are NULL
	Returns <-1 if something I assumed didn't hold
	Returns 0 otherwise
*/
int gfx_draw(gfx_canvas_info * info)
{
	long counter;
	if (!info)
		return -1; //nothing to do
	
	if (info->background_enabled) //FIXME: background should become white if bg_enable == 0
		//*VRAM_A_CONTROL_REG |= VRAM_A_ENABLE;
		*DISPLAY_CONTROL_REG |= BG0_ENABLE;		//not sure which one these is the correct/better way
	else
		//*VRAM_A_CONTROL_REG &= ~VRAM_A_ENABLE;
		*DISPLAY_CONTROL_REG &= ~BG0_ENABLE;
	
	*BG0_OFFSET_X_REG = info->scroll_x;
	*BG0_OFFSET_Y_REG = info->scroll_y;


	
	/*for(counter = 0; counter < 32 * 32; counter++)
		TILE_MAP[counter] = counter & 1;
	return 0;
	*/
	//XXX: Since the specs are shitty as hell, the data below has been derived based on the examples seen
	//each entry in a given row of the the tile map is 16 bits.  This allows us to have 2^16 tiles.
	//from what i've seen each tile is 8x8 pixels, with each pixel using 1 byte to represent its color
	//the color is determined by indexing the byte into the palette map
	
	//copy the map.  Note that we can't use a straight up memcpy because the indexes in a gameboy map
	//is 1 byte long..whereas the index are 2 bytes long in the NDS
	
	//TODO: it might be better to write to RAM then DMA copy to map memory
	for (counter = 0; counter < 32*32; ++counter)
	{
		u16 * nds_map_ptr = TILE_MAP;
		u8 * gb_map_ptr = info->tile_map;
		
		if (info->tile_map_type) //values are sign extended, so add an offset to normalize them
			nds_map_ptr[counter] = (u16)((s16)gb_map_ptr[counter] + 128);
		else //don't bother normalizing
			nds_map_ptr[counter] = (u16)gb_map_ptr[counter];
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
	
	for (counter = 0; counter < NUM_TILES && is_set(info->tiles_modified, counter); ++counter) 
	{
		u8 * gb_tile = (u8 *)&(info->tile_data_table[counter * 8]);
		u8 ds_tile[8][8] = {{0}};
		//convert the tile from gameboy format to ds format
		convert_tile_gb_to_nds(gb_tile, (u8 *)ds_tile);
		
		//now the tile is in ds_tile, write that into memory
		DC_FlushRange(ds_tile, 64);
		dmaCopy(ds_tile, &(TILE_DATA[counter]), 64);
		
	}
	
	/*
	//for testing	
	u8 redTile[64] = 
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
	*/
	
	//deal with the window layer
	
	//enable window?
	if (info->window_enabled)
		*DISPLAY_CONTROL_REG |= WINDOW0_ENABLE;
	else
		*DISPLAY_CONTROL_REG &= ~WINDOW0_ENABLE;
	
	//deal with setting window coordinates

	//layout of WINDOW0_X:
	// Bit   Expl.
	// 0-7   X2, Rightmost coordinate of window, plus 1
  	// 8-15  X1, Leftmost coordinate of window

	*WINDOW0_X = (((u16)info->window_x)<<8) | (160+1); // 160 since it's the length of GB screen
	*WINDOW0_Y = (((u16)info->window_y - 7)<<8) | (144+1); // 144 since it's the height of GB screen
	
	//FIXME:  major bug here.  Based on NDS's set up, the window is mapped to a tile map of its own, but the 
	//GB specs make no mention of this.  In fact it doesn't even talk about the window that much.  So leaving this part 
	//mostly unimplemented
	
	
	
	
	//deal with sprites
/*	if (info->sprites_enabled)*/
/*		*DISPLAY_CONTROL_REG |= SPRITES_ENABLE;*/
/*	else*/
/*		*DISPLAY_CONTROL_REG &= ~SPRITES_ENABLE;*/
	
	vramSetBankB(VRAM_A_MAIN_SPRITE);
	oamInit(&oamMain, SpriteMapping_1D_32, false);
	
	u8 * gfx;
	if (info->sprite_mode)
		gfx = oamAllocateGfx(&oamMain, SpriteSize_8x16, SpriteColorFormat_256Color);
	else
		gfx = oamAllocateGfx(&oamMain, SpriteSize_8x8, SpriteColorFormat_256Color);

	//setup the pallete
	SPRITE_PALETTE[0] = COLOR_0;
	SPRITE_PALETTE[1] = COLOR_1;
	SPRITE_PALETTE[2] = COLOR_2;
	SPRITE_PALETTE[3] = COLOR_3;
	
	//copy the character maps
	for (counter = 0; counter < NUM_TILES; ++counter) 
	{
		u8 * gb_tile = (u8 *)&(info->sprite_pattern_table[counter * 8]);
		u8 ds_tile[8][8] = {{0}};
		
		//convert the tile from gameboy format to ds format
		convert_tile_gb_to_nds(gb_tile, (u8 *)ds_tile);
		
		//now the tile is in ds_tile, write that into memory
		DC_FlushRange(ds_tile, 64);
		dmaCopy(ds_tile, &(gfx[counter * 64]), 64);
		
	}
	

	
	//copy contents of OAM
	for (counter = 0; counter < NUM_SPRITES && is_set(info->sprites_modified, counter); ++counter) //40 is the number of max sprites in GB
	{
		/*
			Layout of OAM in GB:
			
			Byte0 - Y Position
			Specifies the sprites vertical position on the screen (minus 16).
			An offscreen value (for example, Y=0 or Y>=160) hides the sprite.

			Byte1 - X Position
			Specifies the sprites horizontal position on the screen (minus 8).
			An offscreen value (X=0 or X>=168) hides the sprite, but the sprite
			still affects the priority ordering - a better way to hide a sprite is to set its Y-coordinate offscreen.

			Byte2 - Tile/Pattern Number
			Specifies the sprites Tile Number (00-FF). This (unsigned) value selects a tile from memory at 8000h-8FFFh. In CGB Mode this could be either in VRAM Bank 0 or 1, depending on Bit 3 of the following byte.
			In 8x16 mode, the lower bit of the tile number is ignored. Ie. the upper 8x8 tile is "NN AND FEh", and the lower 8x8 tile is "NN OR 01h".

			Byte3 - Attributes/Flags:
			  Bit7   OBJ-to-BG Priority (0=OBJ Above BG, 1=OBJ Behind BG color 1-3)
					 (Used for both BG and Window. BG color 0 is always behind OBJ)
			  Bit6   Y flip          (0=Normal, 1=Vertically mirrored)
			  Bit5   X flip          (0=Normal, 1=Horizontally mirrored)
			  Bit4   Palette number  **Non CGB Mode Only** (0=OBP0, 1=OBP1) => not used in GB
			  Bit3   Tile VRAM-Bank  **CGB Mode Only**     (0=Bank 0, 1=Bank 1) => not used in GB
			  Bit2-0 Palette number  **CGB Mode Only**     (OBP0-7) => not used in GB
		*/
		u32 attribute = info->oam[counter];
		u8 y_pos = attribute & 0xff;
		u8 x_pos = (attribute>>8) & 0xff;
		u8 tile_index = (attribute>>16) & 0xff;
		u8 priority = (attribute>>24) & 0x80;
		u8 y_flip = (attribute>>24) & 0x40;
		u8 x_flip = (attribute>>24) & 0x20;
			
		
		oamSet(&oamMain, //main graphics engine context
			counter,           //oam index (0 to 127)  
			x_pos, y_pos,   //x and y pixle location of the sprite
			priority,                    //priority, lower renders last (on top)
			0,					  //this is the palette index if multiple palettes or the alpha value if bmp sprite	
			info->sprite_mode ? SpriteSize_8x16 : SpriteSize_8x8,     
			SpriteColorFormat_256Color, 
			gfx + tile_index * 64,                  //pointer to the loaded graphics
			-1,                  //sprite rotation data  
			false,               //double the size when rotating?
			(y_pos > 160 && x_pos > 168) ? true : false,			//hide the sprite?
			y_flip ? true : false, x_flip ? true : false, //vflip, hflip
			false	//apply mosaic
			);
		
		/*
		SHIT COMMENTED OUT BECAUSE DUE DATE IS NEAR AND SHIT ISN'T WORKING, so using library routines instead
		u16 * oam = (u16 *)&(OAM[nds_oam_index]);	//TODO: investigate this later:
													//1. When using the 256 Colors/1 Palette mode, 
													//only each second tile may be used, the lower 
													//bit of the tile number should be zero [##taken care of ##]
													//(in 2-dimensional 
													//mapping mode, the bit is completely ignored).
		u16 * obj_attribute_0 = &oam[0];
		u16 * obj_attribute_1 = &oam[1];
		u16 * obj_attribute_2 = &oam[2];
		
		//begin setting obj_attribute_0
		*obj_attribute_0 = (u16)y_pos;
		*obj_attribute_0 &= ~(1<<8);	//turns off scaling and rotation
		*obj_attribute_0 &= ~(1<<9);	//displays the sprite.  Note that GB doesn't have this flag
										//in it's OAM.  To hide a sprite, need to set the x and y
										//values to something obscenely large so it's "displayed"
										//off the screen
		*obj_attribute_0 &= ~(3<<10);	//sets the OBJ mode to normal, as opposed to transparent or some other crap
		*obj_attribute_0 &= ~(1<<12);	//turns of mosaic mode
		*obj_attribute_0 |= (1<<13);	//sets the color/pallete to 256/1
		if (info->sprite_mode)	//8x16 sprite mode
			*obj_attribute_0 |= (2<<14);	//sets the sprite to vertical mode which supports 8x16 tiles
		else	//8x8 sprite mode
			*obj_attribute_0 &= ~(3<<14);	//sets the spirte to square mode which supports 8x8 tiles
			
		
		//begin setting obj_attribute_1
		*obj_attribute_1 = (u16)x_pos;

		if (x_flip)	//if need to horizontal flip //TODO check if this should be vertical or horizontal
			*obj_attribute_1 |= (1<<12);
		else
			*obj_attribute_1 &= ~(1<<12);
			
		if (y_flip)	//if need to vertical flip
			*obj_attribute_1 |= (1<<13);
		else
			*obj_attribute_1 &= ~(1<<13);

		*obj_attribute_1 &= ~(3<<14);	//sets the sprite to 8x8 mode or 8x16 mode depending on corresponding
										//flags in obj_attribute_0			
		
		
		//begin setting obj_attribute_2
		*obj_attribute_2 = info->sprite_mode ? tile_index & ~1 : tile_index; //in 8x16 mode the lower bit must be 0
		if (priority)	//set the priority low if priority variable is high
			*obj_attribute_2 |= (3<<10);	//3 is low priority
		else
			*obj_attribute_2 &= ~(3<<10);	//0 is high priority
			*/
			
	}
	oamUpdate(&oamMain);
	
	
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


/*
	Setups up info such that it can be used in calling gfx_draw()
	Only some fields are setup.  The following fields are not setup properly:
		- num_tiles [if in doubt, initialize this to 192]
	Returns a value < 0 on error
*/
int gfx_setup(gfx_canvas_info * info)
{
	if (!info)
		return -1;
	
	info->background_enabled = 1; //TODO find out what part of memory to read to find this
	info->scroll_x = RAM[0xff42];
	info->scroll_y = RAM[0xff43];
	
	u8 lcdc = RAM[0xff40];
	info->tile_map_type = (lcdc & 8) ? 1 : 0;
	info->tile_map = (info->tile_map_type) ? &RAM[0x9c00] : &RAM[0x9800];
	info->tile_data_type = (lcdc & 16) ? 0 : 1;
	info->tile_data_table = (u16 *)((info->tile_data_type) ? &RAM[0x8800] : &RAM[0x8000]);

	
	info->window_x = RAM[0xff4b];
	info->window_y = RAM[0xff4a];
	info->window_enabled = (lcdc & 0x10) ? 1 : 0;
	
	
	info->sprites_enabled = (lcdc & 0x20) ? 1 : 0;
	info->oam = (u32 *)&RAM[0xfe00];
	info->sprite_mode = (lcdc & 4) ? 1 : 0;
	info->sprite_pattern_table = &RAM[0x8000];
	
	return 0;
}
