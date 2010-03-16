@-------------------------------------------------------------------------------
@ External Variables
@-------------------------------------------------------------------------------

	.extern RAM


@@@@@@@@@@@@@
	.text
@@@@@@@@@@@@@

@-------------------------------------------------------------------------------
@ void executeFrame (void)
	.align  2
	.code   32
	.global executeFrame
@-------------------------------------------------------------------------------
@ r0 = A,F,B,C State Registers
@ r1 = D,E,H,L State Registers
@ r2 = SP State Register
@ r3 = PC State Register
@ r4 = Frame Cycle Count
@ r5 = RAM Address
@ r6 = Holds the current instruction
@-------------------------------------------------------------------------------
executeFrame:

	push {r4,r5,r6,r7,r8,r9}		@ Saving registers for calling function

	ldr r7, =State
	ldr r0, [r7]					@ Loading A,F,B,C into r0
	ldr r1, [r7, #4]				@ Loading D,E,H,L into r1
	ldr r2, [r7, #8]				@ Loading SP into r2
	ldr r3, [r7, #12]				@ Loading PC into r3
	ldr r4, [r7, #16]				@ Loading frame cycle count

	ldr r5, =RAM					@ Initializing r5 to the RAM address

.next:
	ldrb r6, [r5, r3]				@ Loading the next instruction opcode
	add r3, r3, #1					@ Incrementing PC by 1

	ldr r7, =OpcodeJT				@ Loading opcode jump table address
	ldr r7, [r7, r6]				@ Loading opcode handler function address

	push {lr}
	adr lr, .opReturn				@ Loading link register with the return address
	bx r7							@ Branching to the opcode handler function
.opReturn:
	pop {lr}

	ldr r7, =70221

	
	pop	{r4,r5,r6,r7,r8,r9}			@ Restoring registers for calling function

	bx lr


@@@@@@@@@@@@@
	.data
@@@@@@@@@@@@@

@-------------------------------------------------------------------------------
@ Gameboy Processor State
@-------------------------------------------------------------------------------
State:

    .word 0x00000000	@ A,F,B,C
    .word 0x00000000	@ D,E,H,L
    .word 0x00000000	@ SP
    .word 0x00000000	@ PC
    .word 0x00000000	@ Frame cycle count (overflow from last frame)

@-------------------------------------------------------------------------------
@ Opcode Function Jump Table
@-------------------------------------------------------------------------------
OpcodeJT:

    .word executeFrame

@-------------------------------------------------------------------------------
@ CB Opcode Function Jump Table
@-------------------------------------------------------------------------------
CBOpcodeJT:

    .word executeFrame
