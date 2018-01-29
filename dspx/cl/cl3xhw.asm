COMMENT #
===============================================================================
 cl3xhw.asm
 

===============================================================================
#

$DSPX$CL3XHW$ = 0101h

		INCLUDE mydef.inc
		INCLUDE dspx.inc
		INCLUDE dspxseg.inc
		INCLUDE dspxcmn.ah
		INCLUDE bitblt.inc
		INCLUDE cl3xhw.inc

		.386

G_DATA		SEGMENT
BltStart	dw	ofs BltStart_io
NullCsrPtn	tCsrSize <0,0,0,0>
G_DATA		ENDS
L_DATA		SEGMENT

blt_io		LABEL	WORD
		dw	00h
		dw	10h
		dw	12h
		dw	14h
		dw	1h
		dw	11h
		dw	13h
		dw	15h
		dw	20h
		dw	21h
		dw	22h
		dw	23h
		dw	24h
		dw	25h
		dw	26h
		dw	27h
		dw	28h
		dw	29h
		dw	2ah
		dw	2bh
		dw	2ch
		dw	2dh
		dw	2eh
		dw	2fh
		dw	30h
blt_io_pcnt = ($ - blt_io) / 2
blt_io_rop	LABEL	WORD
		dw	32h
		dw	33h
blt_io_cnt = ($ - blt_io) / 2

bltmisc		tClb	<>

mmio_on		dw	0017h
mmio_off	dw	0017h

w_offset	dw	0009h
L_DATA		ENDS
TSR_TEXT	SEGMENT

InIndex		PROC	NEAR
	out	dx,al
	xchg	al,ah
	inc	dx
	in	al,dx
	xchg	al,ah
	dec	dx
	ret
InIndex		ENDP

Init_acc	PROC	NEAR
	mov	dx,03c4h
	mov	ax,1206h
	out	dx,ax		; Unlock cirrus extensions
	mov	al,17h
	call	InIndex
	and	ah,00000011b
	mov	[mmio_off],ax
	or	ah,00000100b	; bit2...enable mmio bit6...mmio address
	mov	[mmio_on],ax
	
	mov	ax,[di + (tBltini.bltini_width)]
	mov	[bltmisc.clb_srcpitch],ax
	mov	[bltmisc.clb_destpitch],ax
	
	mov	dx,03ceh
	mov	al,0bh
	call	InIndex
	and	ah,11100100b	; disable GC-extension and 2nd 32k window
	or	ah,00100000b	; set window offset granularity to 16K
	out	dx,ax
	
	
	ret
Init_acc	ENDP


Init_csr	PROC	NEAR
	call	EraseHWCsr
	mov	dx,03c4h
	mov	ax,3f13h
	out	dx,ax
	xor	ax,ax
	mov	dx,ax
	mov	si,ofs NullCsrPtn
	call	SetHWCsrPtn
	ret
Init_csr	ENDP


SetWindowOffset	PROC	NEAR
	push	ebx
	mov	di,bx
	and	di,3fffh
	shr	ebx,14 - 8
	mov	ah,bh
	mov	al,9
	mov	dx,03ceh
	out	dx,ax
	mov	[w_offset],ax
	pop	ebx
	ret
SetWindowOffset	ENDP


MoveToScrn	PROC	NEAR
	pushm	<eax,cx,si,di>
	mov	ax,[w_offset]
	push	ax
	mov	eax,ebx
	shr	eax,14 - 8
	mov	al,9
	mov	dx,03ceh
	out	dx,ax
	mov	[w_offset],ax
	mov	di,bx
	and	di,3fffh
	shr	cx,2
	rep	movsd
	pop	ax
	out	dx,ax
	mov	[w_offset],ax
	popm	<di,si,cx,eax>
	ret
MoveToScrn	ENDP


SetHWCsrPos	PROC	NEAR
	mov	bx,dx
	mov	dx,03c4h
	shl	ax,5
	or	al,10h
	out	dx,ax
	mov	ax,bx
	shl	ax,5
	or	al,11h
	out	dx,ax
	ret
SetHWCsrPos	ENDP


SetHWCsrPtn	PROC	NEAR
	pushf
	cli
	mov	dx,03ceh
	mov	ax,0fc09h	; offset 0 = fch
	;mov	ax,03c09h	; offset 0 = fch
	out	dx,ax
	mov	ax,0a000h
	mov	es,ax
	mov	di,0ff00h
				; まずカーソルパターンをクリア
	xor	eax,eax
	mov	cx,32 * 2
	rep	stosd
	mov	cl,[si + (tCsrSize.csiz_width)]
	or	cl,cl
	je	@@exit
	mov	eax,80000000h
	dec	cl
	sar	eax,cl
	mov	cl,[si + (tCsrSize.csiz_left)]
	or	cl,cl
	jz	@@2
	dec	cl
	shr	eax,cl
@@2:
	xchg	al,ah
	ror	eax,16
	xchg	al,ah
	xor	cx,cx
	mov	cl,[si + (tCsrSize.csiz_top)]
	shl	cx,2
	mov	di,0ff00h
	add	di,cx
	mov	cl,[si + (tCsrSize.csiz_height)]
	or	cl,cl
	jz	@@exit
	rep	stosd
@@exit:
	mov	dx,03ceh
	mov	ax,[w_offset]
	out	dx,ax
	popf
	ret
SetHWCsrPtn	ENDP


DisplayHWCsr	PROC	NEAR
	mov	dx,03c4h
	mov	ax,0112h
	out	dx,ax
	ret
DisplayHWCsr	ENDP


EraseHWCsr	PROC	NEAR
	mov	dx,03c4h
	mov	ax,0012h
	out	dx,ax
	ret
EraseHWCsr	ENDP

	ALIGN	16

BltStart_io	PROC	NEAR
	mov	ax,word ptr [si + (tClb.clb_rop)]
	mov	byte ptr [blt_io_rop + 1],al
	mov	byte ptr [blt_io_rop + 3],ah
	mov	di,ofs blt_io
	mov	cx,blt_io_pcnt
@@lp:
	mov	ax,word ptr [si]
	add	si,2
	mov	byte ptr [di + 1],al
	cmp	cx,1
	jbe	@@2
	mov	byte ptr [di + 3],ah
	add	di,4
	sub	cx,2
	ja	@@lp
@@2:
	mov	dx,03ceh
	mov	si,ofs blt_io
	mov	cx,blt_io_cnt
	EVEN
	rep	outsw
	mov	ax,0231h
	out	dx,ax
	ret
BltStart_io	ENDP

	ALIGN	16

BltStart_mem	PROC	NEAR
	mov	dx,03c4h
	mov	ax,[mmio_on]
	out	dx,ax
	_write_acc_start
	mov	dx,03c4h
	mov	ax,[mmio_off]
	out	dx,ax
	ret
BltStart_mem	ENDP


BltAbort	PROC	NEAR
	cli
	mov	dx,03ceh
	mov	al,31h
	call	InIndex
	test	ah,00001001b
	jz	@@exit
	and	ah,11000100b
	or	ah,00000100b
	out	dx,ax			; BLT reset
	jmps	$+2			; (いやな予感がするのでいちおうwait)
	jmps	$+2
	jmps	$+2
	jmps	$+2
	jmps	$+2
	jmps	$+2
@@lp:
	call	InIndex
	test	ah,00001001b
	jnz	@@lp
@@exit:
	sti
	ret
BltAbort	ENDP

TfrMem2Scrn	PROC	NEAR
	pushf
	
	mov	si,ofs bltmisc
	mov	eax,[di + (tBlt.blt_dest)]
	mov	[si + (tClb.clb_dest)],eax
	xor	eax,eax
	mov	byte ptr [si + (tClb.clb_dest) +3],al
	mov	[si + (tClb.clb_src)],eax
	mov	al,[di + (tBlt.blt_fg)]
	mov	dword ptr [si + (tClb.clb_fg)],eax
	mov	al,[di + (tBlt.blt_bg)]
	mov	dword ptr [si + (tClb.clb_bg)],eax
	mov	ax,[di + (tBlt.blt_width)]
	dec	ax
	mov	[si + (tClb.clb_width)],ax
	mov	ax,[di + (tBlt.blt_height)]
	dec	ax
	mov	[si + (tClb.clb_height)],ax
	mov	byte ptr [si + (tClb.clb_rop)],CLB_ROP_SRC
	mov	byte ptr [si + (tClb.clb_mode)],CLB_BLT_MEMEXP
	_wait_acc
	push	di
	call	[BltStart]
	pop	di
	;mov	ax,[di + (tBlt.blt_width)]
	;add	ax,7
	;shr	ax,3
	;mov	cx,[di + (tBlt.blt_height)]
	;mul	cx
	;mov	cx,ax
	mov	cx,[di + (tBlt.blt_bytes)]
	shr	cx,2
	mov	ax,0a000h
	mov	es,ax
	mov	si,word ptr [di + (tBlt.blt_src)]
	xor	di,di
	rep	movsd
	
	popf
	ret
TfrMem2Scrn	ENDP


Clb_setup	PROC	NEAR
	mov	eax,[di + (tBlt.blt_dest)]
	mov	[si + (tClb.clb_dest)],eax
	mov	eax,[di + (tBlt.blt_src)]
	mov	[si + (tClb.clb_src)],eax
	xor	eax,eax
	mov	byte ptr [si + (tClb.clb_dest) +3],al
	mov	byte ptr [si + (tClb.clb_src) +3],al
	mov	al,[di + (tBlt.blt_fg)]
	mov	dword ptr [si + (tClb.clb_fg)],eax
	mov	al,[di + (tBlt.blt_bg)]
	mov	dword ptr [si + (tClb.clb_bg)],eax
	mov	ax,[di + (tBlt.blt_width)]
	dec	ax
	mov	[si + (tClb.clb_width)],ax
	mov	ax,[di + (tBlt.blt_height)]
	dec	ax
	mov	[si + (tClb.clb_height)],ax
	mov	[si + (tClb.clb_rop)],bl
	mov	[si + (tClb.clb_mode)],bh
	ret
Clb_setup	ENDP


TfrScrn2Scrn	PROC	NEAR
	pushf
	mov	si,ofs bltmisc
	mov	bl,CLB_ROP_SRC
	mov	bh,CLB_BLT_COPY
	call	Clb_setup
	_wait_acc
	call	[BltStart]
	popf
	ret
	
TfrScrn2Scrn	ENDP

TfrScrn2ScrnX	PROC	NEAR
	pushf
	mov	si,ofs bltmisc
	mov	bl,CLB_ROP_SRC
	mov	bh,CLB_BLT_COPYEXP
	call	Clb_setup
	_wait_acc
	call	[BltStart]
	popf
	ret
TfrScrn2ScrnX	ENDP

BltFillRect	PROC	NEAR
	pushf
	
	mov	si,ofs bltmisc
	mov	bl,CLB_ROP_SRC
	mov	bh,CLB_BLT_PTNEXP
	call	Clb_setup
	xor	eax,eax
	mov	[si + (tClb.clb_src)],eax
	mov	al,[si + (tClb.clb_fg)]
	mov	[si + (tClb.clb_bg)],al
	_wait_acc
	call	[BltStart]
	popf
	ret
BltFillRect	ENDP

InvertRect	PROC	NEAR
	pushf
	
	mov	si,ofs bltmisc
	mov	bl,CLB_ROP_NOT
	mov	bh,CLB_BLT_COPY
	call	Clb_setup
	mov	eax,[si + (tClb.clb_dest)]
	;xor	eax,eax
	mov	[si + (tClb.clb_src)],eax
	mov	byte ptr [si + (tClb.clb_fg)],0fh
	mov	byte ptr [si + (tClb.clb_bg)],0fh
	_wait_acc
	call	[BltStart]
	popf
	ret
InvertRect	ENDP

TSR_TEXT	ENDS

COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

_TEXT		SEGMENT

SetBltMode	PROC	NEAR
	push	dx
	mov	dx,ofs BltStart_io
	cmp	al,1
	jne	@@2
	mov	dx,ofs BltStart_mem
@@2:
	mov	[BltStart],dx
	pop	dx
	ret
SetBltMode	ENDP

_TEXT		ENDS


	END	
