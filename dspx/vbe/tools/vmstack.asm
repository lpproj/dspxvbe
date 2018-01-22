COMMENT #
===============================================================================
 vmstack.asm
 by sava/LP-Project. 1996
===============================================================================
#


MAJOR		EQU	1
MINOR		EQU	00h
STACK_LIMIT	EQU	4096

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


_TEXT		SEGMENT PARA PUBLIC
_TEXT		ENDS
STK_TEXT	SEGMENT PARA PUBLIC
STK_TEXT	ENDS
INIT_TEXT	SEGMENT BYTE PUBLIC
INIT_TEXT	ENDS
STACK		SEGMENT PARA STACK
STACK		ENDS

CGROUP		group _TEXT, STK_TEXT, INIT_TEXT
ofs		EQU	offset CGROUP:
		ASSUME	cs:CGROUP, ds:CGROUP, es:CGROUP


_TEXT		SEGMENT
	ORG	0
	
		dd	-1
		dw	8000h
		dw	ofs Strategy
pCommands	dw	ofs Init_Commands
pName		db	'$VMSTK$$'
MyVer		db	MAJOR, MINOR

reqhdr		dd	?
prevstk		dd	-1
		dd	?

New10		PROC	FAR
	or	ah,ah
	jz	new10_vm
	cmp	ax,4f02h
	je	new10_vm
new10_chain:
		db	0eah	; jmp ssss:oooo
Org10		dd	?
;
;new10_vm:
;	cmp	word ptr cs:[prevstk+2],-1
;	je	new10_vm_chg
;	pushf
;	call	cs:[Org10]
;	retf	2
	
new10_vm:
	push	bp
	mov	word ptr cs:[prevstk],sp
	mov	word ptr cs:[prevstk+2],ss
	cli
	mov	bp,cs
	mov	ss,bp
	mov	sp,ofs stk_bottom
	sti
	nop
	pushf
	call	cs:[Org10]
	cli
	mov	bp,word ptr cs:[prevstk+2]
	mov	ss,bp
	mov	sp,word ptr cs:[prevstk]
	mov	bp,-1
	mov	word ptr cs:[prevstk],bp
	mov	word ptr cs:[prevstk+2],bp
	nop
	sti
	pop	bp
	retf	2
New10		ENDP

Strategy	PROC	FAR
	mov	word ptr cs:[reqhdr],bx
	mov	word ptr cs:[reqhdr+2],es
	ret
Strategy	ENDP

Commands	PROC	FAR
	pushm	<bx,ds>
	lds	bx,cs:[reqhdr]
	mov	word ptr [bx+3],8103h		; なんにでもエラーを返す 
	popm	<ds,bx>
	ret
Commands	ENDP



_TEXT		ENDS
STK_TEXT	SEGMENT
stk_top		LABEL	WORD
		dw	STACK_LIMIT dup (0ffffh)
stk_bottom	LABEL	WORD
STK_TEXT	ENDS

INIT_TEXT	SEGMENT

pchr		PROC	NEAR
	pushm	<ax,dx>
	mov	dl,al
	mov	ah,2
	int	21h
	popm	<dx,ax>
	ret
pchr		ENDP

pn		PROC	NEAR
	push	ax
	mov	al,CR
	call	pchr
	mov	al,LF
	call	pchr
	pop	ax
	ret
pn		ENDP

pln		PROC	NEAR
	push	ax
	mov	ah,9
	int	21h
	pop	ax
	ret
pln		ENDP

PrnVer		PROC	NEAR
	push	ax
	mov	cl,4
	mov	dx,ofs msgVer
	call	pln
	add	al,'0'
	call	pchr
	mov	al,'.'
	call	pchr
	mov	al,ah
	shr	al,cl
	add	al,'0'
	call	pchr
	mov	al,ah
	and	al,15
	add	al,'0'
	call	pchr
	pop	ax
	ret
PrnVer		ENDP

PrnMyName	PROC	NEAR
	mov	ax,word ptr cs:[MyVer]
	call	PrnVer
	mov	dx,ofs msgAuthor
	call	pln
	call	pn
	ret
PrnMyName	ENDP


Init_Commands	PROC	FAR
	pushf
	pushm	<ax,bx,dx,ds,es>
	cld
	mov	ax,cs
	mov	ds,ax
	call	PrnMyName
	mov	ax,3510h
	int	21h
	mov	word ptr [Org10],bx
	mov	word ptr [Org10+2],es
	mov	dx,ofs New10
	mov	ax,2510h
	int	21h
	lds	bx,[reqhdr]
	mov	byte ptr [bx+13],1
	mov	word ptr [bx+14],offset stk_bottom
	mov	word ptr [bx+16],cs
	mov	word ptr cs:[pCommands],offset Commands
	mov	word ptr [bx+3],0100h
	popm	<es,ds,dx,bx,ax>
	popf
	ret
Init_Commands	ENDP

Exe_Main	PROC	FAR
	cld
	mov	ax,cs
	mov	ds,ax
	call	PrnMyName
	mov	dx,ofs errNotCmd
	call	pln
	mov	ax,4c01h
	int	21h
Exe_Main	ENDP

msgVer		db	'VMSTACK '
	IFDEF	DEBUG
		db	' (DEBUG) '
	ENDIF
		db	'Ver ',eos
msgAuthor	db	' (c)sava/LP-Project. 1996',eos

errNotCmd	db	'えーっと、これはデバイスドライバですので'
		db	'実行できません。ではさようなら。',CR,LF,eos

INIT_TEXT	ENDS
STACK		SEGMENT
		dw	128 dup (?)
STACK		ENDS

	END	Exe_Main
