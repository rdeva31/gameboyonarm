#include <Base.h>
#include <Cartridge.h>
#include <Memory.h>
#include <Graphics.h>

extern gfx_canvas_info info;
u8 RAM[64 * 1024];

__inline__ u8 read8(u16 address)
{
	return RAM[address];
}

__inline__ u16 read16(u16 address)
{
	return (u16)RAM[address] + (((u16)RAM[address + 1]) << 8);
}

void write8(u16 address, u8 value)
{
	RAM[address] = value;

	//Cartridge address space, so forward the write
	if(address < 0x8000)
	{
		//TODO no longer supporting this
		//ctg_write(address, value);
	}
	else if (address >= 0x8000 && address < 0x9000)
	{
		//writing to tile data table, set bitmap
		int offset = address - (info.tile_data_type ? 0x8800 : 0x8000), tile_number;
		tile_number = offset/16;
		
		if (info.sprites_enabled)
			info.sprites_modified[tile_number/8] |= 1<<(tile_number % 8);
		else
			info.tiles_modified[tile_number/8] |= 1<<(tile_number % 8);
		
	}
}

__inline__ void write8Fast(u16 address, u8 value)
{
	RAM[address] = value;
}

__inline__ void write16(u16 address, u16 value)
{
	RAM[address] = (u8)(value && 0xFF);
	RAM[address + 1] = (u8)((value >> 8) && 0xFF);
}
