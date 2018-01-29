COMMENT #
===============================================================================
 cl3xdisp.asm
 (c)ŽI/LP-Project. 1996
===============================================================================
#

		.XLIST

$DSPX$CL3XDISP = 0100h
DSPX_ENTR_32	EQU	1

		INCLUDE mydef.inc
		INCLUDE dspx.inc
		INCLUDE dspxseg.inc
		INCLUDE dspxentr.inc
		INCLUDE bitblt.inc
		INCLUDE font.inc
		INCLUDE cl3xhw.inc
		INCLUDE cl3xdisp.inc
		EXTRN	dspx_org_int10:DWORD
		.LIST
		.386p

tCachetbl	STRUC
cache_top	db	0ffh
cache_end	db	0
cache_offset	dw	0ffffh
tCachetbl	ENDS


G_DATA		SEGMENT
Vmode_640	dw	5fh		; 640x480x256
Vmode_800	dw	5ch		; 800x600x256
Vmode_1024	dw	60h		; 1024x768x256
Vmode_1280	dw	6dh		; 1280x1024x256
	;
		
G_DATA		ENDS
L_DATA		SEGMENT
fbuff		db	4 * 32 dup (?)
fbuff_half	db	2 * 32 dup (?)

fctop_s		dd	?
fctop_d		dd	?
slinebytes	dd	0		;
clinebytes	dd	0		; charheight * screenwidth(slinebytes)
bblk_sbcs	tBlt <>
bblk_dbcs	tBlt <>
bblk_misc	tBlt <>
sdata		tBltini <>
cwidth_s	dw	0
cwidth_d	dw	0
cheight		dw	0
L_DATA		ENDS


TSR_TEXT	SEGMENT

Init_cl3xdisp	PROC	NEAR
	mov	di,ofs sdata
	mov	ax,word ptr [bx + (tVms.vms_charwidth)]
	test	byte ptr [bx + (tVms.vms_info)],VT_VM_MASK
	jz	@@2
	xchg	al,ah
@@2:
	mov	byte ptr [cwidth_s],al
	add	al,al
	mov	byte ptr [cwidth_d],al
	mov	byte ptr [cheight],ah
	mov	al,ah
	xor	ah,ah
	mul	word ptr [slinebytes]
	mov	word ptr [clinebytes],ax
	mov	word ptr [clinebytes + 2],dx
	
	call	Init_acc
	call	Init_csr
	
	call	Init_bblk
	call	Init_fctop
	
	call	CacheSbcsToMem
	call	CacheSbcsFonts
	
	ret
Init_cl3xdisp	ENDP


ChangeExtVm	PROC	NEAR
	pushm	<ax,cx,dx>
	mov	dx,[bx + (tVms.vms_screenx)]
	mov	ax,[Vmode_1280]
	mov	cx,1024
	cmp	dx,1280
	je_s	@@setvm
	mov	ax,[Vmode_1024]
	mov	cx,768
	cmp	dx,1024
	je_s	@@setvm
	mov	ax,[Vmode_800]
	mov	cx,600
	cmp	dx,800
	je_s	@@setvm
	mov	ax,[Vmode_640]
	mov	cx,480
	mov	dx,640
@@setvm:
	call	ChangeVm
	mov	[sdata.bltini_width],dx
	mov	[sdata.bltini_height],cx
	mov	word ptr [slinebytes],dx
	
	popm	<dx,cx,ax>
	ret
ChangeExtVm	ENDP


Init_bblk	PROC	NEAR
	mov	ax,[cwidth_s]
	mov	cx,[cheight]
	mov	di,ofs bblk_sbcs
	mov	[di + (tBlt.blt_width)],ax
	mov	[di + (tBlt.blt_height)],cx
	add	ax,7
	shr	ax,3
	mul	cx
	add	ax,3
	and	ax,0fffch
	mov	[di + (tBlt.blt_bytes)],ax
	mov	ax,[cwidth_d]
	mov	di,ofs bblk_dbcs
	mov	[di + (tBlt.blt_width)],ax
	mov	[di + (tBlt.blt_height)],cx
	add	ax,7
	shr	ax,3
	mul	cx
	add	ax,3
	and	ax,0fffch
	mov	[di + (tBlt.blt_bytes)],ax
	ret
Init_bblk	ENDP


Init_fctop	PROC	NEAR
	mov	di,ofs sdata
	movzx	eax,word ptr [di + (tBltini.bltini_width)]
	movzx	ecx,word ptr [di + (tBltini.bltini_height)]
	mul	ecx
	add	eax,3
	and	eax,0fffffffch
	mov	[fctop_s],eax
	movzx	ecx,[bblk_sbcs.blt_bytes]
	shl	ecx,8
	add	eax,ecx
	mov	[fctop_d],eax
	ret
Init_fctop	ENDP


CacheSbcsFonts	PROC	NEAR
	push	si
	mov	ax,0a000h
	mov	es,ax
	xor	cx,cx
	mov	ebx,[fctop_s]
@@lp:
	call	SetWindowOffset
	push	si
	mov	ax,0a000h
	mov	es,ax
	mov	si,di
	call	[GetSbcs]
	pop	si
	;push	cx
	;mov	cx,dx
	;mov	ax,0a000h
	;mov	es,ax
	;call	MoveToScrn
	;pop	cx
	movzx	edx,[bblk_sbcs.blt_bytes]
	add	ebx,edx
	inc	cx
	cmp	cx,256
	jne	@@lp
	pop	si
	ret
CacheSbcsFonts	ENDP


ChangeVm	PROC	NEAR
	pushm	<bx,dx>
	cmp	ax,0100h
	jb_s	@@2
	mov	bx,ax
	mov	ax,4f02h
@@2:
	pushf
	call	cs:[dspx_org_int10]
	popm	<dx,bx>
	ret
ChangeVm	ENDP


CalcApaAdd	PROC	NEAR
	xor	eax,eax
	mov	cx,dx
	mov	ebx,[clinebytes]
	mov	al,ch
	mul	ebx
	mov	ebx,eax
;	xor	eax,eax
	movzx	eax,byte ptr [cwidth_s]
	mul	cl
	add	eax,ebx
	ret
CalcApaAdd	ENDP

	ALIGN	16

SetBltValue	PROC	NEAR
	push	cx
	mov	ah,al
	and	al,0fh
	shr	ah,4
	mov	[di + (tBlt.blt_fg)],al
	mov	[di + (tBlt.blt_bg)],ah
	mov	cx,dx
	xor	eax,eax
	mov	ebx,[clinebytes]
	mov	al,ch
	mul	ebx
	mov	ebx,eax
	xor	eax,eax
	mov	al,byte ptr [cwidth_s]
	mul	cl
	add	eax,ebx
	mov	[di + (tBlt.blt_dest)],eax
	pop	cx
	ret
SetBltValue	ENDP

DispS		PROC	NEAR
	mov	di,ofs bblk_sbcs
	call	SetBltValue
	mov	ax,[di + (tBlt.blt_bytes)]
	xor	ch,ch
	mul	cx
	add	ax,word ptr [fctop_s]
	adc	dx,word ptr [fctop_s+2]
	mov	word ptr [di + (tBlt.blt_src)],ax
	mov	word ptr [di + (tBlt.blt_src)+2],dx
	call	TfrScrn2ScrnX
	ret
DispS		ENDP

DispSmemProc	PROC	NEAR
DispSbcs	LABEL	NEAR
	cmp	cl,byte ptr [sfc_lim]
	ja	DispS
DispSFC		LABEL	NEAR
	mov	di,ax
	mov	al,byte ptr [sbcsfontbytes]
	mul	cl
	add	ax,ofs sfc_top
	mov	si,ax
	mov	ax,di
DispSmem	LABEL	NEAR
	mov	di,ofs bblk_sbcs
	mov	word ptr [di + (tBlt.blt_src)],si
	mov	word ptr [di + (tBlt.blt_src)+2],ds
	call	SetBltValue
	call	TfrMem2Scrn
	ret
DispSmemProc	ENDP

DispD		PROC	NEAR
	mov	di,ofs bblk_dbcs
	call	SetBltValue
	mov	ax,[di + (tBlt.blt_bytes)]
	mul	cx
	add	ax,word ptr [fctop_d]
	adc	dx,word ptr [fctop_d+2]
	mov	word ptr [di + (tBlt.blt_src)],ax
	mov	word ptr [di + (tBlt.blt_src)+2],dx
	call	TfrScrn2ScrnX
	ret
DispD		ENDP


DispDmem	PROC	NEAR
	mov	di,ofs bblk_dbcs
	mov	word ptr [di + (tBlt.blt_src)],si
	mov	word ptr [di + (tBlt.blt_src)+2],ds
	call	SetBltValue
	call	TfrMem2Scrn
	ret
DispDmem	ENDP


FillRect	PROC	NEAR
	mov	di,ofs bblk_misc
	sub	dh,ch
	inc	dh
	sub	dl,cl
	inc	dl
	push	dx
	mov	dx,cx
	call	SetBltValue
	pop	cx
	mov	al,byte ptr [cwidth_s]
	mul	cl
	mov	[di + (tBlt.blt_width)],ax
	mov	al,byte ptr [cheight]
	mul	ch
	mov	[di + (tBlt.blt_height)],ax
	jmp	BltFillRect
FillRect	ENDP


AbortBitBlt	PROC	NEAR
	jmp	BltAbort
AbortBitBlt	ENDP

COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#


DispSbcsFrame	PROC	NEAR
	ret
DispSbcsFrame	ENDP

DispDbcs	PROC	NEAR
	cmp	al,bl
	jne	@@hh
	call	GetDbcsOffset
	cmp	bx,0ffffh
	je	@@nocache
	mov	cx,bx
	jmp	DispD
@@nocache:
	mov	si,ofs fbuff
	call	[GetDbcs]
	mov	al,reg_al
	jmp	DispDmem
@@hh:
	mov	si,ofs fbuff
	push	si
	call	[GetDbcs]
	call	SplitHalf_l
	mov	si,di
	mov	al,reg_al
	mov	dx,reg_dx
	call	DispSmem
	pop	si
	call	SplitHalf_r
	mov	al,reg_bl
	mov	dx,reg_dx
	inc	dl
	mov	si,di
	call	DispSmem
	ret
DispDbcs	ENDP


ScrnTfr		PROC	NEAR
	pushm	<bx,cx,dx>
	mov	di,ofs bblk_misc
	mov	ax,[cwidth_s]
	mul	bl
	mov	[di + (tBlt.blt_width)],ax
	mov	ax,[cheight]
	mov	[di + (tBlt.blt_height)],ax
	push	cx
	call	CalcApaAdd
	mov	[di + (tBlt.blt_dest)],eax
	pop	dx
	call	CalcApaAdd
	mov	[di + (tBlt.blt_src)],eax
	call	TfrScrn2Scrn
	popm	<dx,cx,bx>
	ret
ScrnTfr		ENDP


L_DATA		SEGMENT
SetCsrPtn	dw	ofs SetCsrPtn_hw
DispCsr		dw	ofs DispCsr_hw
EraseCsr	dw	ofs EraseCsr_hw
L_DATA		ENDS

SelectCsrHWSW	PROC	NEAR
	push	ax
	test	byte ptr [bx + (tVms.vms_info)],00000001b
	jz	@@sw
	mov	[SetCsrPtn],ofs SetCsrPtn_hw
	mov	[DispCsr],ofs DispCsr_hw
	mov	[EraseCsr],ofs EraseCsr_hw
	jmps	@@exit
@@sw:
	mov	[SetCsrPtn],ofs SetCsrPtn_sw
	mov	[DispCsr],ofs DispCsr_sw
	mov	[EraseCsr],ofs EraseCsr_sw
@@exit:
	pop	ax
	ret
SelectCsrHWSW	ENDP


L_DATA		SEGMENT
hw_csr		tCsrSize <>
L_DATA		ENDS
SetCsrPtn_hw	PROC	NEAR
	mov	si,ofs hw_csr
	mov	al,byte ptr [cwidth_s]
	mov	[si + (tCsrSize.csiz_width)],al
	mov	byte ptr [si + (tCsrSize.csiz_left)],0
	cmp	cl,byte ptr [cheight]
	jae	@@nodisp
	cmp	ch,byte ptr [cheight]
	jae	@@nodisp
	sub	cl,ch
	jc	@@nodisp
	inc	cl
	jmps	@@2
@@nodisp:
	xor	cx,cx
@@2:
	mov	[si + (tCsrSize.csiz_top)],ch
	mov	[si + (tCsrSize.csiz_height)],cl
	call	SetHWCsrPtn
	ret
SetCsrPtn_hw	ENDP


DispCsr_hw	PROC	NEAR
	mov	cx,dx
	mov	al,byte ptr [cheight]
	mul	ch
	mov	dx,ax
	mov	al,byte ptr [cwidth_s]
	mul	cl
	call	SetHWCsrPos
	call	DisplayHWCsr
	ret
DispCsr_hw	ENDP


EraseCsr_hw	PROC	NEAR
	jmp	EraseHWCsr
EraseCsr_hw	ENDP


L_DATA		SEGMENT
sw_csr_height	dw	8
sw_csr_ofs	dd	0
sw_csr_pos	dw	0
L_DATA		ENDS

SetCsrPtn_sw	PROC	NEAR
	xor	ax,ax
	mov	al,cl
	cmp	al,byte ptr [cheight]
	jae	@@err
	sub	al,ch
	jc	@@err
	inc	al
	jmps	@@2
@@err:
	xor	ax,ax
@@2:
	mov	[sw_csr_height],ax
	mov	ax,word ptr [slinebytes]
	mov	cl,ch
	xor	ch,ch
	mul	cx
	mov	word ptr [sw_csr_ofs],ax
	mov	word ptr [sw_csr_ofs+2],dx
	ret
SetCsrPtn_sw	ENDP

DispEraseCsr_sw	PROC	NEAR
EraseCsr_sw	LABEL	NEAR
	mov	dx,[sw_csr_pos]
DispCsr_sw	LABEL	NEAR
	mov	[sw_csr_pos],dx
	mov	di,ofs bblk_misc
	mov	ax,[sw_csr_height]
	or	ax,ax
	jz	@@exit
	mov	[di + (tBlt.blt_height)],ax
	mov	ax,[cwidth_s]
	mov	[di + (tBlt.blt_width)],ax
	call	CalcApaAdd
	add	eax,[sw_csr_ofs]
	mov	[di + (tBlt.blt_dest)],eax
	call	InvertRect
@@exit:
	ret
DispEraseCsr_sw	ENDP


COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

PrepareSplit	PROC	NEAR
	mov	di,ofs fbuff_half
	mov	dx,[cwidth_s]
	add	dx,7
	shr	dx,3
	mov	bx,[cwidth_d]
	add	bx,7
	shr	bx,3
	ret
PrepareSplit	ENDP

SplitHalf_l	PROC	NEAR
	pushm	<si>
	call	PrepareSplit
	push	di
	mov	cx,[cheight]
@@lp:
	mov	ax,word ptr [si]
	mov	word ptr [di],ax
	add	si,bx
	add	di,dx
	dec	cx
	jne	@@lp
	pop	di
	popm	<si>
	ret
SplitHalf_l	ENDP

SplitHalf_r	PROC	NEAR
	pushm	<si,bp>
	call	PrepareSplit
	push	di
	mov	bp,[cheight]
	mov	cx,[cwidth_s]
	mov	ax,cx
	and	cl,7
	shr	ax,3
	add	si,ax
@@lp:
	mov	ax,word ptr [si]
	xchg	al,ah
	shl	ax,cl
	xchg	al,ah
	mov	word ptr [di],ax
	add	si,bx
	add	di,dx
	dec	bp
	jne	@@lp
	pop	di
	popm	<bp,si>
	ret
SplitHalf_r	ENDP



COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#
G_DATA		SEGMENT
DbcsCache	LABEL	tCachetbl
		tCachetbl <040h,0fch,0>	; 81xx
		tCachetbl <040h,0fch,0>	; 82xx
		tCachetbl <040h,0d7h,0>	; 83xx
		tCachetbl <040h,0bfh,0>	; 84xx
		tCachetbl <>		; 85xx
		tCachetbl <>		; 86xx
		tCachetbl <040h,09dh,0>	; 87xx
		tCachetbl <09eh,0fch,0>	; 88xx
		tCachetbl <040h,0fch,0>	; 89xx
		tCachetbl <040h,0fch,0>	; 8axx
		tCachetbl <040h,0fch,0>	; 8bxx
		tCachetbl <040h,0fch,0>	; 8cxx
		tCachetbl <040h,0fch,0>	; 8dxx
		tCachetbl <040h,0fch,0>	; 8exx
		tCachetbl <040h,0fch,0>	; 8fxx
		tCachetbl <09eh,0fch,0>	; 90xx
		tCachetbl <040h,0fch,0>	; 91xx
		tCachetbl <040h,0fch,0>	; 92xx
		tCachetbl <040h,0fch,0>	; 93xx
		tCachetbl <040h,0fch,0>	; 94xx
		tCachetbl <040h,0fch,0>	; 95xx
		tCachetbl <040h,0fch,0>	; 96xx
		tCachetbl <040h,0fch,0>	; 97xx
		tCachetbl <040h,073h,0>	; 98xx
DbcsCacheCnt = ($ - DbcsCache) / (SIZE tCachetbl)

cRolling	dw	0
sRolling	db	'-\|/'
sDbcsLoading	db	' DBCS font loading...'
cDbcsLoading = ($ - sDbcsLoading)
G_DATA		ENDS

_TEXT		SEGMENT
Init_dbcscache	PROC	NEAR
	mov	di,ofs DbcsCache
	mov	cx,DbcsCacheCnt
	xor	dx,dx
@@lp:
	mov	ax,word ptr [di + (tCachetbl.cache_top)]
	cmp	al,ah
	ja	@@cnt
	mov	[di + (tCachetbl.cache_offset)],dx
	sub	ah,al
	mov	al,ah
	xor	ah,ah
	inc	ax
	add	dx,ax
@@cnt:
	add	di,SIZE tCachetbl
	loop	@@lp
	ret
Init_dbcscache	ENDP
_TEXT		ENDS

	ALIGN	16

GetDbcsOffset	PROC	NEAR
	pushm	<ax,dx>
	;cmp	cx,9873h
	cmp	cx,[fc_lim]
	ja	@@no_pop
	xor	ax,ax
	mov	bx,ax
	mov	bl,ch
	sub	bl,81h
	jc	@@no_pop
	add	bx,bx
	add	bx,bx
	add	bx,ofs DbcsCache
	mov	dx,word ptr [bx]
	mov	al,cl
	cmp	al,dh
	ja	@@no_pop
	sub	al,dl
	jc	@@no_pop
	add	ax,word ptr [bx+2]
	mov	bx,ax
	popm	<dx,ax>
	ret
@@no_pop:
	popm	<dx,ax>
@@no:
	mov	bx,-1
	ret
GetDbcsOffset	ENDP


CacheDbcsFonts	PROC	NEAR
	cmp	[fc_lim],0
	jne	@@1
	ret
@@1:
	pushm	<bp>
	mov	[cRolling],0
	mov	bp,ofs sDbcsLoading
	mov	cx,cDbcsLoading
	movseg	es,cs
	mov	bx,0007h
	xor	dx,dx
	mov	ax,1300h
	pushf
	call	[dspx_org_int10]
	;
	mov	si,ofs DbcsCache
	mov	bp,0ffh
	xor	cx,cx
@@lp:
	push	cx
	mov	ch,cl
	add	ch,81h
	mov	ax,word ptr [si]
	cmp	al,ah
	ja	@@cnt
	mov	cl,al
	movzx	eax,word ptr [si + (tCachetbl.cache_offset)]
	movzx	ebx,[bblk_dbcs.blt_bytes]
	mul	ebx
	add	eax,[fctop_d]
	mov	ebx,eax
@@lp2:
	Call	SetWindowOffset
	push	si
	mov	ax,0a000h
	mov	es,ax
	mov	si,di
	call	[GetDbcs]
;	mov	ax,0a000h
;	mov	es,ax
;	call	MoveToScrn
	pop	si
	
	inc	bp
	cmp	bp,100h
	jb_s	@@lp2_2
	
	push	ebx
	push	cx
	xor	bp,bp
	xor	ebx,ebx
	call	SetWindowOffset
	mov	bx,[cRolling]
	mov	al,byte ptr [bx + ofs sRolling]
	inc	bx
	and	bx,3
	mov	[cRolling],bx
	mov	ah,09h
	mov	bx,0fh
	mov	cx,1
	pushf
	call	[dspx_org_int10]
	pop	cx
	pop	ebx
	
@@lp2_2:
	movzx	eax,[bblk_dbcs.blt_bytes]
	add	ebx,eax
	inc	cl
	cmp	cl,[si + (tCachetbl.cache_end)]
	jbe	@@lp2
@@cnt:
	pop	cx
	add	si,4
	inc	cx
	cmp	cx,DbcsCacheCnt
	jb	@@lp
	
	xor	ebx,ebx
	call	SetWindowOffset
	mov	cx,cDbcsLoading
	mov	ax,0900h
	pushf
	call	[dspx_org_int10]
	;
	popm	<bp>
	ret
CacheDbcsFonts	ENDP


COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

	IFDEF INTERNAL_PROF_BUFFER
		PUBLIC	sfc_top
	ENDIF

L_DATA		SEGMENT
sbcsfontbytes	dw	?
L_DATA		ENDS
G_DATA		SEGMENT
fc_lim		dw	0
sfc_lim		dw	255
G_DATA		ENDS
F_DATA		SEGMENT
sfc_top		LABEL	BYTE
		db	2 * 32 * 256 dup (?)
F_DATA		ENDS

CacheSbcsToMem	PROC	NEAR
	mov	al,byte ptr [cwidth_s]
	add	al,7
	shr	al,3
	mul	byte ptr [cheight]
	mov	[sbcsfontbytes],ax
	movseg	es,cs
	mov	si,ofs sfc_top
	xor	cx,cx
@@sfc_lp:
	call	[GetSbcs]
	add	si,[sbcsfontbytes]
	inc	cx
	cmp	cx,[sfc_lim]
	jb	@@sfc_lp
	ret
CacheSbcsToMem	ENDP


SetSFC		PROC	NEAR
	xor	ah,ah
	mov	[sfc_lim],ax
	ret
SetSFC		ENDP


SetFC		PROC	NEAR
	push	dx
	xor	dx,dx
	cmp	al,0
	je	@@2
	mov	dx,9873h
@@2:
	mov	[fc_lim],dx
	pop	dx
	ret
SetFC		ENDP


SetMMIO		PROC	NEAR
	jmp	SetBltMode
SetMMIO		ENDP

GetTsrLimit	PROC	NEAR
	pushm	<ax,cx>
	mov	ax,2 * 32
	mov	cx,[sfc_lim]
	inc	cx
	mul	cx
	add	ax,ofs TopOfFont
	mov	dx,ax
	popm	<cx,ax>
	ret
GetTsrLimit	ENDP



TSR_TEXT	ENDS

	END
