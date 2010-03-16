#include "Base.h"

//#include "Cartridge.h"
#include "Memory.h"

u8 RAM[64 * 1024];

//TODO: Make this function inline
u8 read8(u16 address)
{
	return RAM[address];
}

u16 read16(u16 address)
{
	return (u16)RAM[address] + (((u16)RAM[address + 1]) << 8);
}

void write8(u16 address, u8 value)
{
	RAM[address] = value;

	//Cartridge address space, so forward the write
	if(address < 0x8000)
	{
		//cartridgeWrite(address, value);
	}
}

//TODO: Make this function inline
void write8Fast(u16 address, u8 value)
{
	RAM[address] = value;
}

//TODO: Can we make this a fast write, or would we ever need to do address checks?
void write16(u16 address, u16 value)
{

}
