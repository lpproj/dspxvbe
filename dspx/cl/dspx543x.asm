COMMENT #
===============================================================================
 dspx543x.asm
 (c)鯖/LP-Project. 1996
===============================================================================
#


CL3X_MAJOR	EQU	0
CL3X_MINOR	EQU	03h

DSPX_ENTR_32 = 1

		.XLIST
		INCLUDE mydef.inc
		INCLUDE dspx.inc
		INCLUDE dspxseg.inc
		INCLUDE bitblt.inc
		INCLUDE dspxentr.inc
		INCLUDE font.inc
		INCLUDE fontexp.inc
		INCLUDE cl3xdisp.inc
		INCLUDE dspxldr.inc
		INCLUDE dspxcmn.ah
		
		INCLUDE prof543x.inc
		.LIST
		.386p

tVgapal		STRUC
vgapal_r	db	?
vgapal_g	db	?
vgapal_b	db	?
tVgapal		ENDS

G_DATA		SEGMENT

DefaultVgapal	tVgapal 40h dup (<>)

sfc_lim		dw	255
		
DRV_NAME	db	'CL-GD543x/4x/5x driver (c)鯖',0
	ALIGN	4

VMS_TABLE	LABEL	tVms
	tVms <03h,00000000b, 80,25,12,30,12,24,1024, 768,12,24,00h,0>
	tVms <03h,00000001b, 80,32,12,24,12,24,1024, 768,12,24,00h,0>
	tVms <70h,00000000b, 53,20,12,24,12,24, 640, 480,12,24,00h,0>
	tVms <70h,00000000b,106,40, 6,12, 6,12, 640, 480, 6,12,00h,0>
	tVms <70h,00000000b, 91,34, 7,14, 6,12, 640, 480, 6,12,00h,0>
	tVms <70h,00000000b, 66,25,12,24,12,24, 800, 600,12,24,00h,0>
	tVms <70h,00000000b,100,33, 8,18, 8,16, 800, 600, 8,16,00h,0>
	tVms <70h,00000000b,100,37, 8,16, 8,16, 800, 600, 8,16,00h,0>
	tVms <70h,00000000b,133,50, 6,12, 6,12, 800, 600, 6,12,00h,0>
	tVms <70h,00000000b,114,42, 7,14, 6,12, 800, 600, 6,12,00h,0>
	tVms <70h,00000000b, 84,32,12,24,12,24,1024, 768,12,24,00h,0>
	tVms <70h,00000000b,128,42, 8,18, 8,16,1024, 768, 8,16,00h,0>
	tVms <70h,00000000b,128,48, 8,16, 8,16,1024, 768, 8,16,00h,0>
	tVms <70h,00000000b,146,54, 7,14, 6,12,1024, 768, 6,12,00h,0>
	tVms <70h,00000000b,170,64, 6,12, 6,12,1024, 768, 6,12,00h,0>
	tVms <70h,00000000b,106,34,12,30,12,24,1280,1024,12,24,00h,0>
	tVms <70h,00000000b,106,42,12,24,12,24,1280,1024,12,24,00h,0>
	tVms <70h,00000000b,160,56, 8,18, 8,16,1280,1024, 8,16,00h,0>
	tVms <70h,00000000b,160,64, 8,16, 8,16,1280,1024, 8,16,00h,0>
	
VMS_COUNT = ($ - VMS_TABLE) / (SIZE tVms)

;FONT_TABLE	LABEL	tFont
;	tFont <1,VT_VM_NORMAL,12,24,12,24,12,24, -1,-1,-1>
;	tFont <1,VT_VM_NORMAL, 8,16, 8,16, 8,16, -1,-1,-1>
;FONT_COUNT = ($ - FONT_TABLE) / (SIZE tFont)


Drv_Drvinfo	LABEL	tDspxDrv
		db	VEXT_MAJOR, VEXT_MINOR
		dw	ofs PRM_TABLE
		dw	ofs VMS_TABLE
		dw	VMS_COUNT
		dw	ofs DRV_NAME
		dw	ofs Drv_Myapi

PRM_TABLE	LABEL	WORD
		dw	ofs SetToExtVm
		dw	ofs ResetToVga
		dw	ofs WriteSbcsChar
		dw	ofs WriteDbcsChar
		dw	ofs FillRectangle
		dw	ofs ScrollUp
		dw	ofs ScrollDown
		dw	ofs SetCursorShape
		dw	ofs PutCursor
		dw	ofs EraseCursor
		dw	ofs SetPalette
		dw	ofs ChangeFont
		dw	ofs ReturnStateSize
		dw	ofs SaveState
		dw	ofs RestoreState
		dw	ofs ChangeState

psp_seg		dw	?
vramsize	dw	?

G_DATA		ENDS
L_DATA		SEGMENT
hw_csr		tCsrSize <>
sbcsfontbytes	dw	?

L_DATA		ENDS

TSR_TEXT	SEGMENT

Drv_Myapi	PROC	FAR
	cmp	ah,LPDRV_GETVER
	jne	@@2
	mov	bx,0100h
	jmps	@@noerr
@@2:
	cmp	ah,LPDRV_SETSEG
	jne	@@3
	mov	cs:[psp_seg],es
	jmps	@@noerr
@@3:
	cmp	ah,LPDRV_GETSEG
	jne	@@4
	mov	es,cs:[psp_seg]
	jmps	@@noerr
@@4:
@@err:
	mov	ah,-1
	stc
	ret
@@noerr:
	xor	ah,ah
	clc
	ret
Drv_Myapi	ENDP


SetToExtVm	PROC	FAR
	pushf
	pushm	<bx,ds>
	movseg	ds,cs
	cld
	xor	bx,bx
	mov	bl,al
	shl	bx,4
	add	bx,ofs VMS_TABLE
	call	ChangeExtVm
	popm	<ds,bx>
	popf
	_prmentry
	xor	bx,bx
	mov	bl,al
	shl	bx,4
	add	bx,ofs VMS_TABLE
	call	SelectCsrHWSW
	mov	al,[bx + (tVms.vms_info)]
	mov	si,ofs FONTEXP_TABLE
	mov	cx,FONTEXP_COUNT
	call	AssignFont
	
	call	Init_cl3xdisp
	call	SetDefaultPal
	call	CacheDbcsFonts
	_prmexit
SetToExtVm	ENDP

ResetToVga	PROC	FAR
	pushm	<ax,dx>
	call	AbortBitBlt
	mov	ax,0012h
	pushf
	call	cs:[dspx_org_int10]
	popm	<dx,ax>
	ret
ResetToVga	ENDP


WriteSbcsChar	PROC	FAR
	_prmentry
	call	DispSbcs
	_prmexit
WriteSbcsChar	ENDP

WriteDbcsChar	PROC	FAR
	_prmentry
	call	DispDbcs
	_prmexit
WriteDbcsChar	ENDP

FillRectangle	PROC	FAR
	_prmentry
	call	FillRect
	_prmexit
FillRectangle	ENDP

ScrollUp	PROC	FAR
	_prmentry
	mov	bl,dl
	sub	bl,cl
	inc	bl
	mov	bh,dh
	sub	bh,ch
	sub	bh,al
	inc	bh
	mov	dx,cx
	add	ch,al
@@lp:
	call	ScrnTfr
	inc	ch
	inc	dh
	dec	bh
	jne	@@lp
	_prmexit
ScrollUp	ENDP

ScrollDown	PROC	FAR
	_prmentry
	mov	bl,dl
	sub	bl,cl
	inc	bl
	mov	bh,dh
	sub	bh,ch
	sub	bh,al
	inc	bh
	mov	ch,dh
	mov	dl,cl
	sub	ch,al
@@lp:
	call	ScrnTfr
	dec	ch
	dec	dh
	dec	bh
	jne	@@lp
	_prmexit
ScrollDown	ENDP

SetCursorShape	PROC	FAR
	_prmentry
	call	[SetCsrPtn]
	_prmexit
SetCursorShape	ENDP

PutCursor	PROC	FAR
	_prmentry
	call	[DispCsr]
	_prmexit
PutCursor	ENDP

EraseCursor	PROC	FAR
	_prmentry
	call	[EraseCsr]
	_prmexit
EraseCursor	ENDP

SetPalette	PROC	FAR
	pushf
	pusha
	push	ds
	push	es
	movseg	ds,cs
	cmp	al,15
	ja_s	@@exit
	and	ah,3fh
	xor	bx,bx
	mov	bl,ah
	mov	si,bx
	add	si,si
	lea	si,[si + bx + ofs DefaultVgapal]
	mov	dh,byte ptr [si + (tVgapal.vgapal_r)]
	mov	ch,byte ptr [si + (tVgapal.vgapal_g)]
	mov	cl,byte ptr [si + (tVgapal.vgapal_b)]
	xor	bx,bx
	mov	bl,al
	push	bx
	mov	ax,1010h
	pushf
	call	[dspx_org_int10]
	pop	bx
	mov	dh,byte ptr [si + (tVgapal.vgapal_r)]
	mov	ch,byte ptr [si + (tVgapal.vgapal_g)]
	mov	cl,byte ptr [si + (tVgapal.vgapal_b)]
	call	SetMirrorPal
@@exit:
	pop	es
	pop	ds
	popa
	popf
	ret
SetPalette	ENDP


SetMirrorPal	PROC	NEAR
	push	bx
	not	dh
	not	cx
	not	bl
	mov	ax,1010h
	pushf
	call	[dspx_org_int10]
	not	cx
	not	dh
	pop	bx
	ret
SetMirrorPal	ENDP


SetDefaultPal	PROC	NEAR
	push	si
	mov	si,ofs DefaultVgapal
	xor	bx,bx
@@lp:
	mov	dh,byte ptr [si + (tVgapal.vgapal_r)]
	mov	ch,byte ptr [si + (tVgapal.vgapal_g)]
	mov	cl,byte ptr [si + (tVgapal.vgapal_b)]
	call	SetMirrorPal
	inc	bx
	add	si,SIZE tVgapal
	cmp	bx,0010h
	jb	@@lp
	pop	si
	ret
SetDefaultPal	ENDP


ChangeFont	PROC	FAR
	ret
ChangeFont	ENDP

ReturnStateSize	PROC	FAR
	pushm	<ax,dx>
	xor	cx,cx
	test	al,1
	jz	@@2
	mov	cx,ofs BottomOfLData
	sub	cx,ofs TopOfLData
@@2:
	test	al,2
	jz	@@3
	mov	dx,cx
	;call	GetSfcBytes
	mov	cx,2 * 32
	add	cx,dx
@@3:
	popm	<dx,ax>
	ret
ReturnStateSize	ENDP

SaveState	PROC	FAR
	pusha
	push	ds
	pushf
	cld
	movseg	ds,cs
	mov	di,bx
	test	al,1
	jz	@@font
	mov	si,ofs TopOfLData
	mov	cx,ofs BottomOfLData
	sub	cx,si
	jcxz	@@font
	rep	movsb
@@font:
	test	al,2
	jz	@@exit
	mov	si,ofs TopOfFont
	;call	GetSfcBytes
	mov	cx,0
	jcxz	@@exit
	rep	movsb
@@exit:
	popf
	pop	ds
	popa
	ret
SaveState	ENDP

RestoreState	PROC	FAR
	pusha
	push	ds
	push	es
	pushf
	cld
	movseg	ds,es
	movseg	es,cs
	mov	si,bx
	test	al,1
	jz	@@font
	mov	di,ofs TopOfLData
	mov	cx,ofs BottomOfLData
	sub	cx,di
	rep	movsb
@@font:
	test	al,2
	jz	@@exit
	;mov	di,ofs TopOfFont
	;push	ds
	;movseg	ds,cs
	;call	GetSfcBytes
	;pop	ds
	;rep	movsb
@@exit:
	popf
	pop	es
	pop	ds
	popa
	ret
RestoreState	ENDP

ChangeState	PROC	FAR
	pushf
	cmp	bl,1
	jne	short @@exit
	test	al,1
	jz	short @@no
@@ok:
	mov	ax,0
	jmps	@@exit
@@no:
	mov	ax,-1
@@exit:
	popf
	ret
ChangeState	ENDP




TSR_TEXT	ENDS


COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#
		.186

_DATA		SEGMENT
sCardID		db	ID_CARDINFO
msgOpening	db	'DSPX543X version ','0' + CL3X_MAJOR, '.'
		db	'0' + (CL3X_MINOR SHR 4), '0' + (CL3X_MINOR AND 15)
		IF (CL3X_MAJOR EQ 0)
		db	' ** 評価版 ** '
		ENDIF
		db	' (c)鯖/LP-Project. 1996',CR,LF,0

msgHelp		db	'Cirrus Logic CL-GD5430/34/36/40 用のビデオ拡張'
		db	'ドライバーです。',CR,LF
		db	CR,LF
		db	'DSPX543X [/FC=ON | OFF] '
		db	'[/SFC=ON | HALF | OFF] '
		db	'[/MMIO=ON | OFF] '
		db	'[/R]',CR,LF
		db	CR,LF
		
		db	'  /FC=OFF',HT,'全角フォントをあらかじめ読み込み'
		db	'ません。(初期値)',CR,LF
		db	'  /FC=ON',HT,'全角フォントの一部をビデオメモリに'
		db	'あらかじめ読み込みます。',CR,LF
		db	CR,LF
		db	'  /SFC=OFF',HT,'半角フォントをメインメモリ上に'
		db	'読み込みません。(初期値)',CR,LF
		db	'  /SFC=HALF',HT,'半角フォントの前半１２８文字分を'
		db	'メインメモリに読み込みます。',CR,LF
		db	'  /SFC=ON',HT,'半角フォントを２５６文字すべて'
		db	'メインメモリに読み込みます。',CR,LF
		db	CR,LF
		db	'  /MMIO=OFF',HT,'メモリマップドＩ／Ｏを使用しません。'
		db	CR,LF
		db	'  /MMIO=ON',HT,'メモリマップドＩ／Ｏを使用します。'
		db	'文字表示速度が向上します。',CR,LF
		db	HT,HT,'OS/2 上では指定できません。(初期値)'
		db	CR,LF
		db	CR,LF
		db	'  /R',HT,HT,'DSPX543X をメモリ上から削除します。'
		db	CR,LF
		db	0

errNot386	db	'ERROR : 386 以降の CPU が必要です。ごめんね。'
		db	CR,LF,0
errNot5434	db	'ERROR : ビデオチップが CL-GD543x/4x/5x では'
		db	'ないようです。',CR,LF,0
errNotEnuff1m	db	'ERROR : ビデオＲＡＭが１メガバイト未満しか'
		db	'ありません。',CR,LF,0
errUnknown	db	'ERROR : なにやらよくわかりませんが、エラーの'
		db	'ようです。おかしいなー。',CR,LF,0
wrnNotEnuffVram	db	'警告  : ビデオＲＡＭ不足のため、使えないビデオモード'
		db	'があります。',CR,LF,0
wrnNoFont	db	'警告  : フォントが存在しないため、使えない'
		db	'ビデオモードがあります。',CR,LF,0
wrnUnknownChip	db	'警告  : ビデオチップは Cirrus Logic のもののよう'
		db	'ですが、当方で関知できない',CR,LF
		db	'        型番です。動作するかは不明です。',CR,LF,0
wrnNoDbcsCache	db	'警告  : ビデオＲＡＭが２メガバイト未満です。全角'
		db	'フォントのキャッシュは',CR,LF
		db	'        できません。',CR,LF,0
errParam	db	'ERROR : パラメータの指定に誤りがあるようです。'
		db	CR,LF,0

sSFC		db	'S'
sFC		db	'FC='
cSFC = ($ - sSFC)
cFC = ($ - sFC)
sMMIO		db	'MMIO='
cMMIO = ($ - sMMIO)
sON		db	'ON',0
sOFF		db	'OFF',0
sALL		db	'ALL',0
sHALF		db	'HALF',0
sNONE		db	'NONE',0
s5426		db	'5426',0

opt_mmio_mdfy	db	0
opt_mmio	db	0
opt_fc		db	0
opt_sfc		db	0
opt_5426	db	0

chip_543x	db	0
vram_size	dw	0
_DATA		ENDS


_TEXT		SEGMENT

Drv_Opening	PROC	NEAR
	mov	dx,ofs msgOpening
	call	PutMsg
	ret
Drv_Opening	ENDP

Drv_Displayhelp	PROC	NEAR
	mov	dx,ofs msgHelp
	call	PutMsg
	ret
Drv_Displayhelp	ENDP

Drv_Checkvideoerr	PROC	NEAR
	push	dx
	cmp	al,1
	je	@@puterr
	cmp	al,2
	jne	@@exit
	mov	dx,ofs wrnUnknownChip
	jmps	@@p
@@puterr:
	mov	dx,ofs errNot386
	cmp	[Cpu_type],3
	jb	@@p
	cmp	[chip_543x],0
	mov	dx,ofs errNot5434
	je	@@p
	cmp	[vram_size],1024
	mov	dx,ofs errNotEnuff1m
	jb	@@p
	mov	dx,ofs errUnknown
@@p:
	call	PutMsg
@@exit:
	pop	dx
	ret
Drv_Checkvideoerr	ENDP

Drv_Checkvideo	PROC	NEAR
	pushm	<bx,bp>
	cmp	[Cpu_type],3
	jb_s	@@no
	mov	ax,1200h
	mov	bl,80h
	int	10h
	or	ah,ah
	jnz_s	@@no
	cmp	al,30h
	ja_s	@@543x
	cmp	al,40h
	je_s	@@no
	ja_s	@@543x
	cmp	[opt_5426],0
	je_s	@@no
	cmp	al,15h			; CL-GD5426
	je_s	@@543x
	cmp	al,18h			; CL-GD5428
	je_s	@@543x
	cmp	al,19h			; CL-GD5429
	jne_s	@@no
@@543x:
	mov	[chip_543x],1
	cmp	al,50h
	ja_s	@@unknown
	mov	ax,0
	jmps	@@ckmem
@@unknown:
	mov	ax,2
	jmps	@@ckmem
@@no:
	mov	ax,1
	jmps	@@exit
@@ckmem:
	push	ax
	mov	ax,1200h
	mov	bl,85h
	int	10h
	mov	bl,64
	mul	bl
	mov	[vram_size],ax
	pop	ax
	cmp	[vram_size],1024
	jae	@@exit
	mov	ax,1
@@exit:
	popm	<bp,bx>
	ret
Drv_Checkvideo	ENDP

Drv_Getparam	PROC	NEAR
	pushm	<bx,cx,si,di,es>
	movseg	es,ds
	mov	bx,word ptr [bx]
	mov	al,byte ptr [bx]
	cmp	al,'-'
	je	@@2
	cmp	al,'/'
	mov	ax,0		; no process
	je	@@2
	jmp	@@exit
@@2:
	inc	bx
	mov	si,bx
	mov	di,ofs sMMIO
	mov	cx,cMMIO
	call	MemCmp
	jne	@@3
	add	bx,cMMIO
	mov	si,bx
	mov	di,ofs sON
	call	StrCmp
	jne	@@2_2
	mov	[opt_mmio_mdfy],1
	mov	[opt_mmio],1
	jmp	@@process
@@2_2:
	mov	si,bx
	mov	di,ofs sOFF
	call	StrCmp
	jne	@@2_3
	mov	[opt_mmio_mdfy],1
	mov	[opt_mmio],0
	jmp	@@process
@@2_3:
	mov	ax,8081h		; err and break
	jmp	@@exit
@@3:
	mov	si,bx
	mov	di,ofs sFC
	mov	cx,cFC
	call	MemCmp
	jne	@@4
	add	bx,cFC
	mov	si,bx
	mov	di,ofs sON
	call	StrCmp
	jne	@@3_2
	mov	[opt_fc],1
	jmp	@@process
@@3_2:
	mov	si,bx
	mov	di,ofs sOFF
	call	StrCmp
	jne	@@3_3
	mov	[opt_fc],0
	jmp	@@process
@@3_3:
	mov	ax,8081h		; err and break
	jmp	@@exit
@@4:
	mov	si,bx
	mov	di,ofs sSFC
	mov	cx,cSFC
	call	MemCmp
	jne	@@5
	add	bx,cSFC
	mov	si,bx
	mov	di,ofs sON
	call	StrCmp
	je	@@4_on
	mov	si,bx
	mov	di,ofs sALL
	call	StrCmp
	jne	@@4_2
@@4_on:
	mov	[opt_sfc],255
	jmp	@@process
@@4_2:
	mov	si,bx
	mov	di,ofs sOFF
	call	StrCmp
	je	@@4_off
	mov	si,bx
	mov	di,ofs sNONE
	call	StrCmp
	jne	@@4_3
@@4_off:
	mov	[opt_sfc],0
	jmp	@@process
@@4_3:
	mov	si,bx
	mov	di,ofs sHALF
	call	StrCmp
	jne	@@4_4
	mov	[opt_sfc],127
	jmp	@@process
@@4_4:
	mov	ax,8081h		; err and break
	jmp	@@exit
@@5:
	mov	si,bx
	mov	di,ofs s5426
	call	StrCmp
	jne	@@6
	mov	[opt_5426],1
	jmp	@@process
@@6:
	;
	mov	ax,0
	jmp	@@exit
@@process:
	mov	ax,0001h		; ok
@@exit:
	popm	<es,di,si,cx,bx>
	ret
Drv_Getparam	ENDP

Drv_Paramerr	PROC	NEAR
	push	dx
	mov	dx,ofs errParam
	call	PutMsg
	pop	dx
	ret
Drv_Paramerr	ENDP

Drv_Preloadjob	PROC	NEAR
	pusha
	push	es
	call	Init_dbcscache
	movseg	es,cs
	
	mov	dx,ofs DefaultVgapal
	xor	bx,bx
	mov	cx,40h
	mov	ax,1017h
	int	10h
	
	cmp	[opt_mmio_mdfy],0
	jne	@@2_1
	mov	al,0
	cmp	[bOs2v2],0
	jne	@@2_0
	mov	al,1
@@2_0:
	mov	[opt_mmio],al
@@2_1:
	mov	al,[opt_mmio]
	call	SetMMIO
	xor	ax,ax
	mov	al,[opt_fc]
	cmp	al,0
	je	@@2_2
	cmp	[vram_size],2048
	jae	@@2_2
	mov	dx,ofs wrnNoDbcsCache
	call	PutMsg
@@2_2:
	call	SetFC
	mov	al,[opt_sfc]
	call	SetSFC
	pop	es
	popa
	ret
Drv_Preloadjob	ENDP

Drv_Checkprof	PROC	NEAR
	pushm	<si>
	mov	si,ofs sCardID
	call	MemCmp
	je	@@noerr
@@err:
	mov	ax,1
	jmps	@@exit
@@noerr:
	mov	ax,0
@@exit:
	popm	<si>
	ret
Drv_Checkprof	ENDP

_DATA		SEGMENT
err_nofont	db	0
err_noreso	db	0
_DATA		ENDS
_BSS		SEGMENT
tmp_nofont	db	1 dup (?)
tmp_noreso	db	1 dup (?)
checkfontbuff	db	4 * 32 dup (?)
_BSS		ENDS

IsFontAvail	PROC	NEAR
	pushm	<bx,cx,si,es>
	mov	bx,si
	call	IsSbcsFontT
	cmp	al,0
	je	@@exit
	call	IsDbcsFontT
	cmp	al,0
	je	@@exit
	movseg	es,ds
	mov	si,ofs checkfontbuff
	mov	cx,8140h
	call	[GetDbcsT]
	cmp	al,0
	mov	al,0
	jne	@@exit
	mov	al,1
@@exit:
	popm	<es,si,cx,bx>
	ret
IsFontAvail	ENDP

Drv_Checkvms	PROC	NEAR
	mov	[tmp_noreso],0
	cmp	[si + (tVms.vms_screenx)],1024
	jbe	@@2
	cmp	[vram_size],2048
	jae	@@2
	mov	[tmp_noreso],1
@@2:
	mov	[tmp_nofont],0
	call	IsFontAvail
	cmp	al,0
	jne	@@3
	mov	[tmp_nofont],1
@@3:
	mov	ax,word ptr [tmp_nofont]
	or	ax,ax
	jnz	@@4
	and	[si + (tVms.vms_info)],7fh
	jmps	@@exit
@@4:
	test	[si + (tVms.vms_info)],80h
	jz	@@nosupp
	mov	ax,0
	jmps	@@exit
@@nosupp:
	or	[si + (tVms.vms_info)],80h
	or	word ptr [err_nofont],ax
	mov	ax,80h
@@exit:
	ret
Drv_Checkvms	ENDP


Drv_Checkvmserr	PROC	NEAR
	push	dx
	cmp	[err_noreso],0
	je	@@2
	mov	dx,ofs wrnNotEnuffVram
	call	PutMsg
@@2:
	cmp	[err_nofont],0
	je	@@3
	mov	dx,ofs wrnNoFont
	call	PutMsg
@@3:
	pop	dx
	ret
Drv_Checkvmserr	ENDP


Drv_Getbottom	PROC	NEAR
	push	dx
	call	GetTsrLimit
	mov	bx,dx
	pop	dx
	ret
Drv_Getbottom	ENDP


_TEXT		ENDS

COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

	END
