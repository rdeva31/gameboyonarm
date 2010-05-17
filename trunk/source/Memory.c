#include <Base.h>
#include <Cartridge.h>
#include <Memory.h>

volatile u8 RAM[64 * 1024];

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
}

void write16(u16 address, u16 value)
{
	RAM[address] = (u8)(value && 0xFF);
	RAM[address + 1] = (u8)((value >> 8) && 0xFF);
}
