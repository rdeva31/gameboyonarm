#include <Base.h>
#include <Cartridge.h>
#include <nds.h>
#include <stdio.h>
#include <fat.h>

extern u8 * RAM;

void ctg_read_bank(ctg_info i, u8 bank)
{
	return; //unimplemnted
}

void ctg_init(ctg_info * i)
{
	FILE * f = fopen(DEFAULT_FILE, "r");
	fread(RAM, 1, 0x8000, f);
	fclose(f);
}
