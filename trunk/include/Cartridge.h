#ifndef CARTRIDGE_H
#define CARTRIDGE_H

#include <Base.h>

typedef struct
{
	u8 type;
	u8 rom_size;
	u8 ram_size;
} ctg_info;


#define DEFAULT_FILE "/TETRIS.GB"

void ctg_read_bank(ctg_info, u8);
void ctg_init(ctg_info *);

#endif
