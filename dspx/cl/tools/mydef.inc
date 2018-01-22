CR		EQU	13
LF		EQU	10

movseg		MACRO	p1,p2
	push	p2
	pop	p1
ENDM

xchgseg		MACRO	p1,p2
	push	p1
	push	p2
	pop	p1
	pop	p2
ENDM

pushm		MACRO	p1
	IRP	p2,<p1>
		push	p2
	ENDM
ENDM

popm		MACRO	p1
	IRP	p2,<p1>
		pop	p2
	ENDM
ENDM

jmps		MACRO	p1
	jmp	short p1
ENDM

_retf		MACRO
		db	0cbh
ENDM
