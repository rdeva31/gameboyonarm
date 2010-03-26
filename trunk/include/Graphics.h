#ifndef GRAPHICS_H
#define GRAPHICS_H

#include <Base.h>
/* References to specific registers can be found here: 
	http://nocash.emubase.de/gbatek.htm#dstechnicaldata
*/

// #defines pertaining to controlling the engines
#define DISPLAY_CONTROL_REG ((unsigned int *)0x4000000)	/* Register DISPCNT, controls the modes of each engine */
#define BACKGROUND_MODE_2D (1<<16)	/* To be used to set DISPLAY_CONTROL_REG to set screen to normal 2d mode */

//#defines pertaining to controlling the background
#define BG0_ENABLE (1<<8)	/* This specifies, which background is active
								since the gameboy only has one background, we'll just use BG0
							*/
#define BG0_CONTROL_REG ((unsigned int *)0x4000008) 	/* Register BG0CNT controls the background */
#define BG0_PRIORITY 0 	/* 0 is the highest priority, since using only 1 bg, it doesn't matter */
#define BG0_CHAR_BASE_BLOCK (1<<2) 	/* Location of the background tile data...computed as 
									0x6000000+16kb*BG0_CHAR_BASE_BLOCK 
									*/
#define BG0_MOSAIC 0 	/* No idea wtf this does, but pretty sure we don't need it */
#define BG0_COLORS_PALETTES (1<<7) 	/*0 == 16 colours/16 palletes; 1 == 256 colors/1 pallete, since 
									gameboy uses only 4 colours, doesn't matter which we use 
									*/
#define BG0_SCREEN_BASE_BLOCK 0		/*Location of the background map data...computed as 
									0x6000000+2kb*BG0_SCREEN_BASE_BLOCK 
									
									We allow the map to be occupied by the first 2kb (gameboy needs only 1 kb).
									Then after a stretch of 14kb of free space, we allocate 16kb (gameboy needs only 4 kb)
									for the tile data
									*/
#define BG0_DISPLAY_OVERFLOW (1<<13)	/* This specifies what to do if scrollx and scrolly are too large.  Gameboy specifies
										That there should be a wrap around. Hence this is 1.  If truncate this should be 0
										*/
#define BG0_SCREEN_SIZE 0	/* Essentially the map size, 0 == 256x256, which is the gameboy map size. This assumes that
							the mode is normal--not scaled or rotation.
							*/
#define BG0_OFFSET_X_REG ((unsigned short *)0x4000010)	/* A register that controls the x coordinate of background 0*/
#define BG0_OFFSET_Y_REG ((unsigned short *)0x4000012)	/* A register that controls the y coordinate of background 0*/

// #defines specifying the location of the tile map and the tile data on the NDS
#define TILE_MAP ((u16 *)(0x6000000))
#define TILE_DATA ((u64 *)(0x6000000+0x4000))

// #defines pertaining to the colors in the palette
#define PALETTE_MAP ((unsigned int *)0x05000000)
#define COLOR_0 0x7FFF
#define COLOR_1 0x70FF
#define COLOR_2 0x700F
#define COLOR_3 0x0000

// #defines pertaining to mapping the VRAM A bank to memory
#define VRAM_A_CONTROL_REG ((unsigned short *) 0x4000240) /* Register VRAMCNT_A, which specifies the logical mapping
															to physical mapping of VRAM_A bank. Bit map of VRAMCNT_A:
															0-2   VRAM MST              ;Bit2 not used by VRAM-A,B,H,I
															3-4   VRAM Offset (0-3)     ;Offset not used by VRAM-E,H,I
															5-6   Not used
															7     VRAM Enable (0=Disable, 1=Enable)
														*/
#define VRAM_A_MST 1	/* Choose memory from 0x6000000 */
#define VRAM_A_OFFSET (0<<3)	/* since VRAM_MST_0 == 0, no need for offset */
#define VRAM_A_ENABLE (1<<7) /* Well duh, we want it enabled so it shows stuff */
#define VRAM_A ((unsigned int *)0x06800000) /* Pointer to a segment of memory that is mapped to by VRAM_A_MST and VRAM_A_OFFSET */


/* Gameboy documentation link (pg 21):
	"Gameboy CPU Manual" //FIXME: add link bitch
*/
typedef struct {
	/* data pertaining to the background */
	int background_enabled; //1 if background is enabled, 0 otherwise
	int scroll_x, scroll_y; //coordinates of background to be displayed 
							//in the left upper corner of the screen.
							//these should correspond to registers of the 
							//same name in the gameboy
	u8 * tile_map; //a pointer to an area of VRAM known as Background Tile Map (located at 0x9800 or 0x9C00)
	int tile_map_type; //should be 0, if tile_map = 0x9800, 1 if pointing at 0x9C00 
	
	u16 * tile_data_table; //aka tile pattern table; pointer to 0x8000 or 0x8800; see page 23 of gameboy documentation
	int tile_data_type; //should be 0 if tile_data_table = 0x8000, 1 if pointing to 0x8800
	int num_tiles; //Number of tiles being used.  0<=num_tiles<=192
	
	int window_x, window_y; //and x and y coordinates of the window respectively
	int window_enabled; //1 if window is enabled, 0 otherwise
	
	/* data pertaining to sprites */
	void * oam; //pointer to 0xfe00, which is 160 byte block of object attribute memory containing data
				//about each sprite (at most 40 sprites are allowed)
	int sprite_mode; //1 if sprite size is 8x16, 0 if 8x8
	
} gfx_canvas_info;
//function prototypes... see Graphics.c for documentation
int gfx_draw(gfx_canvas_info *);
void gfx_init();
#endif
