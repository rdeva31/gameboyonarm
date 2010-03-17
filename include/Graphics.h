#ifndef GRAPHICS_H
#define GRAPHICS_H

#include "Base.h"

/* References to specific registers can be found here: 
	http://nocash.emubase.de/gbatek.htm#dstechnicaldata
*/

// #defines pertaining to controlling the engines
#define DISPLAY_CONTROL_REG ((unsigned int *)0x4000000)	/* Register DISPCNT, controls the modes of each engine */
#define BITMAP_MODE (2<<16)	/* To be used to set DISPLAY_CONTROL_REG to a basic bitmap mode */
#define BITMAP_DATA_BLOCK (0<<18)	/* To be used iff BITMAP_MODE == 2<<16. This specifies, which block
										contains graphics.  The value of this can be between [0,4] */
							
// #defines pertaining to mapping the VRAM A bank to memory
#define VRAM_A_CONTROL_REG ((unsigned int *) 0x4000240) /* Register VRAMCNT_A, which specifies the logical mapping
															to physical mapping of VRAM_A bank. Bit map of VRAMCNT_A:
															0-2   VRAM MST              ;Bit2 not used by VRAM-A,B,H,I
															3-4   VRAM Offset (0-3)     ;Offset not used by VRAM-E,H,I
															5-6   Not used
															7     VRAM Enable (0=Disable, 1=Enable)
														*/
#define VRAM_A_MST 0	/* Choose memory range 0x6800000 to 0x681FFFF */
#define VRAM_A_OFFSET (0<<3)	/* since VRAM_MST_0 == 0, no need for offset */
#define VRAM_A_ENABLE 1 /* Well duh, we want it enabled so it shows stuff */
#define VRAM_A ((unsigned int *)0x0x06800000) /* Pointer to a segment of memory that is mapped to by VRAM_A_MST and VRAM_A_OFFSET */



//function prototypes... see Graphics.c for documentation
void gfx_draw(u8 bytes[]);
void gfx_init();

#endif
