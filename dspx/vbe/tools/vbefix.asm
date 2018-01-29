COMMENT #
===============================================================================
 vbefix.asm
===============================================================================
#

MAJOR		EQU	0
MINOR		EQU	00h

CR		EQU	13
LF		EQU	10
eos		EQU	'$'

jmps		MACRO	p1
	jmp	short p1
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


_TEXT		SEGMENT BYTE
_TEXT		ENDS
		IFDEF	??version
		NOWARN	RES
		ENDIF
STACK		SEGMENT PARA STACK 'STACK'
STACK		ENDS
		IFDEF	??version
		WARN	RES
		ENDIF

STACK		SEGMENT
	dw	128 dup (?)
STACK		ENDS

		ASSUME	cs:_TEXT, ds:_TEXT

_TEXT		SEGMENT

		ORG	0

		dd	-1
		dw	8000h
		dw	Strategy
pCommands	dw	Init_Commands
sName		db	'$VBEFIX$'
		db	'LPPROJ$$'
cName = ($ - sName)
MySeg		dw	0
Org10		dd	?
reqhdr		dd	?

New10		PROC	FAR
	cmp	ax,4f01h
	je	new10_v
new10_org:
	jmp	cs:[Org10]
;
new10_v:
	push	bp
	push	ax	;[bp+10]
	push	cx	;[bp+8]
	push	ds	;[bp+6]
	push	si	;[bp+4]
	push	es	;[bp+2]
	push	di	;[bp]
	cld
	mov	bp,sp
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	di,offset VbeInfo
	mov	word ptr [di],0
	mov	ax,4f00h
	pushf
	call	[Org10]
	cld
	mov	cx,word ptr ss:[bp+8]
	mov	ax,cs
	mov	es,ax
	mov	di,offset VbeInfo
	mov	si,di
	mov	ax,4f01h
	pushf
	call	[Org10]
	mov	word ptr ss:[bp+10],ax
	cld
	mov	si,offset VbeInfo
	les	di,dword ptr ss:[bp]
	mov	cx,128
	rep	movsw
	pop	di
	pop	es
	pop	si
	pop	ds
	pop	cx
	pop	ax
	pop	bp
	iret
New10		ENDP


Strategy	PROC	FAR
	mov	word ptr cs:[reqhdr],bx
	mov	word ptr cs:[reqhdr+2],es
	ret
Strategy	ENDP

Commands	PROC	FAR
	pushm	<bx,ds>
	lds	bx,cs:[reqhdr]
	mov	word ptr [bx+3],8103h
	popm	<ds,bx>
	ret
Commands	ENDP


ExeEntry	PROC	FAR
	mov	ax,4c00h
	int	21h
ExeEntry	ENDP


VbeInfo		db	256 dup (?)

Dev_Bottom	LABEL	NEAR
;------------------------------------------------------------------------------


pmsg		PROC	NEAR
	push	ax
	mov	ah,9
	int	21h
	pop	ax
	ret
pmsg		ENDP

Init_Commands	PROC	FAR
	pushf
	pushm	<ax,bx,dx,ds,es>
	mov	ax,cs
	mov	ds,ax
	
	mov	ax,3510h
	int	21h
	mov	word ptr [Org10],bx
	mov	word ptr [Org10+2],es
	
	mov	dx,offset New10
	mov	ax,2510h
	int	21h
	
	lds	bx,[reqhdr]
	mov	byte ptr [bx+13],1
	mov	word ptr [bx+14],offset Dev_Bottom
	mov	word ptr [bx+16],cs
	mov	word ptr [bx+3],0100h
	mov	cs:[pCommands],offset Commands
	
	popm	<es,ds,dx,bx,ax>
	popf
	ret
Init_Commands	ENDP


_TEXT		ENDS

		END	ExeEntry


