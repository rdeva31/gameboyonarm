#include <Base.h>
#include <Cartridge.h>
#include <Memory.h>

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