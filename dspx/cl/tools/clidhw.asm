COMMENT #
===============================================================================
 clidhw.asm
 (c)鯖/LP-Project. 1996

 Cirrus の VGA レジスタを叩いてチップの判別／情報取得をする。
 はっきり言って「１００％確実！」とは言いかねる。
 なお、CL-GD510/520, 610/620 は判別できない。
===============================================================================
#

		INCLUDE mydef.inc

CLIDHW_MAJOR	EQU	1
CLIDHW_MINOR	EQU	00h

_TEXT		SEGMENT BYTE
	ASSUME	cs:_TEXT, ds:_TEXT
	ORG	100h

Com100h:
	jmp	CLIDHW_main
	

pmsg		PROC	NEAR
	push	ax
	mov	ah,9
	int	21h
	pop	ax
	ret
pmsg		ENDP


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


phex1		PROC
	add	al,'0'
	cmp	al,'9'
	jbe	phex1_2
	add	al,'A' - '0' - 10
phex1_2:
	call	pchr
	ret
phex1		ENDP


px		PROC	NEAR
	push	ax
	mov	ah,al
	shr	al,1
	shr	al,1
	shr	al,1
	shr	al,1
	call	phex1
	mov	al,ah
	and	al,0fh
	call	phex1
	pop	ax
	ret
px		ENDP


in_idx		PROC	NEAR
	out	dx,al
	inc	dx
	xchg	al,ah
	in	al,dx
	dec	dx
	xchg	al,ah
	ret
in_idx		ENDP

ReadClid	PROC	NEAR
	cli
	mov	dx,03c4h
	mov	al,6
	call	in_idx
	mov	[prevSR6],ah
	mov	ah,12h
	out	dx,ax			; unlock cirrus extension regs.
	mov	dx,03d4h
	mov	al,27h
	call	in_idx
	mov	[cl_id],ah
	cmp	ah,80h
	jb	readclid_no
	mov	al,28h
	call	in_idx
	mov	[cl_classid],ah
	mov	dx,03c4h
	mov	al,17h
	call	in_idx
	shr	ah,1
	shr	ah,1
	shr	ah,1
	and	ah,00000111b
	mov	[bus_type],ah
	mov	al,0fh
	call	in_idx
	shr	ah,1
	shr	ah,1
	shr	ah,1
	and	ah,00000011b
	mov	[dram],ah
	
	mov	bl,[cl_id]
	jmps	readclid_exit
readclid_no:
	mov	bl,0
readclid_exit:
	mov	dx,03c4h
	mov	al,12h
	mov	ah,[prevSR6]
	out	dx,ax
	xor	ax,ax
	mov	al,bl
	sti
	ret
ReadClid	ENDP

GetRevStr	PROC	NEAR
	pushm	<ax,bx,di>
	mov	bl,al
grstr_lp:
	mov	bh,byte ptr [di]
	cmp	bl,bh
	je	grstr_match
	cmp	bh,0
	je	grstr_match
	mov	al,'$'
	repne	scasb
	jmps	grstr_lp
grstr_match:
	lea	dx,[di + 1]
	popm	<di,bx,ax>
	ret
GetRevStr	ENDP

CLIDHW_main	PROC	NEAR
	cld
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	
	mov	dx,offset msgOpening
	call	pmsg
	call	ReadClid
	or	al,al
	jnz	clid_2
	mov	dx,offset errNotDetect
	call	pmsg
	mov	al,1
	jmp	clidhw_exit
clid_2:
	mov	dx,offset msgIDRegs
	call	pmsg
	mov	al,[cl_id]
	call	px
	push	ax
	mov	al,'h'
	call	pchr
	call	pn
	pop	ax
	mov	ah,al
	and	al,11111100b
	push	ax
	mov	dx,offset msgDevID
	call	pmsg
	call	px
	mov	al,'h'
	call	pchr
	pop	ax
	mov	di,offset IDTABLE
	call	GetRevStr
	call	pmsg
	mov	dx,offset msgRev
	call	pmsg
	mov	al,ah
	and	al,00000011b
	add	al,'0'
	call	pchr
	call	pn
	
	mov	dx,offset msgClass
	call	pmsg
	mov	al,[cl_classid]
	call	px
	mov	al,'h'
	call	pchr
	call	pn
	
	mov	dx,offset msgMemSize
	call	pmsg
	xor	bx,bx
	mov	bl,[dram]
	add	bx,bx
	mov	dx,[bx + MemSize]
	call	pmsg
	mov	dx,offset sBytes
	call	pmsg
	mov	dx,offset msgBusType
	call	pmsg
	mov	al,[bus_type]
	add	al,'0'
	call	pchr
	mov	al,' '
	call	pchr
	xor	bx,bx
	mov	bl,[bus_type]
	add	bx,bx
	mov	dx,[bx + BusType]
	call	pmsg
	call	pn
clidhw_exit:
	mov	ah,4ch
	int	21h
CLIDHW_main	ENDP


prevSR6		db	0
cl_id_locked	db	0
cl_id		db	0
cl_classid	db	0
bus_type	db	0
dram		db	0


MemSize		LABEL	WORD
		dw	sReserved, s512k, s1m, s2m
BusType		LABEL	WORD
		dw	sReserved, sReserved, sVL33more, sReserved
		dw	sPCI, sReserved, sVL33, sISA

errNotDetect	db	'Not detected cirrus chip.',CR,LF,'$'
msgIDRegs	db	'ID register : $'
msgDevID	db	'Device ID   : $'
msgRev		db	'Revision    : $'
msgClass	db	'Class ID    : $'
msgMemSize	db	'Memory size : $'
msgBusType	db	'BUS type    : $'

sReserved	db	'(unknown)$'
sVL33		db	'(VL-bus 33MHz or less)$'
sVL33more	db	'(VL-bus more than 33MHz)$'
sPCI		db	'(PCI)$'
sISA		db	'(ISA)$'
s512k		db	'512K$'
s1m		db	'1M$'
s2m		db	'2M or 4M$'
sBytes		db	' bytes',CR,LF,'$'

IDTABLE		LABEL	BYTE
		db	10010000b, ' (CL-GD5426)',CR,LF,'$'
		db	10011000b, ' (CL-GD5428)',CR,LF,'$'
		db	10100000b, ' (CL-GD5430/40)',CR,LF,'$'
		db	10101000b, ' (CL-GD5434)',CR,LF,'$'
		db	10101100b, ' (CL-GD5436)',CR,LF,'$'
		db	10110000b, ' (CL-GD545x)',CR,LF,'$'
		db	00000000b, CR,LF,'$'

msgOpening	db	'CLIDHW version ','0' + CLIDHW_MAJOR, '.'
		db	'0' + (CLIDHW_MINOR SHR 4), '0' + (CLIDHW_MINOR AND 15)
		db	'  (c)鯖/LP-Project. 1996',CR,LF,CR,LF,'$'

_TEXT		ENDS

	END	Com100h
