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
@ Macro Definitions
@-------------------------------------------------------------------------------

.macro SET_A r
	bic r0, r0, r12, LSL #24
	orr r0, r0, \r, LSL #24
.endm

.macro SET_F r
	bic r0, r0, r12, LSL #16
	orr r0, r0, \r, LSL #16
.endm

.macro SET_B r
	bic r0, r0, r12, LSL #8
	orr r0, r0, \r, LSL #8
.endm

.macro SET_C r
	bic r0, r0, r12
	orr r0, r0, \r
.endm

.macro SET_D r
	bic r1, r1, r12, LSL #24
	orr r1, r1, \r, LSL #24
.endm

.macro SET_E r
	bic r1, r1, r12, LSL #16
	orr r1, r1, \r, LSL #16
.endm

.macro SET_H r
	bic r1, r1, r12, LSL #8
	orr r1, r1, \r, LSL #8
.endm

.macro SET_L r
	bic r1, r1, r12
	orr r1, r1, \r
.endm

.macro READ_A r
	mov \r, r0, LSR #24
.endm

.macro READ_F r
	mov \r, r0, LSR #16
	and \r, \r, #0xFF
.endm

.macro READ_B r
	mov \r, r0, LSR #8
	and \r, \r, #0xFF
.endm

.macro READ_C r
	and \r, r0, #0xFF
.endm

.macro READ_D r
	mov \r, r1, LSR #24
.endm

.macro READ_E r
	mov \r, r1, LSR #16
	and \r, \r, #0xFF
.endm

.macro READ_H r
	mov \r, r1, LSR #8
	and \r, \r, #0xFF
.endm

.macro READ_L r
	and \r, r1, #0xFF
.endm

.macro READ_BC r
	and \r, r0, r11
.endm

.macro READ_DE r
	mov \r, r1, LSR #16
.endm

.macro READ_HL r
	and \r, r1, r11
.endm

.macro READ_BYTE r, a
	ldrb \r, [r5, \a]
.endm

.macro READ_IMM8 r
	ldrb \r, [r5, r3]
	add r3, r3, #1
.endm

.macro UPDATE_CYCLE_COUNT c
	add r4, r4, #\c
.endm

@-------------------------------------------------------------------------------
@ void executeFrame (void)
@-------------------------------------------------------------------------------
@ r0  = A,F,B,C State Registers
@ r1  = D,E,H,L State Registers
@ r2  = SP State Register
@ r3  = PC State Register
@ r4  = Frame Cycle Count
@ r5  = RAM Address
@ r11 = Word mask (0xFFFF)
@ r12 = Byte mask (0xFF)
@-------------------------------------------------------------------------------
executeFrame:
	.global executeFrame

	push {r4,r5,r6,r7,r11,lr}		@ Saving registers for calling function

	ldr r7, =State
	ldr r0, [r7]					@ Loading A,F,B,C
	ldr r1, [r7, #4]				@ Loading D,E,H,L
	ldr r2, [r7, #8]				@ Loading SP
	ldr r3, [r7, #12]				@ Loading PC
	ldr r4, [r7, #16]				@ Loading frame cycle count

	ldr r5, =RAM					@ Initializing r5 to the RAM address

	ldr r11, =0xFFFF				@ Initializing r11 to 0xFFFF used for word masking
	mov r12, #0xFF					@ Initializing r12 to 0xFF used for byte masking

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

	pop	{r4,r5,r6,r7,r11,lr}		@ Restoring registers for calling function

	bx lr

@-------------------------------------------------------------------------------
@ __ -> Not Implemented
@-------------------------------------------------------------------------------
op__:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 00 -> NOP
@-------------------------------------------------------------------------------
op00:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 06 -> LD B, ##
@-------------------------------------------------------------------------------
op06:
	
	READ_IMM8 r6
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ 0E -> LD C, ##
@-------------------------------------------------------------------------------
op0E:
	
	READ_IMM8 r6
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ 16 -> LD D, ##
@-------------------------------------------------------------------------------
op16:
	
	READ_IMM8 r6
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ 1E -> LD E, ##
@-------------------------------------------------------------------------------
op1E:
	
	READ_IMM8 r6
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ 26 -> LD H, ##
@-------------------------------------------------------------------------------
op26:
	
	READ_IMM8 r6
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ 2E -> LD L, ##
@-------------------------------------------------------------------------------
op2E:

	READ_IMM8 r6
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ 7F -> LD A, A
@-------------------------------------------------------------------------------
op7F:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 78 -> LD A, B
@-------------------------------------------------------------------------------
op78:

	READ_B r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 79 -> LD A, C
@-------------------------------------------------------------------------------
op79:

	READ_C r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 7A -> LD A, D
@-------------------------------------------------------------------------------
op7A:

	READ_D r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 7B -> LD A, E
@-------------------------------------------------------------------------------
op7B:

	READ_E r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 7C -> LD A, H
@-------------------------------------------------------------------------------
op7C:

	READ_H r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 7D -> LD A, L
@-------------------------------------------------------------------------------
op7D:

	READ_L r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ 7E -> LD A, (HL)
@-------------------------------------------------------------------------------
op7E:

	READ_HL r7
	READ_BYTE r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
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
    .word 0x0000FFFE	@ SP
    .word 0x00000100	@ PC (initially set to 0x100)
    .word 0x00000000	@ Frame cycle count (overflow from last frame)

@-------------------------------------------------------------------------------
@ Opcode Function Jump Table
@-------------------------------------------------------------------------------
OpcodeJT:

    .word op00, op__, op__, op__, op__, op__, op06, op__, op__, op__, op__, op__, op__, op__, op0E, op__
    .word op__, op__, op__, op__, op__, op__, op16, op__, op__, op__, op__, op__, op__, op__, op1E, op__
    .word op__, op__, op__, op__, op__, op__, op26, op__, op__, op__, op__, op__, op__, op__, op2E, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op78, op79, op7A, op7B, op7C, op7D, op7E, op7F
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__

@-------------------------------------------------------------------------------
@ CB Opcode Function Jump Table
@-------------------------------------------------------------------------------
CBOpcodeJT:

    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__