COMMENT #
===============================================================================
 clwrap64.asm
===============================================================================
#

		INCLUDE mydef.inc

MAJOR		EQU	0
MINOR		EQU	00h

_TEXT		SEGMENT WORD PUBLIC
	ASSUME	cs:_TEXT, ds:_TEXT, ss:_TEXT
	ORG	0
top:
		dd	-1
DevAttr		dw	8000h
		dw	Strategy
DevCommands	dw	Init_Commands
		db	'$$CLWRAP'
		db	MAJOR, MINOR

New10		PROC	FAR
	cmp	ah,00h
	je	new10_chg
new10_jorg:
	db	0eah		; jmp xxxx:yyyy
Org10	dd	?
;
new10_chg:
	cmp	al,92h
	jnz	new10_chg_2
new10_chg_2:
	pushf
	call	cs:[Org10]
	pushm	<ax,bx,dx>
	cli
	mov	dx,03c4h
	mov	al,06h
	call	InIndex		; Read SR6 value
	mov	bx,ax
	mov	ah,12h
	out	dx,ax		; Unlock cirrus extension registers
	mov	dx,03d4h
	mov	al,1bh
	call	InIndex		; Read CR1B
	and	ah,11110000b	; CR1B bit1 ... Extended address wrap
	out	dx,ax		; Disable address wrap
	mov	dx,03c4h
	mov	ax,bx
	out	dx,ax		; Restore previous value to SR6
	sti
	popm	<dx,bx,ax>
	iret
New10		ENDP

InIndex		PROC	NEAR
	out	dx,al
	inc	dx
	xchg	al,ah
	in	al,dx
	dec	dx
	xchg	al,ah
	ret
InIndex		ENDP

reqhdr		dd	?

Strategy	PROC	FAR
	mov	word ptr cs:[reqhdr],bx
	mov	word ptr cs:[reqhdr +2],es
	ret
Strategy	ENDP

Commands	PROC	FAR
	pushm	<bx,ds>
	pushf
	lds	bx,cs:[reqhdr]
	mov	word ptr [bx+3],8103h
	popf
	popm	<ds,bx>
	ret
Commands	ENDP


Dev_Bottom	LABEL	NEAR
;------------------------------------------------------------------------------


msgOpening	db	'CLWRAP64.SYS ver ', '0' + MAJOR, '.'
		db	'0' + (MINOR SHR 4), '0' + (MINOR AND 15)
		db	' ... $'

msgNot		db	'Not $'
msgInstalled	db	'Installed.',CR,LF,'$'


pmsg		PROC	NEAR
	push	ax
	mov	ah,9
	int	21h
	pop	ax
	ret
pmsg		ENDP


Init_Commands	PROC	FAR
	pushm	<ax,bx,cx,dx,ds,es>
	pushf
	lds	bx,cs:[reqhdr]
	mov	word ptr [bx+3],0100h
	mov	byte ptr [bx+13],1
	mov	word ptr [bx+14],offset Dev_Bottom
	mov	word ptr [bx+16],cs
	movseg	ds,cs
	mov	dx,offset msgOpening
	call	pmsg
	mov	ax,3510h
	int	21h
	mov	word ptr [Org10],bx
	mov	word ptr [Org10+2],es
	
init_2:
	mov	ax,1200h		; Cirrus ÇÃ BIOS Ç©Ç«Ç§Ç©îªíË 
	mov	bl,80h			; ÇΩÇæÇµÅACL-GD510/520/610/620 ÇÕèúäO 
	push	bp
	int	10h
	pop	bp
	cmp	ax,3
	jbe	init_no
	cmp	ax,7fh
	ja	init_no
	
	mov	dx,offset New10
	mov	ax,2510h
	int	21h
	mov	[DevCommands],offset Commands
	jmps	init_exit
init_no:
	mov	dx,offset msgNot
	call	pmsg
	les	bx,[reqhdr]
	mov	byte ptr es:[bx+13],0
	mov	word ptr es:[bx+14],0
	mov	word ptr es:[bx+3],810ch	; Ç»Ç…Çï‘ÇπÇŒÇ¢Ç¢ÇÃÇ©Ç»Å`ÅH
init_exit:
	mov	dx,offset msgInstalled
	call	pmsg
	popf
	popm	<es,ds,dx,cx,bx,ax>
	ret
Init_Commands	ENDP

_TEXT		ENDS

	END	top
