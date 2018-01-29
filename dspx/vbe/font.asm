COMMENT #
===============================================================================
 font.asm
 (c)ŽI/LP-Project. 1996.
 
===============================================================================
#

$DSPX$FONT$VERSION = 0000h

		.XLIST
		INCLUDE ..\mydef.inc
		INCLUDE ..\dspx.inc
		INCLUDE ..\dspxseg.inc
		
		INCLUDE font.inc
		
		.LIST
		.286

G_DATA		SEGMENT
FontCodePage	dw	0
G_DATA		ENDS

L_DATA		SEGMENT
GetSbcs		dd	?
GetDbcs		dd	?
GetSbcsT	dd	?
GetDbcsT	dd	?
SbcsExp		dw	?
DbcsExp		dw	?
SbcsChg0819	dw	?
SbcsCharBytes	dw	?
L_DATA		ENDS
TSR_TEXT	SEGMENT

IsSbcsFontT	PROC	NEAR
	pushm	<bx,dx,si,bp,es>
	mov	si,bx
	mov	bh,0
	call	GetFontSize2Vms
	jz	@@ok
	and	byte ptr [si + (tVms.vms_fontindex)],0fh
	mov	bh,0
	call	GetFontSize2Vms
	jz	@@ok2
	mov	ax,cs
	mov	es,ax
	mov	bx,ofs DummyFontProc
	mov	ax,0
	jmps	@@exit
@@ok2:
	mov	ax,2
	jmps	@@exit
@@ok:
	mov	ax,1
@@exit:
	mov	word ptr [GetSbcsT],bx
	mov	word ptr [GetSbcsT + 2],es
	popm	<es,bp,si,dx,bx>
	ret
IsSbcsFontT	ENDP

IsDbcsFontT	PROC	NEAR
	pushm	<bx,dx,si,bp,es>
	mov	si,bx
	mov	bh,1
	call	GetFontSize2Vms
	jz	@@ok
	and	byte ptr [si + (tVms.vms_fontindex)],0f0h
	mov	bh,1
	call	GetFontSize2Vms
	jz	@@ok2
	mov	ax,cs
	mov	es,ax
	mov	bx,ofs DummyFontProc
	mov	ax,0
	jmps	@@exit
@@ok2:
	mov	ax,2
	jmps	@@exit
@@ok:
	mov	ax,1
@@exit:
	mov	word ptr [GetDbcsT],bx
	mov	word ptr [GetDbcsT + 2],es
	popm	<es,bp,si,dx,bx>
	ret
IsDbcsFontT	ENDP

GetFontSize2Vms	PROC	NEAR
	mov	dh,[si + (tVms.vms_srcfontwidth)]
	mov	dl,[si + (tVms.vms_srcfontheight)]
	or	dx,dx
	jnz	@@2
	mov	dl,[si + (tVms.vms_fontwidth)]
	mov	dh,[si + (tVms.vms_fontheight)]
	mov	word ptr [si + (tVms.vms_srcfontwidth)],dx
	xchg	dl,dh
	mov	byte ptr [si + (tVms.vms_fontindex)],0
@@2:
	mov	bl,[si + (tVms.vms_fontindex)]
	and	bh,1
	jz	@@sbcs
	add	dh,dh
	and	bl,0fh
	jmps	@@cal
@@sbcs:
	shr	bl,4
@@cal:
	mov	bp,[FontCodePage]
	mov	ax,5000h
	int	15h
	or	ah,ah
	ret
GetFontSize2Vms	ENDP


DummyFontProc	PROC	FAR
	mov	al,5
	ret
DummyFontProc	ENDP

DummyChgProc	PROC	NEAR
	ret
DummyChgProc	ENDP


AssignFont	PROC	NEAR
	pushm	<cx>
@@lp:
	cmp	byte ptr [bx + (tFont.tf_avail)],0
	je	@@cont
	mov	al,[bx + (tVms.vms_info)]
	and	al,VT_VM_MASK
	cmp	al,[si + (tFont.tf_info)]
	je	@@2
@@cont:
	add	si,SIZE tFont
	loop	short @@lp
	mov	ax,0			; ‚È‚©‚Á‚½
	jmp	@@exit
@@2:
	mov	ax,word ptr [bx + (tVms.vms_charwidth)]
	cmp	ax,word ptr [si + (tFont.tf_charwidth)]
	jne	@@cont
	mov	ax,word ptr [bx + (tVms.vms_fontwidth)]
	cmp	ax,word ptr [si + (tFont.tf_fontwidth)]
	jne	@@cont
	mov	ax,word ptr [bx + (tVms.vms_srcfontwidth)]
	cmp	ax,word ptr [si + (tFont.tf_srcfontwidth)]
	jne	@@cont
	call	IsSbcsFontT
	call	IsDbcsFontT
	mov	ax,[si + (tFont.tf_sbcs)]
	mov	[SbcsExp],ax
	cmp	ax,-1
	je	@@sbcsraw
	mov	word ptr [GetSbcs],ofs SbcsExpProc
	mov	word ptr [GetSbcs + 2],cs
	jmps	@@3
@@sbcsraw:
	mov	ax,word ptr [GetSbcsT]
	mov	word ptr [GetSbcs],ax
	mov	ax,word ptr [GetSbcsT+2]
	mov	word ptr [GetSbcs+2],ax
@@3:
	mov	ax,[si + (tFont.tf_dbcs)]
	mov	[DbcsExp],ax
	cmp	ax,-1
	je	@@dbcsraw
	mov	word ptr [GetDbcs],ofs DbcsExpProc
	mov	word ptr [GetDbcs + 2],cs
	jmps	@@4
@@dbcsraw:
	mov	ax,word ptr [GetDbcsT]
	mov	word ptr [GetDbcs],ax
	mov	ax,word ptr [GetDbcsT+2]
	mov	word ptr [GetDbcs+2],ax
@@4:
	mov	ax,[si + (tFont.tf_chg0819)]
	cmp	ax,-1
	jne	@@5
	mov	ax,ofs DummyChgProc
@@5:
	mov	[SbcsChg0819],ax
	mov	al,[bx + (tVms.vms_charwidth)]
	add	al,7
	shr	al,3
	mul	[bx + (tVms.vms_charheight)]
	mov	[SbcsCharBytes],ax
	mov	ax,1
@@exit:
	popm	<cx>
	ret
AssignFont	ENDP


SbcsExpProc	PROC	FAR
	push	bx
	xor	bx,bx
	cmp	cl,20h
	jae	@@2
	mov	bl,cl
	mov	bl,byte ptr [bx + ofs SbcsExpTable]
@@2:
	call	[SbcsExp]
	pop	bx
	ret
SbcsExpProc	ENDP

	ALIGN	16

DbcsExpProc	PROC	FAR
	push	bx
	cmp	cx,'„Ÿ'			; 84a0
	jb	@@noexp
	cmp	cx,'„¾'			; 84be
	jbe	@@exp
@@noexp:
	xor	bx,bx
@@exp_brk:
	call	[DbcsExp]
	pop	bx
	ret
@@exp:
	mov	bl,3
	jmps	@@exp_brk
DbcsExpProc	ENDP

G_DATA		SEGMENT
SbcsExpTable	LABEL	BYTE
		db	0,3,3,3,3,1,2,0
		db	0,0,0,0,0,0,0,0
		db	3,0,0,0,1,3,3,3
		db	0,3,1,0,0,1,0,0

G_DATA		ENDS

TSR_TEXT	ENDS

	END
