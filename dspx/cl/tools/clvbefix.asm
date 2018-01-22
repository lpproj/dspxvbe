COMMENT #
===============================================================================
 clvbefix.sys
===============================================================================
#

		INCLUDE mydef.inc
		.186
		
MAJOR		EQU	1
MINOR		EQU	00h

TOP_TEXT	SEGMENT WORD
TOP_TEXT	ENDS
SEL_TEXT	SEGMENT PARA
SEL_TEXT	ENDS
_TEXT		SEGMENT BYTE
_TEXT		ENDS
		IFDEF ??version
		NOWARN RES
		ENDIF
STACK		SEGMENT PARA STACK
		dw	256 dup (?)
STACK		ENDS
		IFDEF ??version
		WARN RES
		ENDIF


CGROUP		GROUP TOP_TEXT,SEL_TEXT,_TEXT
ofs		EQU	offset

		ASSUME cs:CGROUP, ds:CGROUP

COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

SEL_TEXT	SEGMENT

SelProc		PROC	FAR
	cmp	bx,0
	jne	selp_2
	push	dx
	mov	ah,dl
	mov	dx,03ceh
	mov	al,9
	out	dx,ax
	mov	cs:[Woffset_w],ax
	pop	dx
	ret
selp_2:
	mov	bx,0100h
	jne	selp_3
	xor	dx,dx
	mov	dl,[Woffset]
	ret
selp_3:
SelProc		ENDP

Woffset_w	LABEL	WORD
		db	9
Woffset		db	?

SEL_TEXT	ENDS

COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

TOP_TEXT	SEGMENT
		ORG	0
		
		dd	-1
Dev_Attr	dw	8000h
		dw	ofs Strategy
Dev_Cmd		dw	ofs Commands
Dev_ID		db	'$$CLFIX$'
		db	'CLVBEFIX'
Dev_ID_len = ($ - Dev_ID)
Dev_ID_ver	db	MAJOR, MINOR
Pspseg		dw	0
		dw	?


New10		PROC	FAR
	cmp	ah,4fh
	je	new10_v
new10_jorg:
		db	0eah
Org10		dd	?
	;
new10_v:
	cmp	al,1
	je	new10_v01
	cmp	al,2
	je	new10_v02
	cmp	al,5
	jmps	new10_jorg
new10_v05:
new10_v01:
new10_v02:

New10		ENDP


reqhdr		dd	?

Strategy	PROC	FAR
	mov	word ptr cs:[reqhdr],bx
	mov	word ptr cs:[reqhdr+2],es
	ret
Strategy	ENDP

Commands	PROC	FAR
	pushm	<bx,ds>
	lds	bx,cs:[reqhdr]
	mov	word ptr [bx+3],810ch
	popm	<ds,bx>
	ret
Commands	ENDP

TOP_TEXT	ENDS



	END
