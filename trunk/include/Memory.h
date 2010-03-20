#ifndef MEMORY_H
#define MEMORY_H

#include <Base.h>

//Reads
u8 read8(u16 address);
u16 read16(u16 address);

//Writes
void write8(u16 address, u8 value);
void write8Fast(u16 address, u8 value);
void write16(u16 address, u16 value);

#endif
