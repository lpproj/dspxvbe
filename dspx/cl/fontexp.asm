COMMENT #
===============================================================================

===============================================================================
#

$DSPX$FONTEXP = 0100h

		.XLIST
		INCLUDE mydef.inc
		INCLUDE dspx.inc
		INCLUDE dspxseg.inc
		INCLUDE font.inc
		INCLUDE fontexp.inc
		.LIST

G_DATA		SEGMENT
FONTEXP_TABLE	LABEL	tFont
	tFont <1, VT_VM_NORMAL, 8,16, 8,16, 8,16, -1,-1,-1>
	tFont <1, VT_VM_NORMAL, 8,18, 8,16, 8,16, ExpS8_1618, ExpD16_1618,-1>
	tFont <1, VT_VM_NORMAL,12,24,12,24,12,24, -1,-1,-1>
	tFont <1, VT_VM_NORMAL,12,30,12,24,12,24, ExpS12_2430,ExpD24_2430,-1>
	tFont <1, VT_VM_NORMAL, 6,12, 6,12, 6,12, -1,-1,-1>
	tFont <1, VT_VM_NORMAL, 7,14, 6,12, 6,12, ExpS7_1214, ExpD14_1214,-1>
FONTEXP_COUNT = ($ - FONTEXP_TABLE) / (SIZE tFont)
G_DATA		ENDS
L_DATA		SEGMENT
fexpbuff	db	4 * 32 dup (?)
L_DATA		ENDS

TSR_TEXT	SEGMENT

ExpS8_1618	PROC	NEAR
	inc	si
	call	[GetSbcsT]
	pushm	<ax>
	dec	si
	xor	ax,ax
	test	bl,1
	jz	@@2
	mov	al,byte ptr es:[si+1]
	mov	ah,byte ptr es:[si+16]
@@2:
	mov	byte ptr es:[si],al
	mov	byte ptr es:[si+17],ah
	popm	<ax>
	ret
ExpS8_1618	ENDP

ExpD16_1618	PROC	NEAR
	add	si,2
	call	[GetDbcsT]
	sub	si,2
	pushm	<ax,dx>
	test	bl,1
	jz	@@noexp
	mov	ax,word ptr es:[si + 2]
	mov	dx,word ptr es:[si + (2 * 16)]
	jmps	@@2
@@noexp:
	xor	ax,ax
	mov	dx,ax
@@2:
	mov	word ptr es:[si],ax
	mov	word ptr es:[si + (2 * 17)],dx
	popm	<dx,ax>
	ret
ExpD16_1618	ENDP


ExpS12_2430	PROC	NEAR
	add	si,2 * 3
	call	[GetSbcsT]
	sub	si,2 * 3
	pushm	<ax,dx,ds>
	movseg	ds,es
	test	bl,1
	jz	@@noexp
	mov	ax,word ptr [si + (2 * 3)]
	mov	dx,word ptr [si + (2 * 26)]
	jmps	@@2
@@noexp:
	xor	ax,ax
	mov	dx,ax
@@2:
	mov	word ptr [si],ax
	mov	word ptr [si + (2 * 1)],ax
	mov	word ptr [si + (2 * 2)],ax
	mov	word ptr [si + (2 * 27)],dx
	mov	word ptr [si + (2 * 28)],dx
	mov	word ptr [si + (2 * 29)],dx
	popm	<ds,dx,ax>
	ret
ExpS12_2430	ENDP


ExpD24_2430	PROC	NEAR
	add	si,3 * 3
	call	[GetDbcsT]
	sub	si,3 * 3
	pushm	<ax,dx,ds>
	mov	ax,es
	mov	ds,ax
	test	bl,1
	jz	@@noexp
	mov	ax,word ptr [si + (3 * 3)]
	mov	bl,byte ptr [si + (3 * 3) + 2]
	mov	dx,word ptr [si + (3 * 26)]
	mov	bh,byte ptr [si + (3 * 26) + 2]
	jmps	@@2
@@noexp:
	xor	ax,ax
	mov	dx,ax
	mov	bx,ax
@@2:
	mov	word ptr [si],ax
	mov	byte ptr [si + 2],bl
	mov	word ptr [si + (3 * 1)],ax
	mov	byte ptr [si + (3 * 1) + 2],bl
	mov	word ptr [si + (3 * 2)],ax
	mov	byte ptr [si + (3 * 2) + 2],bl
	mov	word ptr [si + (3 * 27)],dx
	mov	byte ptr [si + (3 * 27) + 2],bh
	mov	word ptr [si + (3 * 28)],dx
	mov	byte ptr [si + (3 * 28) + 2],bh
	mov	word ptr [si + (3 * 29)],dx
	mov	byte ptr [si + (3 * 29) + 2],bh
	popm	<ds,dx,ax>
	ret
ExpD24_2430	ENDP

ExpS7_1214	PROC	NEAR
	inc	si
	call	[GetSbcsT]
	dec	si
	pushm	<ax,ds>
	movseg	ds,es
	xor	ax,ax
	test	bl,1
	jz	@@2
	mov	al,byte ptr [si+1]
	mov	ah,byte ptr [si+12]
@@2:
	mov	byte ptr [si],al
	mov	byte ptr [si+13],ah
	test	bl,2
	jz	@@3
	pushm	<cx,si>
	mov	cx,14
@@lp:
	mov	al,byte ptr [si]
	mov	ah,al
	shr	al,1
	and	al,00000010b
	or	al,ah
	mov	byte ptr [si],al
	inc	si
	loop	@@lp
	popm	<si,cx>
@@3:
	popm	<ds,ax>
	ret
ExpS7_1214	ENDP


ExpD14_1214	PROC	NEAR
	add	si,2
	call	[GetDbcsT]
	sub	si,2
	pushm	<ax,cx,si,ds>
	mov	ax,es
	mov	ds,ax
	test	bl,3
	jnz	@@2
	xor	ax,ax
	mov	word ptr [si],ax
	mov	word ptr [si + (2 * 13)],ax
	jmps	@@exit
@@2:
	mov	ax,word ptr [si + (2 * 1)]
	mov	word ptr [si],ax
	mov	ax,word ptr [si + (2 * 12)]
	mov	word ptr [si + (2 * 13)],ax
	mov	cx,14
@@lp:
	mov	ax,word ptr [si]
	mov	bx,ax
	and	ah,00010000b
	shr	ah,1
	or	bh,ah
	shr	ah,1
	or	bh,ah
	mov	word ptr [si],bx
	add	si,2
	dec	cx
	jne	@@lp
@@exit:
	popm	<ds,si,cx,ax>
	ret
ExpD14_1214	ENDP


TSR_TEXT	ENDS

		END
