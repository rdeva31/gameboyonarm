@-------------------------------------------------------------------------------
@ External Variables
@-------------------------------------------------------------------------------

	.extern RAM


@@@@@@@@@@@@@
	.text
	.align 2
	.code 32
@@@@@@@@@@@@@

@-------------------------------------------------------------------------------
@ void executeFrame (void)
@-------------------------------------------------------------------------------
@ r0 = A,F,B,C State Registers
@ r1 = D,E,H,L State Registers
@ r2 = SP State Register
@ r3 = PC State Register
@ r4 = Frame Cycle Count
@ r5 = RAM Address
@-------------------------------------------------------------------------------
executeFrame:
	.global executeFrame

	push {r4,r5,r6,r7,r8,r9,lr}		@ Saving registers for calling function

	ldr r7, =State
	ldr r0, [r7]					@ Loading A,F,B,C
	ldr r1, [r7, #4]				@ Loading D,E,H,L
	ldr r2, [r7, #8]				@ Loading SP
	ldr r3, [r7, #12]				@ Loading PC
	ldr r4, [r7, #16]				@ Loading frame cycle count

	ldr r5, =RAM					@ Initializing r5 to the RAM address

.next:

	ldrb r6, [r5, r3]				@ Loading the next instruction opcode
	add r3, r3, #1					@ Incrementing PC by 1

	ldr r7, =OpcodeJT				@ Loading opcode jump table address
	ldr r7, [r7, r6]				@ Loading opcode handler function address

	adr lr, .opReturn				@ Loading link register with the return address
	bx r7							@ Branching to the opcode handler function

.opReturn:

	ldr r7, =17555
	subs r6, r4, r7					@ Calculating leftover cycle count
	blo .next						@  and continue to next instruction if < max

.done:

	ldr r7, =State
	str r0, [r7]					@ Saving A,F,B,C
	str r1, [r7, #4]				@ Saving D,E,H,L
	str r2, [r7, #8]				@ Saving SP
	str r3, [r7, #12]				@ Saving PC
	str r6, [r7, #16]				@ Saving leftover cycle count

	pop	{r4,r5,r6,r7,r8,r9,lr}		@ Restoring registers for calling function

	bx lr

@-------------------------------------------------------------------------------
@ 00 -> NOP
@-------------------------------------------------------------------------------
op00:

	add r4, r4, #1					@ Update cycle count

	bx lr

@-------------------------------------------------------------------------------
@ 01 -> LD BC, 0xXXYY
@-------------------------------------------------------------------------------
op01:

	add r4, r4, #3					@ Update cycle count

	bx lr


@@@@@@@@@@@@@
	.data
@@@@@@@@@@@@@

@-------------------------------------------------------------------------------
@ Gameboy Processor State
@-------------------------------------------------------------------------------
State:
	.global State

    .word 0x00000000	@ A,F,B,C
    .word 0x00000000	@ D,E,H,L
    .word 0x00000000	@ SP
    .word 0x00000100	@ PC (initially set to 0x100)
    .word 0x00000000	@ Frame cycle count (overflow from last frame)

@-------------------------------------------------------------------------------
@ Opcode Function Jump Table
@-------------------------------------------------------------------------------
OpcodeJT:

    .word op00, op01, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00

@-------------------------------------------------------------------------------
@ CB Opcode Function Jump Table
@-------------------------------------------------------------------------------
CBOpcodeJT:

    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00
    .word op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00, op00