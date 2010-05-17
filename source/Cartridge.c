#include <Base.h>
#include <Cartridge.h>
#include <nds.h>
#include <stdio.h>
#include <fat.h>

extern volatile u8 RAM[64 * 1024];

void ctg_read_bank(ctg_info i, u8 bank)
{
	return; //unimplemnted
}

void ctg_init(ctg_info * i)
{
	//fatInit(2, FALSE);
	fatInitDefault();

	FILE * f = fopen("fat1:/Emulator/TETRIS.GB", "r");

	int bytesRead = fread(&(RAM[0]), 1, 0x8000, f);

	printf("Read %d bytes from TETRIS.GB\n", bytesRead);

	fclose(f);
}
