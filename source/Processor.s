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
	bic r0, r0, r11, lsl #8
	orr r0, r0, \r, lsl #8
.endm

.macro SET_F r
	bic r0, r0, r11
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
	bic r0, r0, #0x80
.endm

.macro RESET_FLAG_N
	bic r0, r0, #0x40
.endm

.macro RESET_FLAG_H
	bic r0, r0, #0x20
.endm

.macro RESET_FLAG_C
	bic r0, r0, #0x10
.endm

.macro CHECK_FLAG_Z
	tst r0, #0x80
.endm

.macro CHECK_FLAG_N
	tst r0, #0x40
.endm

.macro CHECK_FLAG_H
	tst r0, #0x20
.endm

.macro CHECK_FLAG_C
	tst r0, #0x10
.endm

.macro UPDATE_FLAG_Z
	orreq r0, r0, #0x80
	bicne r0, r0, #0x80
.endm

.macro UPDATE_FLAG_H r, m
	tst \r, \m
	orrne r0, r0, #0x20
	biceq r0, r0, #0x20
.endm

.macro UPDATE_FLAG_C r, m
	tst \r, \m
	orrne r0, r0, #0x10
	biceq r0, r0, #0x10
.endm

.macro UPDATE_FLAG_H_NEG r, m
	tst \r, \m
	orreq r0, r0, #0x20
	bicne r0, r0, #0x20
.endm

.macro UPDATE_FLAG_C_NEG r, m
	tst \r, \m
	orreq r0, r0, #0x10
	bicne r0, r0, #0x10
.endm

.macro SET_B r
	bic r0, r0, r11, lsl #24
	orr r0, r0, \r, lsl #24
.endm

.macro SET_C r
	bic r0, r0, r11, lsl #16
	orr r0, r0, \r, lsl #16
.endm

.macro SET_D r
	bic r1, r1, r11, lsl #24
	orr r1, r1, \r, lsl #24
.endm

.macro SET_E r
	bic r1, r1, r11, lsl #16
	orr r1, r1, \r, lsl #16
.endm

.macro SET_H r
	bic r1, r1, r11, lsl #8
	orr r1, r1, \r, lsl #8
.endm

.macro SET_L r
	bic r1, r1, r11
	orr r1, r1, \r
.endm

.macro SET_AF r
	bic r0, r0, r12
	orr r0, r0, \r
.endm

.macro SET_BC r
	bic r0, r0, r12, lsl #16
	orr r0, r0, \r, lsl #16
.endm

.macro SET_DE r
	bic r1, r1, r12, lsl #16
	orr r1, r1, \r, lsl #16
.endm

.macro SET_HL r
	bic r1, r1, r12
	orr r1, r1, \r
.endm

.macro SET_SP r
	mov r2, \r
.endm

.macro SET_PC r
	mov r3, \r
.endm

.macro READ_A r
	mov \r, r0, lsr #8
	and \r, \r, r11
.endm

.macro READ_F r
	and \r, r0, r11
.endm

.macro READ_B r
	mov \r, r0, lsr #24
.endm

.macro READ_C r
	mov \r, r0, lsr #16
	and \r, \r, r11
.endm

.macro READ_D r
	mov \r, r1, lsr #24
.endm

.macro READ_E r
	mov \r, r1, lsr #16
	and \r, \r, r11
.endm

.macro READ_H r
	mov \r, r1, lsr #8
	and \r, \r, r11
.endm

.macro READ_L r
	and \r, r1, r11
.endm

.macro READ_AF r
	and \r, r0, r12
.endm

.macro READ_BC r
	mov \r, r0, lsr #16
.endm

.macro READ_DE r
	mov \r, r1, lsr #16
.endm

.macro READ_HL r
	and \r, r1, r12
.endm

.macro READ_SP r
	mov \r, r2
.endm

.macro READ_PC r
	mov \r, r3
.endm

.macro WRITE_8 r, a
	strb \r, [r5, \a]
.endm

.macro WRITE_16 r, a
	strb \r, [r5, \a]
	add \a, \a, #1
	lsr \r, \r, #8
	strb \r, [r5, \a]
	sub \a, \a, #1
.endm

.macro READ_8 r, a
	ldrb \r, [r5, \a]
.endm

.macro READ_16 r, a, t
	ldrb \r, [r5, \a]
	add \a, \a, #1
	ldrb \t, [r5, \a]
	sub \a, \a, #1
	orr \r, \r, \t, lsl #8
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
	orr \r, \r, \t, lsl #8
.endm

.macro UPDATE_CYCLE_COUNT c
	add r4, r4, #\c
.endm

.macro SIGN_EXTEND_8 r
	tst \r, #0x80
	orrne \r, \r, r12, lsl #8
.endm

.macro ADD8 d, r
	RESET_FLAG_N
	and r8, \d, #0xF
	and r9, \r, #0xF
	add r8, r8, r9
	UPDATE_FLAG_H r8, #0x10
	add \d, \d, \r
	UPDATE_FLAG_C \d, #0x100
	ands \d, \d, r11
	UPDATE_FLAG_Z
.endm

.macro ADD16 d, r
	RESET_FLAG_N
	orr r9, r11, #0xF00
	and r8, \d, r9
	and r9, \r, r9
	add r8, r8, r9
	UPDATE_FLAG_H r8, #0x1000
	add \d, \d, \r
	UPDATE_FLAG_C \d, #0x10000
	and \d, \d, r12
.endm

.macro SUB8 d, r
	SET_FLAG_N
	and r8, \d, #0xF
	and r9, \r, #0xF
	sub r8, r8, r9
	UPDATE_FLAG_H_NEG r8, #0x10
	sub \d, \d, \r
	UPDATE_FLAG_C_NEG \d, #0x100
	ands \d, \d, r11
	UPDATE_FLAG_Z
.endm

.macro AND8 d, r
	ands \d, \d, \r
	UPDATE_FLAG_Z
	RESET_FLAG_N
	SET_FLAG_H
	RESET_FLAG_C
.endm

.macro OR8 d, r
	orrs \d, \d, \r
	UPDATE_FLAG_Z
	RESET_FLAG_N
	RESET_FLAG_H
	RESET_FLAG_C
.endm

.macro XOR8 d, r
	eors \d, \d, \r
	UPDATE_FLAG_Z
	RESET_FLAG_N
	RESET_FLAG_H
	RESET_FLAG_C
.endm

.macro CP d, r
	SET_FLAG_N
	and r8, \d, #0xF
	and r9, \r, #0xF
	sub r8, r8, r9
	UPDATE_FLAG_H_NEG r8, #0x10
	sub \d, \d, \r
	UPDATE_FLAG_C_NEG \d, #0x100
	ands \d, \d, r11
	UPDATE_FLAG_Z
.endm

.macro INC8 r
	RESET_FLAG_N
	and r8, \r, #0xF
	add r8, r8, #1
	UPDATE_FLAG_H r8, #0x10
	add \r, \r, #1
	ands \r, \r, r11
	UPDATE_FLAG_Z
.endm

.macro DEC8 r
	SET_FLAG_N
	and r8, \r, #0xF
	sub r8, r8, #1
	UPDATE_FLAG_H_NEG r8, #0x10
	sub \r, \r, #1
	ands \r, \r, r11
	UPDATE_FLAG_Z
.endm

.macro SWAP r, t
	mov \t, \r, lsr #4
	orr \t, \t, \r, lsl #4
	ands \r, \t, #0xFF
	UPDATE_FLAG_Z
	RESET_FLAG_N
	RESET_FLAG_H
	RESET_FLAG_C
.endm

.macro RLC r
	RESET_FLAG_N
	RESET_FLAG_H
	lsl \r, \r, #1
	UPDATE_FLAG_C \r, #0x100
	orr \r, \r, \r, lsr #8
	ands \r, \r, #0xFF
	UPDATE_FLAG_Z
.endm

.macro RL r, t
	READ_F \t
	RESET_FLAG_N
	RESET_FLAG_H
	lsl \r, \r, #1
	tst \t, #0x10
	orrne \r, \r, #0x01
	UPDATE_FLAG_C \r, #0x100
	ands \r, \r, #0xFF
	UPDATE_FLAG_Z
.endm

.macro RRC r
	RESET_FLAG_N
	RESET_FLAG_H
	UPDATE_FLAG_C \r, #0x1
	orr \r, \r, \r, lsl #8
	lsr \r, \r, #1
	ands \r, \r, #0xFF
	UPDATE_FLAG_Z
.endm

.macro RR r, t
	READ_F \t
	RESET_FLAG_N
	RESET_FLAG_H
	UPDATE_FLAG_C \r, #0x1
	lsrs \r, \r, #1
	tst \t, #0x10
	orrne \r, \r, #0x80
	ands \r, \r, #0xFF
	UPDATE_FLAG_Z
.endm

.macro SLA r
	RESET_FLAG_N
	RESET_FLAG_H
	lsl \r, \r, #1
	UPDATE_FLAG_C \r, #0x100
	ands \r, \r, #0xFF
	UPDATE_FLAG_Z
.endm

.macro SRA r
	RESET_FLAG_N
	RESET_FLAG_H
	UPDATE_FLAG_C \r, #0x1
	lsr \r, \r, #1
	tst \r, #0x40
	orrne \r, \r, #0x80
	ands \r, \r, #0xFF
	UPDATE_FLAG_Z
.endm

.macro SRL r
	RESET_FLAG_N
	RESET_FLAG_H
	UPDATE_FLAG_C \r, #0x1
	lsr \r, \r, #1
	ands \r, \r, #0x7F
	UPDATE_FLAG_Z
.endm

.macro BIT r, b
	RESET_FLAG_N
	SET_FLAG_H
	tst \r, \b
	UPDATE_FLAG_Z
.endm

.macro RES r, b
	bic \r, \r, \b
.endm

.macro SET r, b
	orr \r, \r, \b
.endm

@-------------------------------------------------------------------------------
@ void executeFrame (void)
@-------------------------------------------------------------------------------
@ r0  = B,C,A,F State Registers
@ r1  = D,E,H,L State Registers
@ r2  = SP State Register
@ r3  = PC State Register
@ r4  = Frame Cycle Count
@ r5  = RAM Address
@ r10 = ProcessorState Address
@ r11 = Byte mask (0xFF)
@ r12 = Word mask (0xFFFF)
@-------------------------------------------------------------------------------
executeFrame:
	.global executeFrame

	push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}		@ Saving registers for calling function

	ldr r10, =ProcessorState		@ Initializing r10 to the ProcessorState address

	ldr r0, [r10]					@ Loading A,B,C,F
	ldr r1, [r10, #4]				@ Loading D,E,H,L
	ldr r2, [r10, #8]				@ Loading SP
	ldr r3, [r10, #12]				@ Loading PC
	ldr r4, [r10, #16]				@ Loading frame cycle count

	ldr r5, =RAM					@ Initializing r5 to the RAM address

	mov r11, #0xFF					@ Initializing r11 to 0xFF used for byte masking
	orr r12, r11, r11, lsl #8		@ Initializing r12 to 0xFFFF used for word masking

	ldr r6, =RequestedVBlank
	mov r7, #0
	streq r7, [r6]					@ Storing that VBlank was not requested this frame

.next:

	ldrb r6, [r5, r3]				@ Loading the next instruction opcode
	add r3, r3, #1					@ Incrementing PC by 1

	ldr r7, =OpcodeJT				@ Loading opcode jump table address
	ldr r7, [r7, r6, lsl #2]		@ Loading opcode handler function address

	adr lr, .opReturn				@ Loading link register with the return address
	bx r7							@ Branching to the opcode handler function

.opReturn:

	mov r8, #0						@ Initializing the new request flags to 0

	ldr r6, [r10, #24]				@ Loading div timer cycle count
	add r6, r6, #4
	ands r6, r6, r11
	str r6, [r10, #24]				@ Storing the div timer cycle count
	bne .handleTimer				@ Skipping over incrementing div timer if not needed yet

	ldr r6, =0xFF04
	ldr r7, [r5, r6]
	add r7, r7, #1
	and r7, r7, r11
	str r7, [r5, r6]				@ Updating the DIV timer by incrementing it

.handleTimer:

	ldr r6, =0xFF07
	ldrb r6, [r5, r6]
	tst r6, #0x04
	beq .handleGraphics				@ Skipping over timer handling if it is stopped

.handleGraphics:

	ldr r6, =16416
	cmp r4, r6
	blt .handleInterrupts			@ Skipping possible VBlank request if not time yet

	ldr r6, =RequestedVBlank
	ldr r7, [r6]
	cmp	r7, #0
	orreq r8, r8, #0x01				@ Adding VBlank to the new request flags
	moveq r7, #1
	streq r7, [r6]					@ Storing that VBlank was requested this frame

.handleInterrupts:

	ldr r9, =0xFF0F
	ldrb r7, [r5, r9]				@ Loading the current interrupt request flags

	orr r7, r7, r8					
	strb r7, [r5, r9]				@ Updating it with the new request flags

	ldr r6, [r10, #20]				
	orrs r6, r6, #0
	beq .checkDone					@ IME flag not set, SKIPPING

	ldrb r6, [r5, r12]				@ Loading the interrupt enable flags

	ands r6, r6, r7					@ ANDing the enable and request flags

	beq .checkDone					@ No enabled interrupts were requested, SKIPPING

	ldr r8, =InterruptPriority
	ldr r8, [r8, r6, lsl #2]		@ Figuring out which interrupt has priority

	bic r7, r7, r8
	strb r7, [r5, r9]				@ Clearing the current request flag and storing it

	mov r6, #0
	str r6, [r10, #20]				@ Disabling the IME flag

	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7						@ Pushing the current PC onto the stack

	ldr r6, =InterruptVector
	ldr r6, [r6, r8, lsl #2]
	SET_PC r6						@ Loading the interrupt vector address into the PC

.checkDone:

	ldr r6, =17556
	cmp r4, r6
	blt .next						@ Executing next instruction if not done

.done:

	sub r4, r4, r6					@ Calculating the number of leftover cycles

	str r0, [r10]					@ Saving A,F,B,C
	str r1, [r10, #4]				@ Saving D,E,H,L
	str r2, [r10, #8]				@ Saving SP
	str r3, [r10, #12]				@ Saving PC
	str r4, [r10, #16]				@ Saving leftover cycle count

	pop	{r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}		@ Restoring registers for calling function

	bx lr

@-------------------------------------------------------------------------------
@ Not Yet Implemented
@-------------------------------------------------------------------------------
op__:
opCB__:

	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ Does not exist
@-------------------------------------------------------------------------------
opXX:

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

@###############################################################################
	.ltorg
@###############################################################################

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
	
	READ_BC r7
	READ_8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (DE)
@-------------------------------------------------------------------------------
op1A:
	
	READ_DE r7
	READ_8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (XXXX)
@-------------------------------------------------------------------------------
opFA:
	
	READ_IMM16 r7, r8
	READ_8 r6, r7
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
@ LD (XXXX), A
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
	add r6, r6, r11, lsl #8
	READ_8 r7, r6
	SET_A r7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (FF00 + C), A
@-------------------------------------------------------------------------------
opE2:
	
	READ_C r6
	add r6, r6, r11, lsl #8
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
	and r6, r6, r12
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
	and r6, r6, r12
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
	and r6, r6, r12
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
	and r6, r6, r12
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ LD (FF00 + XX), A
@-------------------------------------------------------------------------------
opE0:
	
	READ_IMM8 r6
	add r6, r6, r11, lsl #8
	READ_A r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD A, (FF00 + XX)
@-------------------------------------------------------------------------------
opF0:
	
	READ_IMM8 r6
	add r6, r6, r11, lsl #8
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
	SIGN_EXTEND_8 r7
	RESET_FLAG_Z
	RESET_FLAG_N
	and r8, r6, #0xF
	and r9, r7, #0xF
	add r8, r8, r9
	UPDATE_FLAG_H r8, #0x10
	add r6, r6, r7
	UPDATE_FLAG_C r6, #0x10000
	and r6, r6, r12
	SET_HL r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ LD (XXXX), SP
@-------------------------------------------------------------------------------
op08:
	
	READ_SP r6
	READ_IMM16 r7, r8
	WRITE_16 r6, r7
	UPDATE_CYCLE_COUNT 5
	bx lr

@-------------------------------------------------------------------------------
@ PUSH AF
@-------------------------------------------------------------------------------
opF5:
	
	READ_AF r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ PUSH BC
@-------------------------------------------------------------------------------
opC5:
	
	READ_BC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ PUSH DE
@-------------------------------------------------------------------------------
opD5:
	
	READ_DE r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ PUSH HL
@-------------------------------------------------------------------------------
opE5:
	
	READ_HL r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ POP AF
@-------------------------------------------------------------------------------
opF1:
	
	READ_SP r6
	READ_16 r7, r6, r8
	SET_AF r7
	add r6, r6, #2
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ POP BC
@-------------------------------------------------------------------------------
opC1:
	
	READ_SP r6
	READ_16 r7, r6, r8
	SET_BC r7
	add r6, r6, #2
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ POP DE
@-------------------------------------------------------------------------------
opD1:
	
	READ_SP r6
	READ_16 r7, r6, r8
	SET_DE r7
	add r6, r6, #2
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ POP HL
@-------------------------------------------------------------------------------
opE1:
	
	READ_SP r6
	READ_16 r7, r6, r8
	SET_HL r7
	add r6, r6, #2
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, A
@-------------------------------------------------------------------------------
op87:
	
	READ_A r6
	mov r7, r6
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, B
@-------------------------------------------------------------------------------
op80:
	
	READ_A r6
	READ_B r7
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, C
@-------------------------------------------------------------------------------
op81:
	
	READ_A r6
	READ_C r7
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, D
@-------------------------------------------------------------------------------
op82:
	
	READ_A r6
	READ_D r7
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, E
@-------------------------------------------------------------------------------
op83:
	
	READ_A r6
	READ_E r7
	RESET_FLAG_N
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, H
@-------------------------------------------------------------------------------
op84:
	
	READ_A r6
	READ_H r7
	RESET_FLAG_N
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, L
@-------------------------------------------------------------------------------
op85:
	
	READ_A r6
	READ_L r7
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, (HL)
@-------------------------------------------------------------------------------
op86:
	
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ ADD A, XX
@-------------------------------------------------------------------------------
opC6:
	
	READ_A r6
	READ_IMM8 r7
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, A
@-------------------------------------------------------------------------------
op8F:
	
	READ_A r6
	CHECK_FLAG_C
	addne r7, r6, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, B
@-------------------------------------------------------------------------------
op88:
	
	READ_A r6
	READ_B r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, C
@-------------------------------------------------------------------------------
op89:
	
	READ_A r6
	READ_C r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, D
@-------------------------------------------------------------------------------
op8A:
	
	READ_A r6
	READ_D r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, E
@-------------------------------------------------------------------------------
op8B:
	
	READ_A r6
	READ_E r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, H
@-------------------------------------------------------------------------------
op8C:
	
	READ_A r6
	READ_H r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, L
@-------------------------------------------------------------------------------
op8D:
	
	READ_A r6
	READ_L r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, (HL)
@-------------------------------------------------------------------------------
op8E:
	
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ ADC A, XX
@-------------------------------------------------------------------------------
opCE:
	
	READ_A r6
	READ_IMM8 r7
	CHECK_FLAG_C
	addne r7, r7, #1
	ADD8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, A
@-------------------------------------------------------------------------------
op97:
	
	READ_A r6
	mov r7, r6
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, B
@-------------------------------------------------------------------------------
op90:
	
	READ_A r6
	READ_B r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, C
@-------------------------------------------------------------------------------
op91:
	
	READ_A r6
	READ_C r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, D
@-------------------------------------------------------------------------------
op92:
	
	READ_A r6
	READ_D r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, E
@-------------------------------------------------------------------------------
op93:
	
	READ_A r6
	READ_E r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, H
@-------------------------------------------------------------------------------
op94:
	
	READ_A r6
	READ_H r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, L
@-------------------------------------------------------------------------------
op95:
	
	READ_A r6
	READ_L r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@###############################################################################
	.ltorg
@###############################################################################

@-------------------------------------------------------------------------------
@ SUB A, (HL)
@-------------------------------------------------------------------------------
op96:
	
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SUB A, XX
@-------------------------------------------------------------------------------
opD6:
	
	READ_A r6
	READ_IMM8 r7
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, A
@-------------------------------------------------------------------------------
op9F:
	
	READ_A r6
	mov r7, r6
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, B
@-------------------------------------------------------------------------------
op98:
	
	READ_A r6
	READ_B r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, C
@-------------------------------------------------------------------------------
op99:
	
	READ_A r6
	READ_C r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, D
@-------------------------------------------------------------------------------
op9A:
	
	READ_A r6
	READ_D r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, E
@-------------------------------------------------------------------------------
op9B:
	
	READ_A r6
	READ_E r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, H
@-------------------------------------------------------------------------------
op9C:
	
	READ_A r6
	READ_H r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, L
@-------------------------------------------------------------------------------
op9D:
	
	READ_A r6
	READ_L r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, (HL)
@-------------------------------------------------------------------------------
op9E:
	
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SBC A, XX
@-------------------------------------------------------------------------------
opDE:
	
	READ_A r6
	READ_IMM8 r7
	CHECK_FLAG_C
	addne r7, r7, #1
	SUB8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ AND A, A
@-------------------------------------------------------------------------------
opA7:
	READ_A r6
	mov r7, r6
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ AND A, B
@-------------------------------------------------------------------------------
opA0:
	READ_A r6
	READ_B r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ AND A, C
@-------------------------------------------------------------------------------
opA1:
	READ_A r6
	READ_C r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ AND A, D
@-------------------------------------------------------------------------------
opA2:
	READ_A r6
	READ_D r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ AND A, E
@-------------------------------------------------------------------------------
opA3:
	READ_A r6
	READ_E r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ AND A, H
@-------------------------------------------------------------------------------
opA4:
	READ_A r6
	READ_H r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ AND A, L
@-------------------------------------------------------------------------------
opA5:
	READ_A r6
	READ_L r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ AND A, (HL)
@-------------------------------------------------------------------------------
opA6:
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ AND A, XX
@-------------------------------------------------------------------------------
opE6:
	READ_A r6
	READ_IMM8 r7
	AND8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ OR A, A
@-------------------------------------------------------------------------------
opB7:
	READ_A r6
	mov r7, r6
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ OR A, B
@-------------------------------------------------------------------------------
opB0:
	READ_A r6
	READ_B r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ OR A, C
@-------------------------------------------------------------------------------
opB1:
	READ_A r6
	READ_C r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ OR A, D
@-------------------------------------------------------------------------------
opB2:
	READ_A r6
	READ_D r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ OR A, E
@-------------------------------------------------------------------------------
opB3:
	READ_A r6
	READ_E r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ OR A, H
@-------------------------------------------------------------------------------
opB4:
	READ_A r6
	READ_H r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ OR A, L
@-------------------------------------------------------------------------------
opB5:
	READ_A r6
	READ_L r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ OR A, (HL)
@-------------------------------------------------------------------------------
opB6:
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ OR A, XX
@-------------------------------------------------------------------------------
opF6:
	READ_A r6
	READ_IMM8 r7
	OR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, A
@-------------------------------------------------------------------------------
opAF:
	READ_A r6
	mov r7, r6
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, B
@-------------------------------------------------------------------------------
opA8:
	READ_A r6
	READ_B r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, C
@-------------------------------------------------------------------------------
opA9:
	READ_A r6
	READ_C r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, D
@-------------------------------------------------------------------------------
opAA:
	READ_A r6
	READ_D r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, E
@-------------------------------------------------------------------------------
opAB:
	READ_A r6
	READ_E r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, H
@-------------------------------------------------------------------------------
opAC:
	READ_A r6
	READ_H r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, L
@-------------------------------------------------------------------------------
opAD:
	READ_A r6
	READ_L r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, (HL)
@-------------------------------------------------------------------------------
opAE:
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ XOR A, XX
@-------------------------------------------------------------------------------
opEE:
	READ_A r6
	READ_IMM8 r7
	XOR8 r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ CP A, A
@-------------------------------------------------------------------------------
opBF:
	SET_FLAG_Z
	SET_FLAG_N
	SET_FLAG_H
	SET_FLAG_C
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CP A, B
@-------------------------------------------------------------------------------
opB8:
	READ_A r6
	READ_B r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CP A, C
@-------------------------------------------------------------------------------
opB9:
	READ_A r6
	READ_C r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CP A, D
@-------------------------------------------------------------------------------
opBA:
	READ_A r6
	READ_D r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CP A, E
@-------------------------------------------------------------------------------
opBB:
	READ_A r6
	READ_E r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CP A, H
@-------------------------------------------------------------------------------
opBC:
	READ_A r6
	READ_H r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CP A, L
@-------------------------------------------------------------------------------
opBD:
	READ_A r6
	READ_L r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CP A, (HL)
@-------------------------------------------------------------------------------
opBE:
	READ_A r6
	READ_HL r7
	READ_8 r7, r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ CP A, XX
@-------------------------------------------------------------------------------
opFE:
	READ_A r6
	READ_IMM8 r7
	CP r6, R7
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ INC A
@-------------------------------------------------------------------------------
op3C:
	READ_A r6
	INC8 r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ INC B
@-------------------------------------------------------------------------------
op04:
	READ_B r6
	INC8 r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ INC C
@-------------------------------------------------------------------------------
op0C:
	READ_C r6
	INC8 r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ INC D
@-------------------------------------------------------------------------------
op14:
	READ_D r6
	INC8 r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ INC E
@-------------------------------------------------------------------------------
op1C:
	READ_E r6
	INC8 r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ INC H
@-------------------------------------------------------------------------------
op24:
	READ_H r6
	INC8 r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ INC L
@-------------------------------------------------------------------------------
op2C:
	READ_L r6
	INC8 r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ INC (HL)
@-------------------------------------------------------------------------------
op34:
	READ_HL r7
	READ_8 r6, r7
	INC8 r6
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ DEC A
@-------------------------------------------------------------------------------
op3D:
	READ_A r6
	DEC8 r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ DEC B
@-------------------------------------------------------------------------------
op05:
	READ_B r6
	DEC8 r6
	SET_B r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ DEC C
@-------------------------------------------------------------------------------
op0D:
	READ_C r6
	DEC8 r6
	SET_C r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ DEC D
@-------------------------------------------------------------------------------
op15:
	READ_D r6
	DEC8 r6
	SET_D r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ DEC E
@-------------------------------------------------------------------------------
op1D:
	READ_E r6
	DEC8 r6
	SET_E r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ DEC H
@-------------------------------------------------------------------------------
op25:
	READ_H r6
	DEC8 r6
	SET_H r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ DEC L
@-------------------------------------------------------------------------------
op2D:
	READ_L r6
	DEC8 r6
	SET_L r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ DEC (HL)
@-------------------------------------------------------------------------------
op35:
	READ_HL r7
	READ_8 r6, r7
	DEC8 r6
	WRITE_8 r6, r7
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ ADD HL, BC
@-------------------------------------------------------------------------------
op09:
	
	READ_HL r6
	READ_BC r7
	ADD16 r6, r7
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ ADD HL, DE
@-------------------------------------------------------------------------------
op19:
	
	READ_HL r6
	READ_DE r7
	ADD16 r6, r7
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ ADD HL, HL
@-------------------------------------------------------------------------------
op29:
	
	READ_HL r6
	READ_HL r7
	ADD16 r6, r7
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ ADD HL, SP
@-------------------------------------------------------------------------------
op39:
	
	READ_HL r6
	READ_SP r7
	ADD16 r6, r7
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ ADD SP, XX
@-------------------------------------------------------------------------------
opE8:
	
	READ_SP r6
	READ_IMM8 r7
	SIGN_EXTEND_8 r7
	RESET_FLAG_Z
	RESET_FLAG_N
	and r8, r6, #0xF
	and r9, r7, #0xF
	add r8, r8, r9
	UPDATE_FLAG_H r8, #0x10
	add r6, r6, r7
	UPDATE_FLAG_C r6, #0x10000
	and r6, r6, r12
	SET_SP r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ INC BC
@-------------------------------------------------------------------------------
op03:
	
	READ_BC r6
	add r6, r6, #1
	and r6, r6, r12
	SET_BC r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ INC DE
@-------------------------------------------------------------------------------
op13:
	
	READ_DE r6
	add r6, r6, #1
	and r6, r6, r12
	SET_DE r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ INC HL
@-------------------------------------------------------------------------------
op23:
	
	READ_HL r6
	add r6, r6, #1
	and r6, r6, r12
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ INC SP
@-------------------------------------------------------------------------------
op33:
	
	READ_SP r6
	add r6, r6, #1
	and r6, r6, r12
	SET_SP r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ DEC BC
@-------------------------------------------------------------------------------
op0B:
	
	READ_BC r6
	sub r6, r6, #1
	and r6, r6, r12
	SET_BC r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ DEC DE
@-------------------------------------------------------------------------------
op1B:
	
	READ_DE r6
	sub r6, r6, #1
	and r6, r6, r12
	SET_DE r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ DEC HL
@-------------------------------------------------------------------------------
op2B:
	
	READ_HL r6
	sub r6, r6, #1
	and r6, r6, r12
	SET_HL r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ DEC SP
@-------------------------------------------------------------------------------
op3B:
	
	READ_SP r6
	sub r6, r6, #1
	and r6, r6, r12
	SET_SP r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ DAA
@-------------------------------------------------------------------------------
op27:

	READ_A r6
	CHECK_FLAG_N
	bne .SUB_LOW

.ADD_LOW:

	CHECK_FLAG_H
	addne r6, r6, #0x6
	bne .ADD_HIGH

	and r7, r6, #0xF
	cmp r7, #0x9
	addgt r6, r6, #0x6

.ADD_HIGH:

	CHECK_FLAG_C
	addne r6, r6, #0x60
	bne .DAA_DONE

	and r7, r6, #0xF0
	cmp r7, #0x90
	addgt r6, r6, #0x60
	b .DAA_DONE

.SUB_LOW:

	CHECK_FLAG_H
	subeq r6, r6, #0x6
	beq .SUB_HIGH

	and r7, r6, #0xF
	cmp r7, #0x9
	subgt r6, r6, #0x6

.SUB_HIGH:

	CHECK_FLAG_C
	subeq r6, r6, #0x60
	beq .DAA_DONE

	and r7, r6, #0xF0
	cmp r7, #0x90
	subgt r6, r6, #0x60

.DAA_DONE:

	RESET_FLAG_H
	tst r6, #0x100
	orrne r0, r0, #0x10
	ands r6, r6, r11
	UPDATE_FLAG_Z
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CPL
@-------------------------------------------------------------------------------
op2F:
	
	READ_A r6
	eor r6, r6, r11
	SET_A r6
	SET_FLAG_N
	SET_FLAG_H
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ SCF
@-------------------------------------------------------------------------------
op37:
	
	RESET_FLAG_N
	RESET_FLAG_H
	SET_FLAG_C
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CCF
@-------------------------------------------------------------------------------
op3F:
	
	READ_F r6
	RESET_FLAG_N
	RESET_FLAG_H
	UPDATE_FLAG_C_NEG r6, #0x10
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ RLCA
@-------------------------------------------------------------------------------
op07:
	
	READ_A r6
	RLC r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ RLA
@-------------------------------------------------------------------------------
op17:
	
	READ_A r6
	RL r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@###############################################################################
	.ltorg
@###############################################################################

@-------------------------------------------------------------------------------
@ RRCA
@-------------------------------------------------------------------------------
op0F:
	
	READ_A r6
	RRC r6
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ RRA
@-------------------------------------------------------------------------------
op1F:
	
	READ_A r6
	RR r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JP XXXX
@-------------------------------------------------------------------------------
opC3:
	
	READ_IMM16 r6, r7
	SET_PC r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ JP NZ, XXXX
@-------------------------------------------------------------------------------
opC2:
	
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 3
	bxeq lr

	READ_IMM16 r6, r7
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JP Z, XXXX
@-------------------------------------------------------------------------------
opCA:
	
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 3
	bxne lr

	READ_IMM16 r6, r7
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JP NC, XXXX
@-------------------------------------------------------------------------------
opD2:
	
	CHECK_FLAG_C
	UPDATE_CYCLE_COUNT 3
	bxeq lr

	READ_IMM16 r6, r7
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JP C, XXXX
@-------------------------------------------------------------------------------
opDA:
	
	CHECK_FLAG_C
	UPDATE_CYCLE_COUNT 3
	bxne lr

	READ_IMM16 r6, r7
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JP (HL)
@-------------------------------------------------------------------------------
opE9:
	
	READ_HL r6
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JR XX
@-------------------------------------------------------------------------------
op18:
	
	READ_PC r6
	READ_IMM8 r7
	SIGN_EXTEND_8 r7
	sub r6, r6, #1
	add r6, r6, r7
	and r6, r6, r12
	SET_PC r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ JR NZ, XX
@-------------------------------------------------------------------------------
op20:
	
	READ_IMM8 r7
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 2
	bxeq lr

	READ_PC r6
	SIGN_EXTEND_8 r7
	sub r6, r6, #2
	add r6, r6, r7
	and r6, r6, r12
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JR Z, XX
@-------------------------------------------------------------------------------
op28:
	
	READ_IMM8 r7
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 2
	bxne lr

	READ_PC r6
	SIGN_EXTEND_8 r7
	sub r6, r6, #2
	add r6, r6, r7
	and r6, r6, r12
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JR NC, XX
@-------------------------------------------------------------------------------
op30:
	
	READ_IMM8 r7
	CHECK_FLAG_C
	UPDATE_CYCLE_COUNT 2
	bxeq lr

	READ_PC r6
	SIGN_EXTEND_8 r7
	sub r6, r6, #2
	add r6, r6, r7
	and r6, r6, r12
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ JR C, XX
@-------------------------------------------------------------------------------
op38:
	
	READ_IMM8 r7
	CHECK_FLAG_C
	UPDATE_CYCLE_COUNT 2
	bxne lr

	READ_PC r6
	SIGN_EXTEND_8 r7
	sub r6, r6, #2
	add r6, r6, r7
	and r6, r6, r12
	SET_PC r6
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ CALL XXXX
@-------------------------------------------------------------------------------
opCD:
	
	READ_IMM16 r6, r7
	READ_PC r7
	READ_SP r8
	sub r8, r8, #2
	WRITE_16 r7, r8
	SET_SP r8
	SET_PC r6
	UPDATE_CYCLE_COUNT 6
	bx lr

@-------------------------------------------------------------------------------
@ CALL NZ, XXXX
@-------------------------------------------------------------------------------
opC4:
	
	READ_IMM16 r6, r7
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 3
	bxeq lr
	
	READ_PC r7
	READ_SP r8
	sub r8, r8, #2
	WRITE_16 r7, r8
	SET_SP r8
	SET_PC r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ CALL Z, XXXX
@-------------------------------------------------------------------------------
opCC:
	
	READ_IMM16 r6, r7
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 3
	bxne lr

	READ_PC r7
	READ_SP r8
	sub r8, r8, #2
	WRITE_16 r7, r8
	SET_SP r8
	SET_PC r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ CALL NZ, XXXX
@-------------------------------------------------------------------------------
opD4:
	
	READ_IMM16 r6, r7
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 3
	bxeq lr
	
	READ_PC r7
	READ_SP r8
	sub r8, r8, #2
	WRITE_16 r7, r8
	SET_SP r8
	SET_PC r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ CALL Z, XXXX
@-------------------------------------------------------------------------------
opDC:
	
	READ_IMM16 r6, r7
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 3
	bxne lr

	READ_PC r7
	READ_SP r8
	sub r8, r8, #2
	WRITE_16 r7, r8
	SET_SP r8
	SET_PC r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ RST 00
@-------------------------------------------------------------------------------
opC7:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x00
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RST 08
@-------------------------------------------------------------------------------
opCF:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x08
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RST 10
@-------------------------------------------------------------------------------
opD7:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x10
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RST 18
@-------------------------------------------------------------------------------
opDF:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x18
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RST 20
@-------------------------------------------------------------------------------
opE7:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x20
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RST 28
@-------------------------------------------------------------------------------
opEF:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x28
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RST 30
@-------------------------------------------------------------------------------
opF7:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x30
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RST 38
@-------------------------------------------------------------------------------
opFF:
	
	READ_PC r6
	READ_SP r7
	sub r7, r7, #2
	WRITE_16 r6, r7
	SET_SP r7
	SET_PC #0x38
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RET
@-------------------------------------------------------------------------------
opC9:
	
	READ_SP r6
	READ_16 r7, r6, r8
	add r6, r6, #2
	SET_PC r7
	SET_SP r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RET NZ
@-------------------------------------------------------------------------------
opC0:
	
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 2
	bxeq lr
	
	READ_SP r6
	READ_16 r7, r6, r8
	add r6, r6, #2
	SET_PC r7
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ RET Z
@-------------------------------------------------------------------------------
opC8:
	
	CHECK_FLAG_Z
	UPDATE_CYCLE_COUNT 2
	bxne lr
	
	READ_SP r6
	READ_16 r7, r6, r8
	add r6, r6, #2
	SET_PC r7
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ RET NC
@-------------------------------------------------------------------------------
opD0:
	
	CHECK_FLAG_C
	UPDATE_CYCLE_COUNT 2
	bxeq lr
	
	READ_SP r6
	READ_16 r7, r6, r8
	add r6, r6, #2
	SET_PC r7
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ RET C
@-------------------------------------------------------------------------------
opD8:
	
	CHECK_FLAG_C
	UPDATE_CYCLE_COUNT 2
	bxne lr
	
	READ_SP r6
	READ_16 r7, r6, r8
	add r6, r6, #2
	SET_PC r7
	SET_SP r6
	UPDATE_CYCLE_COUNT 3
	bx lr

@-------------------------------------------------------------------------------
@ DI
@-------------------------------------------------------------------------------
opF3:

	ldr r7, =ProcessorState
	mov r6, #0
	str r6, [r7, #20]
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ EI
@-------------------------------------------------------------------------------
opFB:

	ldr r7, =ProcessorState
	mov r6, #1
	str r6, [r7, #20]
	UPDATE_CYCLE_COUNT 1
	bx lr

@-------------------------------------------------------------------------------
@ RETI
@-------------------------------------------------------------------------------
opD9:

	READ_SP r6
	READ_16 r7, r6, r8
	add r6, r6, #2
	SET_PC r7
	SET_SP r6

	ldr r7, =ProcessorState
	mov r6, #1
	str r6, [r7, #20]

	UPDATE_CYCLE_COUNT 2
	bx lr
	

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ CB Instruction
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

opCB:

	ldrb r6, [r5, r3]				@ Loading the next instruction opcode
	add r3, r3, #1					@ Incrementing PC by 1

	ldr r7, =CBOpcodeJT				@ Loading CB opcode jump table address
	ldr r7, [r7, r6]				@ Loading opcode handler function address

	bx r7							@ Branching to the opcode handler function

@-------------------------------------------------------------------------------
@ SWAP A
@-------------------------------------------------------------------------------
opCB37:

	READ_A r6
	SWAP r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SWAP B
@-------------------------------------------------------------------------------
opCB30:

	READ_B r6
	SWAP r6, r7
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SWAP C
@-------------------------------------------------------------------------------
opCB31:

	READ_C r6
	SWAP r6, r7
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SWAP D
@-------------------------------------------------------------------------------
opCB32:

	READ_D r6
	SWAP r6, r7
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SWAP E
@-------------------------------------------------------------------------------
opCB33:

	READ_E r6
	SWAP r6, r7
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SWAP H
@-------------------------------------------------------------------------------
opCB34:

	READ_H r6
	SWAP r6, r7
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SWAP L
@-------------------------------------------------------------------------------
opCB35:

	READ_L r6
	SWAP r6, r7
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SWAP (HL)
@-------------------------------------------------------------------------------
opCB36:

	READ_HL r6
	READ_8 r7, r6
	SWAP r7, r8
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RLC A
@-------------------------------------------------------------------------------
opCB07:
	
	READ_A r6
	RLC r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RLC B
@-------------------------------------------------------------------------------
opCB00:
	
	READ_B r6
	RLC r6
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RLC C
@-------------------------------------------------------------------------------
opCB01:
	
	READ_C r6
	RLC r6
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RLC D
@-------------------------------------------------------------------------------
opCB02:
	
	READ_D r6
	RLC r6
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RLC E
@-------------------------------------------------------------------------------
opCB03:
	
	READ_E r6
	RLC r6
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RLC H
@-------------------------------------------------------------------------------
opCB04:
	
	READ_H r6
	RLC r6
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RLC L
@-------------------------------------------------------------------------------
opCB05:
	
	READ_L r6
	RLC r6
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RLC (HL)
@-------------------------------------------------------------------------------
opCB06:
	
	READ_HL r6
	READ_8 r7, r6
	RLC r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RL A
@-------------------------------------------------------------------------------
opCB17:
	
	READ_A r6
	RL r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RL B
@-------------------------------------------------------------------------------
opCB10:
	
	READ_B r6
	RL r6, r7
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RL C
@-------------------------------------------------------------------------------
opCB11:
	
	READ_C r6
	RL r6, r7
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RL D
@-------------------------------------------------------------------------------
opCB12:
	
	READ_D r6
	RL r6, r7
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RL E
@-------------------------------------------------------------------------------
opCB13:
	
	READ_E r6
	RL r6, r7
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RL H
@-------------------------------------------------------------------------------
opCB14:
	
	READ_H r6
	RL r6, r7
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RL L
@-------------------------------------------------------------------------------
opCB15:
	
	READ_L r6
	RL r6, r7
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RL (HL)
@-------------------------------------------------------------------------------
opCB16:
	
	READ_HL r6
	READ_8 r7, r6
	RL r7, r8
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RRC A
@-------------------------------------------------------------------------------
opCB0F:
	
	READ_A r6
	RRC r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RRC B
@-------------------------------------------------------------------------------
opCB08:
	
	READ_B r6
	RRC r6
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RRC C
@-------------------------------------------------------------------------------
opCB09:
	
	READ_C r6
	RRC r6
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RRC D
@-------------------------------------------------------------------------------
opCB0A:
	
	READ_D r6
	RRC r6
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RRC E
@-------------------------------------------------------------------------------
opCB0B:
	
	READ_E r6
	RRC r6
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RRC H
@-------------------------------------------------------------------------------
opCB0C:
	
	READ_H r6
	RRC r6
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RRC L
@-------------------------------------------------------------------------------
opCB0D:
	
	READ_L r6
	RRC r6
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RRC (HL)
@-------------------------------------------------------------------------------
opCB0E:
	
	READ_HL r6
	READ_8 r7, r6
	RRC r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RR A
@-------------------------------------------------------------------------------
opCB1F:
	
	READ_A r6
	RR r6, r7
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RR B
@-------------------------------------------------------------------------------
opCB18:
	
	READ_B r6
	RR r6, r7
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RR C
@-------------------------------------------------------------------------------
opCB19:
	
	READ_C r6
	RR r6, r7
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RR D
@-------------------------------------------------------------------------------
opCB1A:
	
	READ_D r6
	RR r6, r7
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RR E
@-------------------------------------------------------------------------------
opCB1B:
	
	READ_E r6
	RR r6, r7
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RR H
@-------------------------------------------------------------------------------
opCB1C:
	
	READ_H r6
	RR r6, r7
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RR L
@-------------------------------------------------------------------------------
opCB1D:
	
	READ_L r6
	RR r6, r7
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RR (HL)
@-------------------------------------------------------------------------------
opCB1E:
	
	READ_HL r6
	READ_8 r7, r6
	RR r7, r8
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SLA A
@-------------------------------------------------------------------------------
opCB27:
	
	READ_A r6
	SLA r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SLA B
@-------------------------------------------------------------------------------
opCB20:
	
	READ_B r6
	SLA r6
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@###############################################################################
	.ltorg
@###############################################################################

@-------------------------------------------------------------------------------
@ SLA C
@-------------------------------------------------------------------------------
opCB21:
	
	READ_C r6
	SLA r6
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SLA D
@-------------------------------------------------------------------------------
opCB22:
	
	READ_D r6
	SLA r6
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SLA E
@-------------------------------------------------------------------------------
opCB23:
	
	READ_E r6
	SLA r6
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SLA H
@-------------------------------------------------------------------------------
opCB24:
	
	READ_H r6
	SLA r6
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SLA L
@-------------------------------------------------------------------------------
opCB25:
	
	READ_L r6
	SLA r6
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SLA (HL)
@-------------------------------------------------------------------------------
opCB26:
	
	READ_HL r6
	READ_8 r7, r6
	SLA r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SRA A
@-------------------------------------------------------------------------------
opCB2F:
	
	READ_A r6
	SRA r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRA B
@-------------------------------------------------------------------------------
opCB28:
	
	READ_B r6
	SRA r6
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRA C
@-------------------------------------------------------------------------------
opCB29:
	
	READ_C r6
	SRA r6
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRA D
@-------------------------------------------------------------------------------
opCB2A:
	
	READ_D r6
	SRA r6
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRA E
@-------------------------------------------------------------------------------
opCB2B:
	
	READ_E r6
	SRA r6
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRA H
@-------------------------------------------------------------------------------
opCB2C:
	
	READ_H r6
	SRA r6
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRA L
@-------------------------------------------------------------------------------
opCB2D:
	
	READ_L r6
	SRA r6
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRA (HL)
@-------------------------------------------------------------------------------
opCB2E:
	
	READ_HL r6
	READ_8 r7, r6
	SRA r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SRL A
@-------------------------------------------------------------------------------
opCB3F:
	
	READ_A r6
	SRL r6
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRL B
@-------------------------------------------------------------------------------
opCB38:
	
	READ_B r6
	SRL r6
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRL C
@-------------------------------------------------------------------------------
opCB39:
	
	READ_C r6
	SRL r6
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRL D
@-------------------------------------------------------------------------------
opCB3A:
	
	READ_D r6
	SRL r6
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRL E
@-------------------------------------------------------------------------------
opCB3B:
	
	READ_E r6
	SRL r6
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRL H
@-------------------------------------------------------------------------------
opCB3C:
	
	READ_H r6
	SRL r6
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRL L
@-------------------------------------------------------------------------------
opCB3D:
	
	READ_L r6
	SRL r6
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SRL (HL)
@-------------------------------------------------------------------------------
opCB3E:
	
	READ_HL r6
	READ_8 r7, r6
	SRL r7
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, A
@-------------------------------------------------------------------------------
opCB47:
	
	READ_A r6
	BIT r6, #0x01
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, B
@-------------------------------------------------------------------------------
opCB40:
	
	READ_B r6
	BIT r6, #0x01
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, C
@-------------------------------------------------------------------------------
opCB41:
	
	READ_C r6
	BIT r6, #0x01
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, D
@-------------------------------------------------------------------------------
opCB42:
	
	READ_D r6
	BIT r6, #0x01
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, E
@-------------------------------------------------------------------------------
opCB43:
	
	READ_E r6
	BIT r6, #0x01
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, H
@-------------------------------------------------------------------------------
opCB44:
	
	READ_H r6
	BIT r6, #0x01
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, L
@-------------------------------------------------------------------------------
opCB45:
	
	READ_L r6
	BIT r6, #0x01
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 0, (HL)
@-------------------------------------------------------------------------------
opCB46:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x01
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, A
@-------------------------------------------------------------------------------
opCB4F:
	
	READ_A r6
	BIT r6, #0x02
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, B
@-------------------------------------------------------------------------------
opCB48:
	
	READ_B r6
	BIT r6, #0x02
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, C
@-------------------------------------------------------------------------------
opCB49:
	
	READ_C r6
	BIT r6, #0x02
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, D
@-------------------------------------------------------------------------------
opCB4A:
	
	READ_D r6
	BIT r6, #0x02
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, E
@-------------------------------------------------------------------------------
opCB4B:
	
	READ_E r6
	BIT r6, #0x02
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, H
@-------------------------------------------------------------------------------
opCB4C:
	
	READ_H r6
	BIT r6, #0x02
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, L
@-------------------------------------------------------------------------------
opCB4D:
	
	READ_L r6
	BIT r6, #0x02
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 1, (HL)
@-------------------------------------------------------------------------------
opCB4E:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x02
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, A
@-------------------------------------------------------------------------------
opCB57:
	
	READ_A r6
	BIT r6, #0x04
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, B
@-------------------------------------------------------------------------------
opCB50:
	
	READ_B r6
	BIT r6, #0x04
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, C
@-------------------------------------------------------------------------------
opCB51:
	
	READ_C r6
	BIT r6, #0x04
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, D
@-------------------------------------------------------------------------------
opCB52:
	
	READ_D r6
	BIT r6, #0x04
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, E
@-------------------------------------------------------------------------------
opCB53:
	
	READ_E r6
	BIT r6, #0x04
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, H
@-------------------------------------------------------------------------------
opCB54:
	
	READ_H r6
	BIT r6, #0x04
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, L
@-------------------------------------------------------------------------------
opCB55:
	
	READ_L r6
	BIT r6, #0x04
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 2, (HL)
@-------------------------------------------------------------------------------
opCB56:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x04
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, A
@-------------------------------------------------------------------------------
opCB5F:
	
	READ_A r6
	BIT r6, #0x08
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, B
@-------------------------------------------------------------------------------
opCB58:
	
	READ_B r6
	BIT r6, #0x08
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, C
@-------------------------------------------------------------------------------
opCB59:
	
	READ_C r6
	BIT r6, #0x08
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, D
@-------------------------------------------------------------------------------
opCB5A:
	
	READ_D r6
	BIT r6, #0x08
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, E
@-------------------------------------------------------------------------------
opCB5B:
	
	READ_E r6
	BIT r6, #0x08
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, H
@-------------------------------------------------------------------------------
opCB5C:
	
	READ_H r6
	BIT r6, #0x08
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, L
@-------------------------------------------------------------------------------
opCB5D:
	
	READ_L r6
	BIT r6, #0x08
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 3, (HL)
@-------------------------------------------------------------------------------
opCB5E:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x08
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, A
@-------------------------------------------------------------------------------
opCB67:
	
	READ_A r6
	BIT r6, #0x10
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, B
@-------------------------------------------------------------------------------
opCB60:
	
	READ_B r6
	BIT r6, #0x10
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, C
@-------------------------------------------------------------------------------
opCB61:
	
	READ_C r6
	BIT r6, #0x10
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, D
@-------------------------------------------------------------------------------
opCB62:
	
	READ_D r6
	BIT r6, #0x10
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, E
@-------------------------------------------------------------------------------
opCB63:
	
	READ_E r6
	BIT r6, #0x10
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, H
@-------------------------------------------------------------------------------
opCB64:
	
	READ_H r6
	BIT r6, #0x10
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, L
@-------------------------------------------------------------------------------
opCB65:
	
	READ_L r6
	BIT r6, #0x10
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 4, (HL)
@-------------------------------------------------------------------------------
opCB66:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x10
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, A
@-------------------------------------------------------------------------------
opCB6F:
	
	READ_A r6
	BIT r6, #0x20
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, B
@-------------------------------------------------------------------------------
opCB68:
	
	READ_B r6
	BIT r6, #0x20
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, C
@-------------------------------------------------------------------------------
opCB69:
	
	READ_C r6
	BIT r6, #0x20
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, D
@-------------------------------------------------------------------------------
opCB6A:
	
	READ_D r6
	BIT r6, #0x20
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, E
@-------------------------------------------------------------------------------
opCB6B:
	
	READ_E r6
	BIT r6, #0x20
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, H
@-------------------------------------------------------------------------------
opCB6C:
	
	READ_H r6
	BIT r6, #0x20
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, L
@-------------------------------------------------------------------------------
opCB6D:
	
	READ_L r6
	BIT r6, #0x20
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 5, (HL)
@-------------------------------------------------------------------------------
opCB6E:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x20
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, A
@-------------------------------------------------------------------------------
opCB77:
	
	READ_A r6
	BIT r6, #0x40
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, B
@-------------------------------------------------------------------------------
opCB70:
	
	READ_B r6
	BIT r6, #0x40
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, C
@-------------------------------------------------------------------------------
opCB71:
	
	READ_C r6
	BIT r6, #0x40
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, D
@-------------------------------------------------------------------------------
opCB72:
	
	READ_D r6
	BIT r6, #0x40
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, E
@-------------------------------------------------------------------------------
opCB73:
	
	READ_E r6
	BIT r6, #0x40
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, H
@-------------------------------------------------------------------------------
opCB74:
	
	READ_H r6
	BIT r6, #0x40
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, L
@-------------------------------------------------------------------------------
opCB75:
	
	READ_L r6
	BIT r6, #0x40
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 6, (HL)
@-------------------------------------------------------------------------------
opCB76:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x40
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, A
@-------------------------------------------------------------------------------
opCB7F:
	
	READ_A r6
	BIT r6, #0x80
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, B
@-------------------------------------------------------------------------------
opCB78:
	
	READ_B r6
	BIT r6, #0x80
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, C
@-------------------------------------------------------------------------------
opCB79:
	
	READ_C r6
	BIT r6, #0x80
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, D
@-------------------------------------------------------------------------------
opCB7A:
	
	READ_D r6
	BIT r6, #0x80
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, E
@-------------------------------------------------------------------------------
opCB7B:
	
	READ_E r6
	BIT r6, #0x80
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, H
@-------------------------------------------------------------------------------
opCB7C:
	
	READ_H r6
	BIT r6, #0x80
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, L
@-------------------------------------------------------------------------------
opCB7D:
	
	READ_L r6
	BIT r6, #0x80
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ BIT 7, (HL)
@-------------------------------------------------------------------------------
opCB7E:
	
	READ_HL r6
	READ_8 r7, r6
	BIT r7, #0x80
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, A
@-------------------------------------------------------------------------------
opCB87:
	
	READ_A r6
	RES r6, #0x01
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, B
@-------------------------------------------------------------------------------
opCB80:
	
	READ_B r6
	RES r6, #0x01
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, C
@-------------------------------------------------------------------------------
opCB81:
	
	READ_C r6
	RES r6, #0x01
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, D
@-------------------------------------------------------------------------------
opCB82:
	
	READ_D r6
	RES r6, #0x01
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, E
@-------------------------------------------------------------------------------
opCB83:
	
	READ_E r6
	RES r6, #0x01
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, H
@-------------------------------------------------------------------------------
opCB84:
	
	READ_H r6
	RES r6, #0x01
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, L
@-------------------------------------------------------------------------------
opCB85:
	
	READ_L r6
	RES r6, #0x01
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 0, (HL)
@-------------------------------------------------------------------------------
opCB86:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x01
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 1, A
@-------------------------------------------------------------------------------
opCB8F:
	
	READ_A r6
	RES r6, #0x02
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 1, B
@-------------------------------------------------------------------------------
opCB88:
	
	READ_B r6
	RES r6, #0x02
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@###############################################################################
	.ltorg
@###############################################################################

@-------------------------------------------------------------------------------
@ RES 1, C
@-------------------------------------------------------------------------------
opCB89:
	
	READ_C r6
	RES r6, #0x02
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 1, D
@-------------------------------------------------------------------------------
opCB8A:
	
	READ_D r6
	RES r6, #0x02
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 1, E
@-------------------------------------------------------------------------------
opCB8B:
	
	READ_E r6
	RES r6, #0x02
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 1, H
@-------------------------------------------------------------------------------
opCB8C:
	
	READ_H r6
	RES r6, #0x02
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 1, L
@-------------------------------------------------------------------------------
opCB8D:
	
	READ_L r6
	RES r6, #0x02
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 1, (HL)
@-------------------------------------------------------------------------------
opCB8E:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x02
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, A
@-------------------------------------------------------------------------------
opCB97:
	
	READ_A r6
	RES r6, #0x04
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, B
@-------------------------------------------------------------------------------
opCB90:
	
	READ_B r6
	RES r6, #0x04
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, C
@-------------------------------------------------------------------------------
opCB91:
	
	READ_C r6
	RES r6, #0x04
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, D
@-------------------------------------------------------------------------------
opCB92:
	
	READ_D r6
	RES r6, #0x04
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, E
@-------------------------------------------------------------------------------
opCB93:
	
	READ_E r6
	RES r6, #0x04
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, H
@-------------------------------------------------------------------------------
opCB94:
	
	READ_H r6
	RES r6, #0x04
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, L
@-------------------------------------------------------------------------------
opCB95:
	
	READ_L r6
	RES r6, #0x04
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 2, (HL)
@-------------------------------------------------------------------------------
opCB96:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x04
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, A
@-------------------------------------------------------------------------------
opCB9F:
	
	READ_A r6
	RES r6, #0x08
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, B
@-------------------------------------------------------------------------------
opCB98:
	
	READ_B r6
	RES r6, #0x08
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, C
@-------------------------------------------------------------------------------
opCB99:
	
	READ_C r6
	RES r6, #0x08
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, D
@-------------------------------------------------------------------------------
opCB9A:
	
	READ_D r6
	RES r6, #0x08
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, E
@-------------------------------------------------------------------------------
opCB9B:
	
	READ_E r6
	RES r6, #0x08
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, H
@-------------------------------------------------------------------------------
opCB9C:
	
	READ_H r6
	RES r6, #0x08
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, L
@-------------------------------------------------------------------------------
opCB9D:
	
	READ_L r6
	RES r6, #0x08
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 3, (HL)
@-------------------------------------------------------------------------------
opCB9E:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x08
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, A
@-------------------------------------------------------------------------------
opCBA7:
	
	READ_A r6
	RES r6, #0x10
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, B
@-------------------------------------------------------------------------------
opCBA0:
	
	READ_B r6
	RES r6, #0x10
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, C
@-------------------------------------------------------------------------------
opCBA1:
	
	READ_C r6
	RES r6, #0x10
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, D
@-------------------------------------------------------------------------------
opCBA2:
	
	READ_D r6
	RES r6, #0x10
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, E
@-------------------------------------------------------------------------------
opCBA3:
	
	READ_E r6
	RES r6, #0x10
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, H
@-------------------------------------------------------------------------------
opCBA4:
	
	READ_H r6
	RES r6, #0x10
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, L
@-------------------------------------------------------------------------------
opCBA5:
	
	READ_L r6
	RES r6, #0x10
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 4, (HL)
@-------------------------------------------------------------------------------
opCBA6:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x10
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, A
@-------------------------------------------------------------------------------
opCBAF:
	
	READ_A r6
	RES r6, #0x20
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, B
@-------------------------------------------------------------------------------
opCBA8:
	
	READ_B r6
	RES r6, #0x20
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, C
@-------------------------------------------------------------------------------
opCBA9:
	
	READ_C r6
	RES r6, #0x20
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, D
@-------------------------------------------------------------------------------
opCBAA:
	
	READ_D r6
	RES r6, #0x20
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, E
@-------------------------------------------------------------------------------
opCBAB:
	
	READ_E r6
	RES r6, #0x20
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, H
@-------------------------------------------------------------------------------
opCBAC:
	
	READ_H r6
	RES r6, #0x20
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, L
@-------------------------------------------------------------------------------
opCBAD:
	
	READ_L r6
	RES r6, #0x20
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 5, (HL)
@-------------------------------------------------------------------------------
opCBAE:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x20
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, A
@-------------------------------------------------------------------------------
opCBB7:
	
	READ_A r6
	RES r6, #0x40
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, B
@-------------------------------------------------------------------------------
opCBB0:
	
	READ_B r6
	RES r6, #0x40
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, C
@-------------------------------------------------------------------------------
opCBB1:
	
	READ_C r6
	RES r6, #0x40
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, D
@-------------------------------------------------------------------------------
opCBB2:
	
	READ_D r6
	RES r6, #0x40
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, E
@-------------------------------------------------------------------------------
opCBB3:
	
	READ_E r6
	RES r6, #0x40
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, H
@-------------------------------------------------------------------------------
opCBB4:
	
	READ_H r6
	RES r6, #0x40
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, L
@-------------------------------------------------------------------------------
opCBB5:
	
	READ_L r6
	RES r6, #0x40
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 6, (HL)
@-------------------------------------------------------------------------------
opCBB6:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x40
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, A
@-------------------------------------------------------------------------------
opCBBF:
	
	READ_A r6
	RES r6, #0x80
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, B
@-------------------------------------------------------------------------------
opCBB8:
	
	READ_B r6
	RES r6, #0x80
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, C
@-------------------------------------------------------------------------------
opCBB9:
	
	READ_C r6
	RES r6, #0x80
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, D
@-------------------------------------------------------------------------------
opCBBA:
	
	READ_D r6
	RES r6, #0x80
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, E
@-------------------------------------------------------------------------------
opCBBB:
	
	READ_E r6
	RES r6, #0x80
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, H
@-------------------------------------------------------------------------------
opCBBC:
	
	READ_H r6
	RES r6, #0x80
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, L
@-------------------------------------------------------------------------------
opCBBD:
	
	READ_L r6
	RES r6, #0x80
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ RES 7, (HL)
@-------------------------------------------------------------------------------
opCBBE:
	
	READ_HL r6
	READ_8 r7, r6
	RES r7, #0x80
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, A
@-------------------------------------------------------------------------------
opCBC7:
	
	READ_A r6
	SET r6, #0x01
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, B
@-------------------------------------------------------------------------------
opCBC0:
	
	READ_B r6
	SET r6, #0x01
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, C
@-------------------------------------------------------------------------------
opCBC1:
	
	READ_C r6
	SET r6, #0x01
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, D
@-------------------------------------------------------------------------------
opCBC2:
	
	READ_D r6
	SET r6, #0x01
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, E
@-------------------------------------------------------------------------------
opCBC3:
	
	READ_E r6
	SET r6, #0x01
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, H
@-------------------------------------------------------------------------------
opCBC4:
	
	READ_H r6
	SET r6, #0x01
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, L
@-------------------------------------------------------------------------------
opCBC5:
	
	READ_L r6
	SET r6, #0x01
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 0, (HL)
@-------------------------------------------------------------------------------
opCBC6:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x01
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, A
@-------------------------------------------------------------------------------
opCBCF:
	
	READ_A r6
	SET r6, #0x02
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, B
@-------------------------------------------------------------------------------
opCBC8:
	
	READ_B r6
	SET r6, #0x02
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, C
@-------------------------------------------------------------------------------
opCBC9:
	
	READ_C r6
	SET r6, #0x02
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, D
@-------------------------------------------------------------------------------
opCBCA:
	
	READ_D r6
	SET r6, #0x02
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, E
@-------------------------------------------------------------------------------
opCBCB:
	
	READ_E r6
	SET r6, #0x02
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, H
@-------------------------------------------------------------------------------
opCBCC:
	
	READ_H r6
	SET r6, #0x02
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, L
@-------------------------------------------------------------------------------
opCBCD:
	
	READ_L r6
	SET r6, #0x02
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 1, (HL)
@-------------------------------------------------------------------------------
opCBCE:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x02
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, A
@-------------------------------------------------------------------------------
opCBD7:
	
	READ_A r6
	SET r6, #0x04
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, B
@-------------------------------------------------------------------------------
opCBD0:
	
	READ_B r6
	SET r6, #0x04
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, C
@-------------------------------------------------------------------------------
opCBD1:
	
	READ_C r6
	SET r6, #0x04
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, D
@-------------------------------------------------------------------------------
opCBD2:
	
	READ_D r6
	SET r6, #0x04
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, E
@-------------------------------------------------------------------------------
opCBD3:
	
	READ_E r6
	SET r6, #0x04
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, H
@-------------------------------------------------------------------------------
opCBD4:
	
	READ_H r6
	SET r6, #0x04
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, L
@-------------------------------------------------------------------------------
opCBD5:
	
	READ_L r6
	SET r6, #0x04
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 2, (HL)
@-------------------------------------------------------------------------------
opCBD6:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x04
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, A
@-------------------------------------------------------------------------------
opCBDF:
	
	READ_A r6
	SET r6, #0x08
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, B
@-------------------------------------------------------------------------------
opCBD8:
	
	READ_B r6
	SET r6, #0x08
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, C
@-------------------------------------------------------------------------------
opCBD9:
	
	READ_C r6
	SET r6, #0x08
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, D
@-------------------------------------------------------------------------------
opCBDA:
	
	READ_D r6
	SET r6, #0x08
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, E
@-------------------------------------------------------------------------------
opCBDB:
	
	READ_E r6
	SET r6, #0x08
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, H
@-------------------------------------------------------------------------------
opCBDC:
	
	READ_H r6
	SET r6, #0x08
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, L
@-------------------------------------------------------------------------------
opCBDD:
	
	READ_L r6
	SET r6, #0x08
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 3, (HL)
@-------------------------------------------------------------------------------
opCBDE:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x08
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 4, A
@-------------------------------------------------------------------------------
opCBE7:
	
	READ_A r6
	SET r6, #0x10
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 4, B
@-------------------------------------------------------------------------------
opCBE0:
	
	READ_B r6
	SET r6, #0x10
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 4, C
@-------------------------------------------------------------------------------
opCBE1:
	
	READ_C r6
	SET r6, #0x10
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@###############################################################################
	.ltorg
@###############################################################################

@-------------------------------------------------------------------------------
@ SET 4, D
@-------------------------------------------------------------------------------
opCBE2:
	
	READ_D r6
	SET r6, #0x10
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 4, E
@-------------------------------------------------------------------------------
opCBE3:
	
	READ_E r6
	SET r6, #0x10
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 4, H
@-------------------------------------------------------------------------------
opCBE4:
	
	READ_H r6
	SET r6, #0x10
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 4, L
@-------------------------------------------------------------------------------
opCBE5:
	
	READ_L r6
	SET r6, #0x10
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 4, (HL)
@-------------------------------------------------------------------------------
opCBE6:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x10
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, A
@-------------------------------------------------------------------------------
opCBEF:
	
	READ_A r6
	SET r6, #0x20
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, B
@-------------------------------------------------------------------------------
opCBE8:
	
	READ_B r6
	SET r6, #0x20
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, C
@-------------------------------------------------------------------------------
opCBE9:
	
	READ_C r6
	SET r6, #0x20
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, D
@-------------------------------------------------------------------------------
opCBEA:
	
	READ_D r6
	SET r6, #0x20
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, E
@-------------------------------------------------------------------------------
opCBEB:
	
	READ_E r6
	SET r6, #0x20
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, H
@-------------------------------------------------------------------------------
opCBEC:
	
	READ_H r6
	SET r6, #0x20
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, L
@-------------------------------------------------------------------------------
opCBED:
	
	READ_L r6
	SET r6, #0x20
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 5, (HL)
@-------------------------------------------------------------------------------
opCBEE:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x20
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, A
@-------------------------------------------------------------------------------
opCBF7:
	
	READ_A r6
	SET r6, #0x40
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, B
@-------------------------------------------------------------------------------
opCBF0:
	
	READ_B r6
	SET r6, #0x40
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, C
@-------------------------------------------------------------------------------
opCBF1:
	
	READ_C r6
	SET r6, #0x40
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, D
@-------------------------------------------------------------------------------
opCBF2:
	
	READ_D r6
	SET r6, #0x40
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, E
@-------------------------------------------------------------------------------
opCBF3:
	
	READ_E r6
	SET r6, #0x40
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, H
@-------------------------------------------------------------------------------
opCBF4:
	
	READ_H r6
	SET r6, #0x40
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, L
@-------------------------------------------------------------------------------
opCBF5:
	
	READ_L r6
	SET r6, #0x40
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 6, (HL)
@-------------------------------------------------------------------------------
opCBF6:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x40
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, A
@-------------------------------------------------------------------------------
opCBFF:
	
	READ_A r6
	SET r6, #0x80
	SET_A r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, B
@-------------------------------------------------------------------------------
opCBF8:
	
	READ_B r6
	SET r6, #0x80
	SET_B r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, C
@-------------------------------------------------------------------------------
opCBF9:
	
	READ_C r6
	SET r6, #0x80
	SET_C r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, D
@-------------------------------------------------------------------------------
opCBFA:
	
	READ_D r6
	SET r6, #0x80
	SET_D r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, E
@-------------------------------------------------------------------------------
opCBFB:
	
	READ_E r6
	SET r6, #0x80
	SET_E r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, H
@-------------------------------------------------------------------------------
opCBFC:
	
	READ_H r6
	SET r6, #0x80
	SET_H r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, L
@-------------------------------------------------------------------------------
opCBFD:
	
	READ_L r6
	SET r6, #0x80
	SET_L r6
	UPDATE_CYCLE_COUNT 2
	bx lr

@-------------------------------------------------------------------------------
@ SET 7, (HL)
@-------------------------------------------------------------------------------
opCBFE:
	
	READ_HL r6
	READ_8 r7, r6
	SET r7, #0x80
	WRITE_8 r7, r6
	UPDATE_CYCLE_COUNT 4
	bx lr


@@@@@@@@@@@@@
	.data
@@@@@@@@@@@@@

@-------------------------------------------------------------------------------
@ Gameboy Processor State
@-------------------------------------------------------------------------------
ProcessorState:
	.global ProcessorState

    .word 0x001301B0	@ B,C,A,F
    .word 0x00D8014D	@ D,E,H,L
    .word 0x0000FFFE	@ SP
    .word 0x00000100	@ PC (initially set to 0x100)
    .word 0x00000000	@ Frame cycle count (overflow from last frame)
	.word 0x00000000	@ IME Flag
	.word 0x00000000	@ DIV timer cycle count
	.word 0x00000000	@ Timer cycle count

RequestedVBlank:
	.word 0

@-------------------------------------------------------------------------------
@ Interrupts
@-------------------------------------------------------------------------------
InterruptPriority:
	.word 0x00, 0x01, 0x02, 0x01, 0x04, 0x01, 0x02, 0x01, 0x08, 0x01, 0x02, 0x01, 0x04, 0x01, 0x02, 0x01
	.word 0x10, 0x01, 0x02, 0x01, 0x04, 0x01, 0x02, 0x01, 0x08, 0x01, 0x02, 0x01, 0x04, 0x01, 0x02, 0x01

InterruptVector:
	.word 0x00, 0x40, 0x48, 0x00, 0x50, 0x00, 0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60

@-------------------------------------------------------------------------------
@ Opcode Function Jump Table
@-------------------------------------------------------------------------------
OpcodeJT:

    .word op00, op01, op02, op03, op04, op05, op06, op07, op08, op09, op0A, op0B, op0C, op0D, op0E, op0F
    .word op__, op11, op12, op13, op14, op15, op16, op17, op18, op19, op1A, op1B, op1C, op1D, op1E, op1F
    .word op20, op21, op22, op23, op24, op25, op26, op27, op28, op29, op2A, op2B, op2C, op2D, op2E, op2F
    .word op30, op31, op32, op33, op34, op35, op36, op37, op38, op39, op3A, op3B, op3C, op3D, op3E, op3F
    .word op40, op41, op42, op43, op44, op45, op46, op47, op48, op49, op4A, op4B, op4C, op4D, op4E, op4F
    .word op50, op51, op52, op53, op54, op55, op56, op57, op58, op59, op5A, op5B, op5C, op5D, op5E, op5F
    .word op60, op61, op62, op63, op64, op65, op66, op67, op68, op69, op6A, op6B, op6C, op6D, op6E, op6F
    .word op70, op71, op72, op73, op74, op75, op__, op77, op78, op79, op7A, op7B, op7C, op7D, op7E, op7F
    .word op80, op81, op82, op86, op84, op85, op86, op87, op88, op89, op8A, op8B, op8C, op8D, op8E, op8F
    .word op90, op91, op92, op93, op94, op95, op96, op97, op98, op99, op9A, op9B, op9C, op9D, op9E, op9F
    .word opA0, opA1, opA2, opA3, opA4, opA5, opA6, opA7, opA8, opA9, opAA, opAB, opAC, opAD, opAE, opAF
    .word opB0, opB1, opB2, opB3, opB4, opB5, opB6, opB7, opB8, opB9, opBA, opBB, opBC, opBD, opBE, opBF
    .word opC0, opC1, opC2, opC3, opC4, opC5, opC6, opC7, opC8, opC9, opCA, opCB, opCC, opCD, opCE, opCF
    .word opD0, opD1, opD2, opXX, opD4, opD5, opD6, opD7, opD8, opD9, opDA, opXX, opDC, opXX, opDE, opDF
    .word opE0, opE1, opE2, opXX, opXX, opE5, opE6, opE7, opE8, opE9, opEA, opXX, opXX, opXX, opEE, opEF
    .word opF0, opF1, opF2, opF3, opXX, opF5, opF6, opF7, opF8, opF9, opFA, opFB, opXX, opXX, opFE, opFF

	@ TODO
	@	op10: STOP
	@	op76: HALT

@-------------------------------------------------------------------------------
@ CB Opcode Function Jump Table
@-------------------------------------------------------------------------------
CBOpcodeJT:

    .word opCB00, opCB01, opCB02, opCB03, opCB04, opCB05, opCB06, opCB07, opCB08, opCB09, opCB0A, opCB0B, opCB0C, opCB0D, opCB0E, opCB0F
    .word opCB10, opCB11, opCB12, opCB13, opCB14, opCB15, opCB16, opCB17, opCB18, opCB19, opCB1A, opCB1B, opCB1C, opCB1D, opCB1E, opCB1F
    .word opCB20, opCB21, opCB22, opCB23, opCB24, opCB25, opCB26, opCB27, opCB28, opCB29, opCB2A, opCB2B, opCB2C, opCB2D, opCB2E, opCB2F
    .word opCB30, opCB31, opCB32, opCB33, opCB34, opCB35, opCB36, opCB37, opCB38, opCB39, opCB3A, opCB3B, opCB3C, opCB3D, opCB3E, opCB3F
    .word opCB40, opCB41, opCB42, opCB43, opCB44, opCB45, opCB46, opCB47, opCB48, opCB49, opCB4A, opCB4B, opCB4C, opCB4D, opCB4E, opCB4F
    .word opCB50, opCB51, opCB52, opCB53, opCB54, opCB55, opCB56, opCB57, opCB58, opCB59, opCB5A, opCB5B, opCB5C, opCB5D, opCB5E, opCB5F
    .word opCB60, opCB61, opCB62, opCB63, opCB64, opCB65, opCB66, opCB67, opCB68, opCB69, opCB6A, opCB6B, opCB6C, opCB6D, opCB6E, opCB6F
    .word opCB70, opCB71, opCB72, opCB73, opCB74, opCB75, opCB76, opCB77, opCB78, opCB79, opCB7A, opCB7B, opCB7C, opCB7D, opCB7E, opCB7F
    .word opCB80, opCB81, opCB82, opCB83, opCB84, opCB85, opCB86, opCB87, opCB88, opCB89, opCB8A, opCB8B, opCB8C, opCB8D, opCB8E, opCB8F
    .word opCB90, opCB91, opCB92, opCB93, opCB94, opCB95, opCB96, opCB97, opCB98, opCB99, opCB9A, opCB9B, opCB9C, opCB9D, opCB9E, opCB9F
    .word opCBA0, opCBA1, opCBA2, opCBA3, opCBA4, opCBA5, opCBA6, opCBA7, opCBA8, opCBA9, opCBAA, opCBAB, opCBAC, opCBAD, opCBAE, opCBAF
    .word opCBB0, opCBB1, opCBB2, opCBB3, opCBB4, opCBB5, opCBB6, opCBB7, opCBB8, opCBB9, opCBBA, opCBBB, opCBBC, opCBBD, opCBBE, opCBBF
    .word opCBC0, opCBC1, opCBC2, opCBC3, opCBC4, opCBC5, opCBC6, opCBC7, opCBC8, opCBC9, opCBCA, opCBCB, opCBCC, opCBCD, opCBCE, opCBCF
    .word opCBD0, opCBD1, opCBD2, opCBD3, opCBD4, opCBD5, opCBD6, opCBD7, opCBD8, opCBD9, opCBDA, opCBDB, opCBDC, opCBDD, opCBDE, opCBDF
    .word opCBE0, opCBE1, opCBE2, opCBE3, opCBE4, opCBE5, opCBE6, opCBE7, opCBE8, opCBE9, opCBEA, opCBEB, opCBEC, opCBED, opCBEE, opCBEF
    .word opCBF0, opCBF1, opCBF2, opCBF3, opCBF4, opCBF5, opCBF6, opCBF7, opCBF8, opCBF9, opCBFA, opCBFB, opCBFC, opCBFD, opCBFE, opCBFF