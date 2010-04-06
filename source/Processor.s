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
	bic r0, r0, r12, lsl #24
	orr r0, r0, \r, lsl #24
.endm

.macro SET_B r
	bic r0, r0, r12, lsl #16
	orr r0, r0, \r, lsl #16
.endm

.macro SET_C r
	bic r0, r0, r12, lsl #8
	orr r0, r0, \r, lsl #8
.endm

.macro SET_F r
	bic r0, r0, r12
	orr r0, r0, \r
.endm

.macro SET_FLAG_Z
	orr r0, r0, #0x80
.endm

.macro SET_FLAG_N
	orr r0, r0, #0x40
.endm

.macro SET_FLAG_H
	orr r0, r0, #0x20
.endm

.macro SET_FLAG_C
	orr r0, r0, #0x10
.endm

.macro RESET_FLAG_Z
	and r0, r0, #0x70
.endm

.macro RESET_FLAG_N
	and r0, r0, #0xB0
.endm

.macro RESET_FLAG_H
	and r0, r0, #0xD0
.endm

.macro RESET_FLAG_C
	and r0, r0, #0xE0
.endm

.macro SET_D r
	bic r1, r1, r12, lsl #24
	orr r1, r1, \r, lsl #24
.endm

.macro SET_E r
	bic r1, r1, r12, lsl #16
	orr r1, r1, \r, lsl #16
.endm

.macro SET_H r
	bic r1, r1, r12, lsl #8
	orr r1, r1, \r, lsl #8
.endm

.macro SET_L r
	bic r1, r1, r12
	orr r1, r1, \r
.endm

.macro SET_BC r
	bic r0, r0, r11
	orr r0, r0, \r
.endm

.macro SET_DE r
	bic r1, r1, r11, lsl #16
	orr r1, r1, \r, lsl #16
.endm

.macro SET_HL r
	bic r1, r1, r11
	orr r1, r1, \r
.endm

.macro SET_SP r
	mov r2, \r
.endm

.macro READ_A r
	mov \r, r0, lsr #24
.endm

.macro READ_F r
	mov \r, r0, lsr #16
	and \r, \r, #0xFF
.endm

.macro READ_B r
	mov \r, r0, lsr #8
	and \r, \r, #0xFF
.endm

.macro READ_C r
	and \r, r0, #0xFF
.endm

.macro READ_D r
	mov \r, r1, lsr #24
.endm

.macro READ_E r
	mov \r, r1, lsr #16
	and \r, \r, #0xFF
.endm

.macro READ_H r
	mov \r, r1, lsr #8
	and \r, \r, #0xFF
.endm

.macro READ_L r
	and \r, r1, #0xFF
.endm

.macro READ_BC r
	and \r, r0, r11
.endm

.macro READ_DE r
	mov \r, r1, lsr #16
.endm

.macro READ_HL r
	and \r, r1, r11
.endm

.macro READ_SP r
	mov \r, r2
.endm

.macro WRITE_8 r, a
	strb \r, [r5, \a]
.endm

.macro WRITE_16 r, a
	strb \r, [r5, \a]
	add \a, \a, #1
	lsr \r, \r, #8
	strb \r, [r5, \a]
.endm

.macro READ_8 r, a
	ldrb \r, [r5, \a]
.endm

.macro READ_16 r, a
	ldrb \r, [r5, \a]
	add \a, \a, #1
	ldrb \a, [r5, \a]
	eor \r, \r, \a, lsl #8
.endm

.macro READ_IMM8 r
	ldrb \r, [r5, r3]
	add r3, r3, #1
.endm

.macro READ_IMM16 r, t
	ldrb \r, [r5, r3]
	add r3, r3, #1
	ldrb \t, [r5, r3]
	add r3, r3, #1
	eor \r, \r, \t, lsl #8
.endm

.macro UPDATE_CYCLE_COUNT c
	add r4, r4, #\c
.endm

@-------------------------------------------------------------------------------
@ void executeFrame (void)
@-------------------------------------------------------------------------------
@ r0  = A,B,C,F State Registers
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

	push {r4,r5,r6,r7,r8,r11,lr}		@ Saving registers for calling function

	ldr r7, =State
	ldr r0, [r7]					@ Loading A,B,C,F
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

	pop	{r4,r5,r6,r7,r8,r11,lr}		@ Restoring registers for calling function

	bx lr

@-------------------------------------------------------------------------------
@ Not Implemented
@-------------------------------------------------------------------------------
op__:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ NOP
@-------------------------------------------------------------------------------
op00:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD B, ##
@-------------------------------------------------------------------------------
op06:
	
	READ_IMM8 r6
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD C, ##
@-------------------------------------------------------------------------------
op0E:
	
	READ_IMM8 r6
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD D, ##
@-------------------------------------------------------------------------------
op16:
	
	READ_IMM8 r6
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD E, ##
@-------------------------------------------------------------------------------
op1E:
	
	READ_IMM8 r6
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD H, ##
@-------------------------------------------------------------------------------
op26:
	
	READ_IMM8 r6
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD L, ##
@-------------------------------------------------------------------------------
op2E:

	READ_IMM8 r6
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD A, A
@-------------------------------------------------------------------------------
op7F:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD A, B
@-------------------------------------------------------------------------------
op78:

	READ_B r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD A, C
@-------------------------------------------------------------------------------
op79:

	READ_C r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD A, D
@-------------------------------------------------------------------------------
op7A:

	READ_D r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD A, E
@-------------------------------------------------------------------------------
op7B:

	READ_E r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD A, H
@-------------------------------------------------------------------------------
op7C:

	READ_H r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD A, L
@-------------------------------------------------------------------------------
op7D:

	READ_L r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (HL)
@-------------------------------------------------------------------------------
op7E:

	READ_HL r7
	READ_8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD B, B
@-------------------------------------------------------------------------------
op40:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD B, C
@-------------------------------------------------------------------------------
op41:

	READ_C r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD B, D
@-------------------------------------------------------------------------------
op42:

	READ_D r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD B, E
@-------------------------------------------------------------------------------
op43:

	READ_E r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD B, H
@-------------------------------------------------------------------------------
op44:

	READ_H r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD B, L
@-------------------------------------------------------------------------------
op45:

	READ_L r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD B, (HL)
@-------------------------------------------------------------------------------
op46:

	READ_HL r7
	READ_8 r6, r7
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD C, B
@-------------------------------------------------------------------------------
op48:

	READ_B r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD C, C
@-------------------------------------------------------------------------------
op49:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD C, D
@-------------------------------------------------------------------------------
op4A:

	READ_D r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD C, E
@-------------------------------------------------------------------------------
op4B:

	READ_E r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD C, H
@-------------------------------------------------------------------------------
op4C:

	READ_H r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD C, L
@-------------------------------------------------------------------------------
op4D:

	READ_L r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD C, (HL)
@-------------------------------------------------------------------------------
op4E:

	READ_HL r7
	READ_8 r6, r7
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD D, B
@-------------------------------------------------------------------------------
op50:

	READ_B r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD D, C
@-------------------------------------------------------------------------------
op51:

	READ_C r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD D, D
@-------------------------------------------------------------------------------
op52:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD D, E
@-------------------------------------------------------------------------------
op53:

	READ_E r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD D, H
@-------------------------------------------------------------------------------
op54:

	READ_H r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD D, L
@-------------------------------------------------------------------------------
op55:

	READ_L r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD D, (HL)
@-------------------------------------------------------------------------------
op56:

	READ_HL r7
	READ_8 r6, r7
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD E, B
@-------------------------------------------------------------------------------
op58:

	READ_B r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD E, C
@-------------------------------------------------------------------------------
op59:

	READ_C r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD E, D
@-------------------------------------------------------------------------------
op5A:

	READ_D r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD E, E
@-------------------------------------------------------------------------------
op5B:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD E, H
@-------------------------------------------------------------------------------
op5C:

	READ_H r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD E, L
@-------------------------------------------------------------------------------
op5D:

	READ_L r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD E, (HL)
@-------------------------------------------------------------------------------
op5E:

	READ_HL r7
	READ_8 r6, r7
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD H, B
@-------------------------------------------------------------------------------
op60:

	READ_B r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD H, C
@-------------------------------------------------------------------------------
op61:

	READ_C r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD H, D
@-------------------------------------------------------------------------------
op62:

	READ_D r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD H, E
@-------------------------------------------------------------------------------
op63:

	READ_E r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD H, H
@-------------------------------------------------------------------------------
op64:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD H, L
@-------------------------------------------------------------------------------
op65:

	READ_L r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD H, (HL)
@-------------------------------------------------------------------------------
op66:

	READ_HL r7
	READ_8 r6, r7
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD L, B
@-------------------------------------------------------------------------------
op68:

	READ_B r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD L, C
@-------------------------------------------------------------------------------
op69:

	READ_C r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD L, D
@-------------------------------------------------------------------------------
op6A:

	READ_D r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD L, E
@-------------------------------------------------------------------------------
op6B:

	READ_E r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD L, H
@-------------------------------------------------------------------------------
op6C:

	READ_H r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD L, L
@-------------------------------------------------------------------------------
op6D:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD L, (HL)
@-------------------------------------------------------------------------------
op6E:

	READ_HL r7
	READ_8 r6, r7
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), B
@-------------------------------------------------------------------------------
op70:
	
	READ_B r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), C
@-------------------------------------------------------------------------------
op71:
	
	READ_C r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), D
@-------------------------------------------------------------------------------
op72:
	
	READ_D r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), E
@-------------------------------------------------------------------------------
op73:
	
	READ_E r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), H
@-------------------------------------------------------------------------------
op74:
	
	READ_H r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), L
@-------------------------------------------------------------------------------
op75:
	
	READ_L r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), XX
@-------------------------------------------------------------------------------
op36:
	
	READ_IMM8 r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (BC)
@-------------------------------------------------------------------------------
op0A:
	
	READ_BC r6
	READ_8 r6, r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (DE)
@-------------------------------------------------------------------------------
op1A:
	
	READ_DE r6
	READ_8 r6, r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (XXXX)
@-------------------------------------------------------------------------------
opFA:
	
	READ_IMM16 r6, r7
	READ_8 r6, r6
	SET_A r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ LD A, XX
@-------------------------------------------------------------------------------
op3E:
	
	READ_IMM8 r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD B, A
@-------------------------------------------------------------------------------
op47:
	
	READ_A r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD C, A
@-------------------------------------------------------------------------------
op4F:
	
	READ_A r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD D, A
@-------------------------------------------------------------------------------
op57:
	
	READ_A r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD E, A
@-------------------------------------------------------------------------------
op5F:
	
	READ_A r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD H, A
@-------------------------------------------------------------------------------
op67:
	
	READ_A r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD L, A
@-------------------------------------------------------------------------------
op6F:
	
	READ_A r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ LD (BC), A
@-------------------------------------------------------------------------------
op02:
	
	READ_A r6
	READ_BC r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (DE), A
@-------------------------------------------------------------------------------
op12:
	
	READ_A r6
	READ_DE r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), A
@-------------------------------------------------------------------------------
op77:
	
	READ_A r6
	READ_HL r7
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL), A
@-------------------------------------------------------------------------------
opEA:
	
	READ_IMM16 r7, r6
	READ_A r6
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (FF00 + C)
@-------------------------------------------------------------------------------
opF2:
	
	READ_C r6
	add r6, r6, r12, lsl #8
	READ_8 r7, r6
	SET_A r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (FF00 + C), A
@-------------------------------------------------------------------------------
opE2:
	
	READ_C r6
	add r6, r6, r12, lsl #8
	READ_A r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (HL-)
@-------------------------------------------------------------------------------
op3A:
	
	READ_HL r6
	READ_8 r7, r6
	SET_A r7
	sub r6, r6, #1
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL-), A
@-------------------------------------------------------------------------------
op32:
	
	READ_HL r6
	READ_A r7
	WRITE_8 r7, r6
	sub r6, r6, #1
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (HL+)
@-------------------------------------------------------------------------------
op2A:
	
	READ_HL r6
	READ_8 r7, r6
	SET_A r7
	add r6, r6, #1
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (HL+), A
@-------------------------------------------------------------------------------
op22:
	
	READ_HL r6
	READ_A r7
	WRITE_8 r7, r6
	add r6, r6, #1
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (FF00 + XX), A
@-------------------------------------------------------------------------------
opE0:
	
	READ_IMM8 r6
	add r6, r6, r12, lsl #8
	READ_A r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (FF00 + XX)
@-------------------------------------------------------------------------------
opF0:
	
	READ_IMM8 r6
	add r6, r6, r12, lsl #8
	READ_8 r7, r6
	SET_A r7
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD BC, XXXX
@-------------------------------------------------------------------------------
op01:
	
	READ_IMM16 r6, r7
	SET_BC r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD DE, XXXX
@-------------------------------------------------------------------------------
op11:
	
	READ_IMM16 r6, r7
	SET_DE r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD HL, XXXX
@-------------------------------------------------------------------------------
op21:
	
	READ_IMM16 r6, r7
	SET_HL r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD SP, XXXX
@-------------------------------------------------------------------------------
op31:
	
	READ_IMM16 r6, r7
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD SP, HL
@-------------------------------------------------------------------------------
opF9:
	
	READ_HL r6
	SET_SP r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD HL, SP+XX
@-------------------------------------------------------------------------------
opF8:
	
	READ_SP r6
	READ_IMM8 r7
	tst r7, #0xF0
	addeq r6, r6, r7
	subne r6, r6, r7
	RESET_FLAG_Z
	RESET_FLAG_N		@TODO: Take care of C,H flags
	and r6, r6, r11
	SET_HL r6
	UPDATE_CYCLE_COUNT 3
	bx lr



@@@@@@@@@@@@@
	.data
@@@@@@@@@@@@@

@-------------------------------------------------------------------------------
@ Gameboy Processor State
@-------------------------------------------------------------------------------
State:
	.global State

    .word 0x00000000	@ A,B,C,F
    .word 0x00000000	@ D,E,H,L
    .word 0x0000FFFE	@ SP
    .word 0x00000100	@ PC (initially set to 0x100)
    .word 0x00000000	@ Frame cycle count (overflow from last frame)

@-------------------------------------------------------------------------------
@ Opcode Function Jump Table
@-------------------------------------------------------------------------------
OpcodeJT:

    .word op00, op01, op02, op__, op__, op__, op06, op__, op__, op__, op0A, op__, op__, op__, op0E, op__
    .word op__, op11, op12, op__, op__, op__, op16, op__, op__, op__, op1A, op__, op__, op__, op1E, op__
    .word op__, op21, op22, op__, op__, op__, op26, op__, op__, op__, op2A, op__, op__, op__, op2E, op__
    .word op__, op31, op32, op__, op__, op__, op36, op__, op__, op__, op3A, op__, op__, op__, op3E, op__
    .word op40, op41, op42, op43, op44, op45, op46, op47, op48, op49, op4A, op4B, op4C, op4D, op4E, op4F
    .word op50, op51, op52, op53, op54, op55, op56, op57, op58, op59, op5A, op5B, op5C, op5D, op5E, op5F
    .word op60, op61, op62, op63, op64, op65, op66, op67, op68, op69, op6A, op6B, op6C, op6D, op6E, op6F
    .word op70, op71, op72, op73, op74, op75, op__, op77, op78, op79, op7A, op7B, op7C, op7D, op7E, op7F
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__, op__
    .word opE0, op__, opE2, op__, op__, op__, op__, op__, op__, op__, opEA, op__, op__, op__, op__, op__
    .word opF0, op__, opF2, op__, op__, op__, op__, op__, opF8, opF9, opFA, op__, op__, op__, op__, op__

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