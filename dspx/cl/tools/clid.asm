COMMENT #
===============================================================================
 clid.asm
 (c)鯖/LP-Project. 1996

 Cirrus logic の VGA BIOS を呼び出して、チップなどの情報を得る。 ただそんだけ。
 あくまで BIOS 経由なので、BIOS が関知できる範囲で把握できる。
===============================================================================
#

		INCLUDE mydef.inc

CLID_MAJOR	EQU	1
CLID_MINOR	EQU	00h

_TEXT		SEGMENT BYTE
	ASSUME	cs:_TEXT, ds:_TEXT
	ORG	100h

Com100h:
	jmp	CLID_main
	

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


CLID_main	PROC	NEAR
	cld
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	
	mov	dx,offset msgOpening
	call	pmsg
	
	mov	ax,1200h
	mov	bl,80h
	int	10h		; ah=12h,bl=80h ... Inquire CIRRUS VGA type
	push	ax
	mov	dx,offset msgP0
	call	pmsg
	call	px
	mov	al,'h'
	call	pchr
	call	pn
	pop	ax
	
	mov	dx,offset msgP1
	call	pmsg
	mov	di,offset CLTABLE
	call	GetRevStr
	call	pmsg
	call	pn
	
	mov	dx,offset msgSrev
	call	pmsg
	cmp	bl,80h
	jne	clid_srev2
	mov	dx,offset msgSrevNa
	call	pmsg
	call	pn
	mov	al,1
	jmp	clid_exit
clid_srev2:
	mov	al,bl
	call	px
	mov	al,'h'
	call	pchr
	call	pn
	
	mov	dx,offset msgP2
	call	pmsg
	mov	ax,1200h
	mov	bl,81h
	int	10h		; ah=12h,bl=81h ... Inquire CIRRUS BIOS version
	xchg	al,ah
	add	al,'0'
	call	pchr
	mov	al,'.'
	call	pchr
	xchg	al,ah
	call	px
	call	pn
	
	mov	dx,offset msgP3
	call	pmsg
	mov	ax,1200h
	mov	bl,85h
	int	10h		; ah=12h,bl=85h ... Get amount of installed mem
	mov	di,offset MEMTABLE
	call	GetRevStr
	call	pmsg
	call	pn
	mov	al,0
clid_exit:
	mov	ah,4ch
	int	21h
CLID_main	ENDP


msgOpening	db	'CLID version ','0' + CLID_MAJOR, '.'
		db	'0' + (CLID_MINOR SHR 4), '0' + (CLID_MINOR AND 15)
		db	'  (c)鯖/LP-Project. 1996',CR,LF,CR,LF,'$'
msgP0		db	'Chip type code : $'
msgP1		db	'Chip type      : CL-GD$'
msgSrev		db	'Chip revision  : $'
msgSrevNa	db	'(not available)$'
msgP2		db	'BIOS version   : $'
msgP3		db	'Memory         : $'

CLTABLE		LABEL	BYTE
		db	 1,'???? (reserved)$'
		db	 2, '510/520$'
		db	 3, '610/620$'
		db	 4, '5320$'
		db	 5, '6410$'
		db	 6, '5410$'
		db	 7, '6420$'
		db	 8, '6412$'
		db	10h,'5401$'
		db	11h,'5402$'
		db	12h,'5420$'
		db	13h,'5422$'
		db	14h,'5424$'
		db	15h,'5426$'
		db	16h,'5420 r1$'
		db	17h,'5402 r1$'
		db	18h,'5428$'
		db	19h,'5429$'
		db	20h,'6205$'
		db	21h,'6215$'
		db	22h,'6225$'
		db	23h,'6235$'
		db	24h,'6245$'
		db	31h,'5434$'
		db	32h,'5430$'
		db	33h,'5434 rev E or F$'
		db	35h,'5440$'
		db	36h,'5436$'
		db	40h,'6440$'
		db	41h,'7542$'
		db	50h,'5452$'
		
		db	 0, '---- (not detected)$'

MEMTABLE	LABEL	BYTE
		db	(256 / 64) , '256k bytes$'
		db	(512 / 64) , '512k bytes$'
		db	(1024 / 64), '1M bytes$'
		db	(2048 / 64), '2M bytes$'
		db	(3072 / 64), '3M bytes$'
		db	(4096 / 64), '4M bytes$'
		db	(6144 / 64), '6M bytes$'	; 4M より上はたぶん 
		db	(8192 / 64), '8M bytes$'	; ないと思うけど(笑)
		db	0, '(unknown)$'

_TEXT		ENDS

	END	Com100h
