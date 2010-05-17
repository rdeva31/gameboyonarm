#include <Base.h>
#include <Cartridge.h>
#include <Graphics.h>
#include <Memory.h>
#include <stdio.h>
#include <nds.h>
extern void executeFrame(); //TODO: Put this in a processor.h later
extern u8 * RAM;
gfx_canvas_info info;

int main()
{
	ctg_init(NULL);
	gfx_init();
	gfx_setup(&info);
	//initialize some values in RAM
	RAM[0xFF05] = 0x00; // TIMA
	RAM[0xFF06] = 0x00; // TMA
	RAM[0xFF07] = 0x00; // TAC
	RAM[0xFF10] = 0x80; // NR10
	RAM[0xFF11] = 0xBF; // NR11
	RAM[0xFF12] = 0xF3; // NR12
	RAM[0xFF14] = 0xBF; // NR14
	RAM[0xFF16] = 0x3F; // NR21
	RAM[0xFF17] = 0x00; // NR22
	RAM[0xFF19] = 0xBF; // NR24
	RAM[0xFF1A] = 0x7F; // NR30
	RAM[0xFF1B] = 0xFF; // NR31
	RAM[0xFF1C] = 0x9F; // NR32
	RAM[0xFF1E] = 0xBF; // NR33
	RAM[0xFF20] = 0xFF; // NR41
	RAM[0xFF21] = 0x00; // NR42
	RAM[0xFF22] = 0x00; // NR43
	RAM[0xFF23] = 0xBF; // NR30
	RAM[0xFF24] = 0x77; // NR50
	RAM[0xFF25] = 0xF3; // NR51
	RAM[0xFF26] = 0xF1; // Sound
	RAM[0xFF40] = 0x91; // LCDC
	RAM[0xFF42] = 0x00; // SCY
	RAM[0xFF43] = 0x00; // SCX
	RAM[0xFF45] = 0x00; // LYC
	RAM[0xFF47] = 0xFC; // BGP
	RAM[0xFF48] = 0xFF; // OBP0
	RAM[0xFF49] = 0xFF; // OBP1
	RAM[0xFF4A] = 0x00; // WY
	RAM[0xFF4B] = 0x00; // WX
	
	while(true)
	{
		executeFrame();
		gfx_setup(&info);
		gfx_draw(&info);
	}
}


/*int main()*/
/*{*/

/*	u8 tile_1[16] =*/
/*					{*/
/*						0xff, 0xff,*/
/*						0x01, 0x01,*/
/*						0x01, 0xff,*/
/*						0xff, 0xf1,*/
/*						0xf1, 0xff,*/
/*						0x01, 0xff,*/
/*						0xff, 0x01,*/
/*						0xff, 0xff,*/
/*					};*/

/*	u8 tile_2[16] =  */
/*					{*/
/*						0xff, 0xff,*/
/*						0xff, 0xff,*/
/*						0xff, 0xff,*/
/*						0xff, 0xff,*/
/*						0xff, 0xff,*/
/*						0xff, 0xff,*/
/*						0xff, 0xff,*/
/*						0xff, 0xff*/
/*					};*/
/*					*/
/*	unsigned char tile_data[192*16] = {0};*/
/*	int counter;*/
/*	*/
/*	for (counter=0; counter < 16; ++counter)*/
/*		tile_data[counter] = tile_1[counter];*/
/*	for (counter = 0; counter < 16; ++counter)*/
/*		tile_data[16+counter] = tile_2[counter];*/

/*	u8 map[32*32] = {*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,1,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,0,0,0,0,*/
/*						0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,1,0,0,0,0,1,1,1,0,0,1,1,1,1,1,0,0,0,1,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,1,0,0,0,0,1,1,1,1,0,1,1,1,1,1,0,0,0,1,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,*/
/*					};*/
/*					*/
/*					*/
/*	//set up oam*/
/*	u32 oam_entry = 32 | 32<<8 | 0<<16 | 0;*/
/*					*/
/*	gfx_canvas_info i = {0};*/
/*	i.background_enabled  = 1;*/
/*	i.scroll_x = i.scroll_y = 0;*/
/*	i.tile_map = map;*/
/*	i.tile_data_table = tile_data;*/
/*	//i.tiles_modified[0] = 3;*/
/*	*/
/*	i.sprites_enabled = 1;*/
/*	i.oam = &oam_entry;*/
/*	i.sprite_mode = 0;*/
/*	i.sprites_modified[0] = 3;*/
/*	i.sprite_pattern_table = tile_data;*/

/*			*/
/*	consoleDemoInit();*/
/* */
/*	printf("Gameboy on ARM Emulator\n");*/

/*	//executeFrame();*/
/*	*/
/*	gfx_init();*/
/*	/*while(1)*/
/*	{*/
/*		static int flip_flop = 0;*/
/*		if (flip_flop)*/
/*			oam_entry = 32 | 32<<8 | 1<<16 | 0;*/
/*		else*/
/*			oam_entry = 32 | 32<<8 | 0<<16 | 0;*/
/*		flip_flop = ~flip_flop;*/
/*		*/
/*		gfx_draw(&i);*/
/*	}*/
/*	printf("draw returned %d\n",gfx_draw(&i));*/
/*	return 0;*/
/*}*/#include <nds.h>
/* 
int main() {
	// Setup the video modes.
	videoSetMode( MODE_0_2D );
	vramSetMainBanks(VRAM_A_MAIN_SPRITE,VRAM_B_LCD,VRAM_C_LCD,VRAM_D_LCD);
	 
	//setup sprites
	oamInit(&oamMain, SpriteMapping_Bmp_1D_128, false); //initialize the oam
	u16* gfx = oamAllocateGfx(&oamMain, SpriteSize_64x64,SpriteColorFormat_256Color);//make room for the sprite
	dmaCopy(spriteTiles,gfx, spriteTilesLen);//copy the sprite
	dmaCopy(spritePal, SPRITE_PALETTE, spritePalLen); //copy the sprites palette oamEnable(&oamMain);
	 
	while (1) //infinite loop
	{
		oamSet(&oamMain,0,64,32,0,0,SpriteSize_64x64,SpriteColorFormat_256Color,gfx,0,false,false,false,false,false);
		swiWaitForVBlank();
	}
	return 0;
}
 */
