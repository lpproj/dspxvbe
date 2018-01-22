COMMENT #
===============================================================================
 dspxvbe.asm
 version 0.00
 (c)鯖/LP-Project. 1996
===============================================================================
#
		INCLUDE ..\mydef.inc
		INCLUDE ..\dspx.inc
		INCLUDE ..\dspxseg.inc
		INCLUDE ..\vesa.inc
		
		INCLUDE dspxvbe.inc
		INCLUDE dspxcmn.ah
		INCLUDE font.inc
		INCLUDE dspxldr.inc
		INCLUDE profvbe.inc
		
		.386

DSPXVBE_MAJOR	EQU	0
DSPXVBE_MINOR	EQU	00h

BITSEXP_BASE	EQU	0fh

_call_int10	MACRO
	pushf
	call	dword ptr [Org10h]
ENDM

L_DATA		SEGMENT
prev_csradd	dd	0
prev_xy		LABEL	WORD
prev_x		db	0
prev_y		db	0
csr_height	db	1,0
csr_offset	dd	0
sfc_max		db	127,0
TfrProc		dw	?

LineBuffer	LABEL	BYTE
DbcsBuffer	db	3 * 30 dup (?)
DbcsHBuffer	db	2 * 30 dup (?)
		db	1600 - ($ - LineBuffer) dup (?)
L_DATA		ENDS
F_DATA		SEGMENT
SbcsBuffer	LABEL	BYTE
		db	2 * 30 dup (?)
SbcsResident1	LABEL	NEAR
		db	127 * 2 * 30 dup (?)
SbcsResident128	LABEL	NEAR
		db	128 * 2 * 30 dup (?)
SbcsResident256	LABEL	NEAR
F_DATA		ENDS
G_DATA		SEGMENT
DefaultPalette	db	3 * 40h dup (0)

VbeModeTables	LABEL	tVbepack
VbeMode1024	tVbepack <105h,1024, 768>
VbeMode1280	tVbepack <107h,1280,1024>
VbeMode1600	tVbepack <-1,1600,1200>
VbeModeCount = ($ - VbeModeTables) / (SIZE tVbepack)

VideoModeTables	LABEL	tVms
	tVms <03h,00000000b, 80,25,12,30,12,24,1024, 768,12,24,00h,0>
	tVms <70h,00000000b, 84,32,12,24,12,24,1024, 768,12,24,00h,0>
	tVms <70h,00000000b,106,42,12,24,12,24,1280,1024,12,24,00h,0>
	tVms <70h,00000000b,132,50,12,24,12,24,1600,1200,12,24,00h,0>
VideoModeCount = ($ - VideoModeTables) / (SIZE tVms)

FontModeTables	LABEL	tFont
	tFont <1,VT_VM_NORMAL,12,30,12,24,12,24, ExpS1230, ExpD2430, -1>
	tFont <1,VT_VM_NORMAL,12,24,12,24,12,24, -1, -1, -1>
	;tFont <1,VT_VM_NORMAL, 8,16, 8,16, 8,16, -1, -1, -1>
FontModeCount = ($ - FontModeTables) / (SIZE tFont)

mypspseg	dw	?

Drv_Drvinfo	LABEL	tDspxDrv
		db	VEXT_MAJOR, VEXT_MINOR
		dw	ofs Primitive
		dw	ofs VideoModeTables
		dw	VideoModeCount
		dw	ofs DriverName
		dw	ofs DrvMyapi

Primitive	LABEL	WORD
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
		
		
DriverName	db	'Generic VBE 256 driver 0.00test (c)鯖',0

G_DATA		ENDS

TSR_TEXT	SEGMENT

GetVmsVm	PROC	NEAR
	mov	si,ofs VbeModeTables
	mov	cx,VbeModeCount
@@srchvm:
	mov	eax,dword ptr [bx + (tVms.vms_screenx)]
	cmp	eax,dword ptr [si + (tVbepack.vbepk_scrnX)]
	je	@@getvm
	add	si,SIZE tVbepack
	loop	short @@srchvm
@@getvm:
	mov	ax,[si + (tVbepack.vbepk_vm)]
	ret
GetVmsVm	ENDP

GetSfcBytes	PROC	NEAR
	pushm	<ax,dx>
	mov	ax,word ptr [sfc_max]
	inc	ax
	mov	cl,2 * 30
	mul	cx
	mov	cx,ax
	popm	<dx,ax>
	ret
GetSfcBytes	ENDP


ExpS1230	PROC	NEAR
	add	si,2 * 3
	call	[GetSbcsT]
	sub	si,2 * 3
	cmp	al,0
	jne	@@exit
	pushm	<ax,dx>
	xor	ax,ax
	mov	dx,ax
	test	bl,1
	jz	@@2
	mov	ax,word ptr es:[si + (2 * 3)]
	mov	dx,word ptr es:[si + (2 * (3 + 23))]
@@2:
	mov	word ptr es:[si],ax
	mov	word ptr es:[si + (2 * 1)],ax
	mov	word ptr es:[si + (2 * 2)],ax
	mov	word ptr es:[si + (2 * (3 + 23 + 1))],dx
	mov	word ptr es:[si + (2 * (3 + 23 + 2))],dx
	mov	word ptr es:[si + (2 * (3 + 23 + 3))],dx
	popm	<dx,ax>
@@exit:
	ret
ExpS1230	ENDP


ExpD2430	PROC	NEAR
	pushm	<ds>
	movseg	ds,es
	add	si,3 * 3
	call	[GetDbcsT]
	sub	si,3 * 3
	test	bl,1
	jnz	@@exp
	xor	ax,ax
	mov	word ptr [si],ax
	mov	word ptr [si+2],ax
	mov	word ptr [si+4],ax
	mov	word ptr [si+6],ax
	mov	byte ptr [si+8],al
	mov	word ptr [si + ((3 + 23 + 1) * 3)],ax
	mov	word ptr [si + ((3 + 23 + 1) * 3) + 2],ax
	mov	word ptr [si + ((3 + 23 + 1) * 3) + 4],ax
	mov	word ptr [si + ((3 + 23 + 1) * 3) + 6],ax
	mov	byte ptr [si + ((3 + 23 + 1) * 3) + 8],al
@@exit:
	popm	<ds>
	ret
	;
@@exp:
	push	dx
	mov	ax,word ptr [si + (3 * 3)]
	mov	dl,byte ptr [si + (3 * 3) + 2]
	mov	word ptr [si],ax
	mov	byte ptr [si + 2],dl
	mov	word ptr [si + (3 * 1)],ax
	mov	byte ptr [si + (3 * 1) + 2],dl
	mov	word ptr [si + (3 * 2)],ax
	mov	byte ptr [si + (3 * 2) + 2],dl
	mov	ax,word ptr [si + (3 * 26)]
	mov	dl,byte ptr [si + (3 * 26) + 2]
	mov	word ptr [si + (3 * 27)],ax
	mov	byte ptr [si + (3 * 27) + 2],dl
	mov	word ptr [si + (3 * 28)],ax
	mov	byte ptr [si + (3 * 28) + 2],dl
	mov	word ptr [si + (3 * 29)],ax
	mov	byte ptr [si + (3 * 29) + 2],dl
	pop	dx
	jmps	@@exit
ExpD2430	ENDP


DrvMyapi	PROC	FAR
	cmp	ah,LPDRV_GETVER
	jne	@@2
	mov	bx,0100h
	jmps	@@noerr
@@2:
	cmp	ah,LPDRV_SETSEG
	jne	@@3
	mov	cs:[mypspseg],es
	jmps	@@noerr
@@3:
	cmp	ah,LPDRV_GETSEG
	jne	@@4
	mov	es,cs:[mypspseg]
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
DrvMyapi	ENDP


SetToExtVm	PROC	FAR
	_prmentry
	and	ax,00ffh
	shl	ax,4
	add	ax,ofs VideoModeTables
	mov	bx,ax
	call	GetVmsVm
	push	bx
	mov	bx,ax
	mov	ax,4f02h
	_call_int10
	pop	bx
	call	InitVbeVars
	mov	si,ofs FontModeTables
	mov	cx,FontModeCount
	call	AssignFont
	mov	si,ofs SbcsBuffer
	xor	cx,cx
@@sbcs_lp:
	call	[GetSbcs]
	add	si,[SbcsCharBytes]
	inc	cl
	cmp	cl,[sfc_max]
	jbe	@@sbcs_lp
	mov	[prev_y],-1

COMMENT #
	mov	dx,ofs DefaultPalette
	mov	bx,0
	mov	cx,8
	mov	ax,1012h
	mov	dx,ofs DefaultPalette + (3 * 38h)
	mov	bx,8
	mov	cx,8
	mov	ax,1012h
#

	_prmexit
SetToExtVm	ENDP


ResetToVga	PROC	FAR
	pushm	<ax,bx,cx,dx,ds>
	pushf
	mov	ax,cs
	mov	ds,ax
;	mov	ax,4f02h
;	mov	bx,0012h
;	_call_int10
;	cmp	ax,004fh
;	je	@@2
	mov	ax,0012h
	_call_int10
@@2:
	popf
	popm	<ds,dx,cx,bx,ax>
	ret
ResetToVga	ENDP

	ALIGN	16

WriteSbcsChar	PROC	FAR
	_prmentry
	cmp	cl,[sfc_max]
	ja	@@getfont
	mov	al,cl
	mov	ch,byte ptr [SbcsCharBytes]
	mul	ch
	mov	si,ax
	add	si,ofs SbcsBuffer
@@getfont_brk:
	mov	al,reg_al
	call	Disp12
	_prmexit
@@getfont:
	mov	si,ofs DbcsBuffer
	call	dword ptr [GetSbcs]
	jmps	@@getfont_brk
WriteSbcsChar	ENDP

	ALIGN	16

WriteDbcsChar	PROC	FAR
	_prmentry
	mov	si,ofs DbcsBuffer
	call	[GetDbcs]
	mov	al,reg_al
	cmp	al,reg_bl
	jne	@@hh
	call	Disp24
@@hh_brk:
	_prmexit
	;
@@hh:
	call	Disp24HandH
	jmps	@@hh_brk
WriteDbcsChar	ENDP


Disp24HandH	PROC	NEAR
	mov	di,ofs DbcsHBuffer
	mov	cx,word ptr [cheight]
	push	si
@@lp_l:
	movsw
	add	si,1
	dec	cx
	jnz	@@lp_l
	mov	si,ofs DbcsHBuffer
	mov	dx,reg_dx
	mov	al,reg_al
	pushm	<ds,es>
	call	Disp12
	popm	<es,ds>
	pop	si
	inc	si
	mov	di,ofs DbcsHBuffer
	mov	cx,word ptr [cheight]
@@lp_r:
	mov	ah,byte ptr [si]
	mov	al,byte ptr [si + 1]
	shl	ax,4
	xchg	al,ah
	stosw
	add	si,3
	dec	cx
	jnz	@@lp_r
	mov	si,ofs DbcsHBuffer
	mov	dx,reg_dx
	inc	dl
	mov	al,reg_bl
	call	Disp12
	ret
Disp24HandH	ENDP

GetDestAddr	PROC	NEAR
	movzx	eax,ch
	mov	ebx,[clinebytes]
	mul	ebx
	mov	edi,eax
	movzx	eax,cl
	mov	bl,[cwidth_s]
	mul	bl
	add	edi,eax
	add	edi,[crtcstart]
	and	edi,[crtcmask]
	ret
GetDestAddr	ENDP


FillRectangle	PROC	FAR
	_prmentry

	call	GetDestAddr
	mov	al,reg_dh
	sub	al,reg_ch
	inc	al
	mov	bl,[cheight]
	mul	bl
	mov	dx,ax
	mov	al,reg_dl
	sub	al,reg_cl
	inc	al
	mov	bl,[cwidth_s]
	mul	bl
	mov	cx,ax
	mov	al,reg_al
	call	FillLine

	_prmexit
FillRectangle	ENDP


ScrollUp	PROC	FAR
	_prmentry
	
	call	GetDestAddr
	movzx	eax,reg_al
	mov	ebx,[clinebytes]
	mul	ebx
	lea	esi,[edi + eax]
	mov	al,reg_dl
	sub	al,reg_cl
	inc	al
	mov	bl,[cwidth_s]
	mul	bl
	mov	cx,ax
	mov	al,reg_dh
	sub	al,reg_ch
	sub	al,reg_al
	inc	al
	mov	bl,[cheight]
	mul	bl
	mov	dx,ax
	call	[TfrProc]
	
	mov	[prev_y],-1
	_prmexit
ScrollUp	ENDP


ScrollDown	PROC	FAR
	_prmentry
	
	mov	ch,dh
	push	cx
	sub	ch,al
	call	GetDestAddr
	pop	cx
	mov	esi,edi
	call	GetDestAddr
	mov	al,reg_dl
	sub	al,reg_cl
	inc	al
	mov	bl,[cwidth_s]
	mul	bl
	mov	cx,ax
	mov	dx,word ptr [cheight]
	mov	al,reg_dh
	sub	al,reg_ch
	sub	al,reg_al
	inc	al
@@lp:
	push	ax
	call	[TfrProc]
	sub	esi,[clinebytes]
	and	esi,[crtcmask]
	sub	edi,[clinebytes]
	and	edi,[crtcmask]
	pop	ax
	dec	al
	jnz	@@lp
	mov	[prev_y],-1
	_prmexit
ScrollDown	ENDP


SetCursorShape	PROC	FAR
	pushm	<ax,dx,ds>
	pushf
	mov	ax,cs
	mov	ds,ax
	mov	al,cl
	sub	al,ch
	inc	al
	mov	[csr_height],al
	xor	ax,ax
	mov	al,ch
	mul	word ptr [slinebytes]
	mov	word ptr [csr_offset],ax
	mov	word ptr [csr_offset + 2],dx
	popf
	popm	<ds,dx,ax>
	ret
SetCursorShape	ENDP


PutCursor	PROC	FAR
	_prmentry
	mov	[prev_xy],dx
	mov	cl,dl
	movzx	eax,dh
	mov	ebx,[clinebytes]
	mul	ebx
	mov	edi,eax
	movzx	eax,cl
	mov	bl,[cwidth_s]
	mul	bl
	add	edi,eax
	add	edi,[csr_offset]
	add	edi,[crtcstart]
	and	edi,[crtcmask]
	mov	[prev_csradd],edi
	mov	cx,word ptr [csr_height]
	call	Xor12n
	_prmexit
PutCursor	ENDP

EraseCursor	PROC	FAR
	_prmentry
	mov	edi,[prev_csradd]
	mov	cx,word ptr [csr_height]
	call	Xor12n
	_prmexit
EraseCursor	ENDP

SetPalette	PROC	FAR
	pushm	<ax,bx,cx,dx,di,ds>
	movseg	ds,cs
	cmp	al,15
	ja	@@exit
	xor	bx,bx
	mov	bl,ah
	mov	di,bx
	add	di,di
	lea	di,[bx + di + ofs DefaultPalette]
	xor	bx,bx
	mov	bl,al
	mov	dh,byte ptr [di]
	mov	ch,byte ptr [di+1]
	mov	cl,byte ptr [di+2]
	mov	ax,1010h
	_call_int10
@@exit:
	popm	<ds,di,dx,cx,bx,ax>
	ret
SetPalette	ENDP


ChangeFont	PROC	FAR
	_prmentry
	_prmexit
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
	call	GetSfcBytes
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
	call	GetSfcBytes
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
	mov	di,ofs TopOfFont
	push	ds
	movseg	ds,cs
	call	GetSfcBytes
	pop	ds
	rep	movsb
@@exit:
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


_DATA		SEGMENT
sCardID		db	ID_CARDINFO
msgOpening	db	'DSPXVBE version '
		db	'0' + DSPXVBE_MAJOR, '.'
		db	'0'+(DSPXVBE_MINOR SHR 4), '0'+(DSPXVBE_MINOR AND 15)
		db	'(試作)'
		db	' (c)鯖/LP-Project. 1996',CR,LF,0
msgHelp		db	'VESA BIOS 汎用の IBM DOS/V Extension ビデオ拡張'
		db	'ドライバです。',CR,LF
		db	CR,LF
		db	'DSPXVBE [/NOUMB] [/R]',CR,LF
		db	CR,LF
		db	'  /NOUMB',HT,'UMB への自動ロードを禁止します。',CR,LF
		db	'  /R', HT,HT,'DSPXVBE をメモリから削除します。',CR,LF
		db	0
		
errCputype	db	'ERROR : 386以降のＣＰＵでないと動作しません。',CR,LF,0
errNovesa	db	'ERROR : VESA BIOS がサポートされていない、もしくは'
		db	' 1024x768 (256色)の',CR,LF
		db	'        ビデオモードがサポートされて'
		db	'いないもようです。',CR,LF,0
wrnNoFont	db	'警告  : フォントがないため、使えないビデオモードが'
		db	'あります。',CR,LF,0
wrnNoVm		db	'警告  : サポートされていない解像度のビデオモードが'
		db	'あります。',CR,LF,0
_DATA		ENDS

_TEXT		SEGMENT


Drv_Getparam	PROC	NEAR
	mov	al,0
	mov	ah,0
	ret
Drv_Getparam	ENDP

Drv_Checkvideo	PROC	NEAR
	pushm	<bx,cx,dx,si,di,ds,es>
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	cmp	[Cpu_type],3
	jb	short @@no
	call	GetOrg10h
	call	ChkVbe
	or	ax,ax
	jz	short @@no
	call	CheckVmExist
	or	ax,ax
	jz	short @@no
	jmps	@@ok
@@no:
	mov	ax,1
	jmps	@@exit
@@ok:
	mov	ax,0
@@exit:
	popm	<es,ds,di,si,dx,cx,bx>
	ret
Drv_Checkvideo	ENDP

Drv_Checkvideoerr	PROC	NEAR
	mov	dx,ofs errCputype
	cmp	[Cpu_type],3
	jb	short @@p
	mov	dx,ofs errNovesa
@@p:
	call	PutMsg
	ret
Drv_Checkvideoerr	ENDP

Drv_Checkprof	PROC	NEAR
	pushm	<si>
	mov	si,ofs sCardID
	call	MemCmp
	je	@@noerr
@@err:
	mov	al,1
	jmps	@@exit
@@noerr:
	mov	al,0
@@exit:
	popm	<si>
	ret
Drv_Checkprof	ENDP

_DATA		SEGMENT
cvm_nofont	db	0
cvm_novm	db	0
_DATA		ENDS

Drv_Checkvms	PROC	NEAR
	pushm	<bx,cx,si,es>
	mov	bx,si
	mov	si,ofs FontModeTables
	mov	cx,FontModeCount
	call	AssignFont
	cmp	al,0
	jne	@@2
@@nofont:
	test	[bx + (tVms.vms_info)],80h
	jnz	@@no_thru
	mov	[cvm_nofont],1
	jmps	@@no_set
@@2:
	movseg	es,cs
	mov	si,ofs DbcsBuffer
	mov	cx,8140h
	xor	ax,ax
	call	[GetDbcsT]
	cmp	al,0
	jne	@@nofont
	
	call	GetVmsVm
	cmp	ax,-1
	jne	@@avail
	test	[bx + (tVms.vms_info)],80h
	jnz	@@no_thru
	mov	[cvm_novm],1
	jmps	@@no_set
@@no_set:				; 使えない
	mov	ax,80h
	or	[bx + (tVms.vms_info)],80h
	jmps	@@exit
@@no_thru:				; 使えない（もともと使えなかった）
	mov	ax,0
	jmps	@@exit
@@avail:				; 使える
	and	[bx + (tVms.vms_info)],7fh
	mov	ax,1
@@exit:
	popm	<es,si,cx,bx>
	ret
Drv_Checkvms	ENDP

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

Drv_Paramerr	PROC	NEAR
	ret
Drv_Paramerr	ENDP


Drv_Checkvmserr	PROC	NEAR
	pushm	<dx>
	cmp	[cvm_nofont],0
	je	@@2
	mov	dx,ofs wrnNoFont
	call	PutMsg
@@2:
	cmp	[cvm_novm],0
	je	@@3
	mov	dx,ofs wrnNoVm
	call	PutMsg
@@3:
	popm	<dx>
	ret
Drv_Checkvmserr	ENDP

Drv_Getbottom	PROC	NEAR
	push	cx
	mov	bx,ofs TopOfFont
	call	GetSfcBytes
	add	bx,cx
	pop	cx
	ret
Drv_Getbottom	ENDP


Drv_Preloadjob	PROC	NEAR
	pushm	<ax,bx,cx,dx,di>
	mov	di,ofs DefaultPalette
	xor	bx,bx
@@lp:
	push	bx
	mov	ax,1007h
	int	10h			; _call_int10
	mov	ax,1015h
	int	10h
	mov	byte ptr es:[di],dh
	mov	byte ptr es:[di+1],ch
	mov	byte ptr es:[di+2],cl
	add	di,3
	pop	bx
	inc	bx
	cmp	bx,40h
	jb	@@lp
	popm	<di,dx,cx,bx,ax>
	ret
Drv_Preloadjob	ENDP



_TEXT		ENDS



COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

G_DATA		SEGMENT

Org10h		dd	0
Egapalentry	dd	0
Vramtotal	dd	?

Bitstbl		LABEL	DWORD
	.XLIST
	$bitstbl$ = 0
	REPT	16
		bitsexp4b $bitstbl$, BITSEXP_BASE
	$bitstbl$ = $bitstbl$ + 1
	ENDM
	.LIST
Colortbl	LABEL	DWORD
	$colortbl$ = 00000000h
	REPT	16
		dd	$colortbl$
	$colortbl$ = $colortbl$ + 01010101h
	ENDM
G_DATA		ENDS
L_DATA		SEGMENT

crtcstart	dd	?
crtcmask	dd	0ffffffffh
curwnd_w	dw	?
curwnd_r	dw	?
windex_w	dw	?	; 書き込みウインドウ番号
wseg_w		dw	?	; 書き込みウインドウセグメント
windex_r	dw	?
wseg_r		dw	?


slinebytes	dd	?	; スキャンライン１行のバイト数
slinebytes_s	dd	?	; slinebytes - 半角幅
slinebytes_d	dd	?	; slinebytss - 全角幅
clinebytes	dd	?	; キャラクタライン１行のバイト数
				; (slinebytes * 文字高さ)
wselproc	dd	?	; ウインドウ切替ファンクション
wframesize	dd	?	; ウインドウの大きさ
wframemask	dw	?, 0	; wframesize - 1
wframeshift	dw	0	; ウインドウ切替用のシフトカウント
wframedepth	dw	1	; (ウインドウサイズ / ウインドウ分解能)
curwndmask	dw	0ffffh	; ウインドウ位置の最大値
cwidth_s	db	?, 0	; 半角横幅
cwidth_d	db	?, 0	; 全角横幅
cheight		db	?, 0	; 文字高さ

L_DATA		ENDS


TSR_TEXT	SEGMENT

COMMENT #
-------------------------------------------------------------------------------
 InitVbeVars
 ds:bx ... tVms
 ds:si ... tVbePack
-------------------------------------------------------------------------------
#

InitVbeVars	PROC	NEAR
	pushm	<eax,ecx,edx>
	xor	ecx,ecx
	mov	ax,[si + (tVbepack.vbepk_bpl)]
	mov	cx,ax
	mov	[slinebytes],ecx
	xor	dx,dx
	mov	dl,[bx + (tVms.vms_charwidth)]
	mov	[cwidth_s],dl
	sub	cx,dx
	mov	[slinebytes_s],ecx
	sub	cx,dx
	mov	[slinebytes_d],ecx
	add	dl,dl
	mov	[cwidth_d],dl
	xor	cx,cx
	mov	cl,[bx + (tVms.vms_charheight)]
	mov	[cheight],cl
	mul	cx
	mov	word ptr [clinebytes],ax
	mov	word ptr [clinebytes+2],dx
	mov	eax,[si + (tVbepack.vbepk_wsize)]
	mov	[wframesize],eax
	dec	eax
	mov	[wframemask],ax
	mov	ax,[si + (tVbepack.vbepk_wgsft)]
	mov	[wframeshift],ax
	xor	ah,ah
	mov	al,[si + (tVbepack.vbepk_wndW)]
	mov	[windex_w],ax
	mov	al,[si + (tVbepack.vbepk_wndR)]
	mov	[TfrProc],ofs TfrLine
	mov	[windex_r],ax
	cmp	ax,[windex_w]
	jne	@@1
	mov	[TfrProc],ofs TfrLine1w
@@1:
	
	mov	ax,[si + (tVbepack.vbepk_wsegW)]
	mov	[wseg_w],ax
	mov	ax,[si + (tVbepack.vbepk_wsegR)]
	mov	[wseg_r],ax

	mov	eax,[Vramtotal]
	dec	eax
	mov	[crtcmask],eax
	mov	cl,byte ptr [wframeshift]
	shr	eax,cl
	mov	[curwndmask],ax

	mov	ax,[si + (tVbepack.vbepk_wgdepth)]
	mov	[wframedepth],ax
	dec	ax
	not	ax
	and	[curwndmask],ax
	mov	ax,word ptr [si + (tVbepack.vbepk_selproc)]
	mov	dx,word ptr [si + (tVbepack.vbepk_selproc + 2)]
	or	ax,ax
	jnz	@@2
	or	dx,dx
	jnz	@@2
	mov	dx,cs
	mov	ax,ofs WndselByBios
@@2:
	mov	word ptr [wselproc],ax
	mov	word ptr [wselproc+2],dx
	
	push	bx
	xor	dx,dx
	mov	bx,[windex_r]
	mov	[curwnd_r],dx
	call	[wselproc]
	xor	dx,dx
	mov	bx,[windex_w]
	mov	[curwnd_w],dx
	call	[wselproc]
	xor	eax,eax
	mov	[crtcstart],eax
	pop	bx
	
	popm	<edx,ecx,eax>
	ret
InitVbeVars	ENDP


COMMENT #
-------------------------------------------------------------------------------
 Disp12n
 dl...x  dh...y
 al...属性
 ds:si...文字ビットマップ先頭
-------------------------------------------------------------------------------
#
	ALIGN	16

Disp12Proc	PROC	NEAR
@@chgw0:
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	jmps	@@chgw0_brk
Disp12		LABEL	NEAR
	pushm	<bp>
	mov	ch,al
	mov	cl,dl
	movzx	eax,dh
	mov	ebx,[clinebytes]
	mul	ebx
	mov	edi,eax
	movzx	eax,cl
	mov	bl,[cwidth_s]
	mul	bl
	add	eax,[crtcstart]
	add	edi,eax
	mov	edx,edi
	mov	cl,byte ptr [wframeshift]
	shr	edx,cl
	and	dx,[curwndmask]
	cmp	dx,[curwnd_w]
	jne	@@chgw0
@@chgw0_brk:
	mov	ax,word ptr [slinebytes]
	sub	ax,8
	push	ax		; ss:[bp+2] ... add value to next line
	mov	ax,word ptr [cheight]
	push	ax		; ss:[bp] ... loop count (cheight)
	mov	bp,sp
	mov	es,[wseg_w]
	and	di,[wframemask]
	xor	eax,eax
	mov	al,ch
	shr	al,4
	mov	edx,dword ptr [eax * 4 + ofs Colortbl]	; BG mask
	mov	al,ch
	and	al,0fh
	mov	ecx,dword ptr [eax * 4 + ofs Colortbl]	; FG mask
	mov	ax,di
	add	ax,word ptr [clinebytes]
	jc	@@chg_lp
	cmp	ax,[wframemask]
	ja	@@chg_lp
	
	ALIGN	4
@@lp:
	xor	eax,eax
	mov	al,byte ptr [si]
	shr	al,4
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	xor	eax,eax
	mov	al,byte ptr [si]
	and	al,0fh
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di+4],eax
	xor	eax,eax
	mov	al,byte ptr [si+1]
	shr	al,4
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di+8],eax
	
	add	si,2
	add	di,word ptr [slinebytes]
	dec	word ptr ss:[bp]
	jnz	@@lp
	
	add	sp,4
	popm	<bp>
	ret
	
	
	ALIGN	4
@@chg_lp:
	xor	eax,eax
	mov	al,byte ptr [si]
	shr	al,4
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgw1
	cmp	di,[wframemask]
	ja	@@chgw1
@@chgw1_brk:
	xor	eax,eax
	mov	al,byte ptr [si]
	and	al,0fh
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgw2
	cmp	di,[wframemask]
	ja	@@chgw2
@@chgw2_brk:
	xor	eax,eax
	mov	al,byte ptr [si+1]
	shr	al,4
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,word ptr ss:[bp+2]
	jc	@@chgw3
	cmp	di,[wframemask]
	ja	@@chgw3
@@chgw3_brk:
	add	si,2
	dec	word ptr ss:[bp]
	jnz	@@chg_lp
	
	add	sp,4
	popm	<bp>
	ret
;
	ALIGN	4
@@chgw1:
	push	ofs @@chgw1_brk
	jmp	WndIncr_w
	
	ALIGN	4
@@chgw2:
	push	ofs @@chgw2_brk
	jmp	WndIncr_w

	ALIGN	4
@@chgw3:
	push	ofs @@chgw3_brk
	jmp	WndIncr_w

Disp12Proc	ENDP

	ALIGN	16


Disp24Proc	PROC	NEAR
@@chgw0:
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	jmps	@@chgw0_brk
@@chgw1:
	push	ofs @@chgw1_brk
	jmp	WndIncr_w
	
	ALIGN	4
@@chgw2:
	push	ofs @@chgw2_brk
	jmp	WndIncr_w

	ALIGN	4
@@chgw3:
	push	ofs @@chgw3_brk
	jmp	WndIncr_w
Disp24		LABEL	NEAR
	pushm	<bp>
	mov	ch,al
	mov	cl,dl
	movzx	eax,dh
	mov	ebx,[clinebytes]
	mul	ebx
	mov	edi,eax
	movzx	eax,cl
	mov	bl,[cwidth_s]
	mul	bl
	add	eax,[crtcstart]
	add	edi,eax
	mov	edx,edi
	mov	cl,byte ptr [wframeshift]
	shr	edx,cl
	and	dx,[curwndmask]
	cmp	dx,[curwnd_w]
	jne	@@chgw0
@@chgw0_brk:
	mov	ax,word ptr [slinebytes]
	sub	ax,20
	push	ax		; ss:[bp+2] ... add value to next line
	mov	ax,word ptr [cheight]
	push	ax		; ss:[bp] ... loop count (cheight)
	mov	bp,sp
	mov	es,[wseg_w]
	and	di,[wframemask]
	xor	eax,eax
	mov	al,ch
	shr	al,4
	mov	edx,dword ptr [eax * 4 + ofs Colortbl]	; BG mask
	mov	al,ch
	and	al,0fh
	mov	ecx,dword ptr [eax * 4 + ofs Colortbl]	; FG mask
	
	ALIGN	4
@@lp:
	xor	eax,eax
	mov	al,byte ptr [si]
	shr	al,4
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgw1
	cmp	di,[wframemask]
	ja	@@chgw1
@@chgw1_brk:
	xor	eax,eax
	mov	al,byte ptr [si]
	and	al,0fh
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgw2
	cmp	di,[wframemask]
	ja	@@chgw2
@@chgw2_brk:

	xor	eax,eax
	mov	al,byte ptr [si+1]
	shr	al,4
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgw3
	cmp	di,[wframemask]
	ja	@@chgw3
@@chgw3_brk:
	xor	eax,eax
	mov	al,byte ptr [si+1]
	and	al,0fh
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgw4
	cmp	di,[wframemask]
	ja	@@chgw4
@@chgw4_brk:

	xor	eax,eax
	mov	al,byte ptr [si+2]
	shr	al,4
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgw5
	cmp	di,[wframemask]
	ja	@@chgw5
@@chgw5_brk:
	xor	eax,eax
	mov	al,byte ptr [si+2]
	and	al,0fh
	lea	bx,[eax * 4 + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,word ptr ss:[bp+2]
	jc	@@chgw6
	cmp	di,[wframemask]
	ja	@@chgw6
@@chgw6_brk:

	add	si,3
	dec	word ptr ss:[bp]
	jnz	@@lp
	
	add	sp,4
	popm	<bp>
	ret
;
	ALIGN	4
@@chgw4:
	push	ofs @@chgw4_brk
	jmp	WndIncr_w
	
	ALIGN	4
@@chgw5:
	push	ofs @@chgw5_brk
	jmp	WndIncr_w

	ALIGN	4
@@chgw6:
	push	ofs @@chgw6_brk
	jmp	WndIncr_w

Disp24Proc	ENDP


	ALIGN	16

WndIncr_w	PROC	NEAR
	pushm	<ax,dx>
	mov	dx,[curwnd_w]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	add	di,word ptr [wframesize]
	and	di,[wframemask]
	popm	<dx,ax>
	ret
WndIncr_w	ENDP

	ALIGN	16

WndIncr_wcs	PROC	NEAR
	pushm	<ax,dx,ds>
	mov	ax,cs
	mov	ds,ax
	mov	dx,[curwnd_w]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	add	di,word ptr [wframesize]
	and	di,[wframemask]
	popm	<ds,dx,ax>
	ret
WndIncr_wcs	ENDP

	ALIGN	16

WndIncr_r	PROC	NEAR
	pushm	<ax,dx,ds>
	mov	ax,cs
	mov	ds,ax
	mov	dx,[curwnd_r]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	[curwnd_r],dx
	mov	bx,[windex_r]
	call	[wselproc]
	add	si,word ptr [wframesize]
	and	si,[wframemask]
	popm	<ds,dx,ax>
	ret
WndIncr_r	ENDP

	ALIGN	16
	
WndIncr_xorcs	PROC	NEAR
	pushm	<ax,bx,dx,ds>
	mov	ax,cs
	mov	ds,ax
	mov	dx,[curwnd_r]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	[curwnd_r],dx
	mov	bx,[windex_r]
	call	[wselproc]
	mov	dx,[curwnd_w]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	add	di,word ptr [wframesize]
	and	di,[wframemask]
	popm	<ds,dx,bx,ax>
	ret
WndIncr_xorcs	ENDP

COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

	ALIGN	16

Xor12n		PROC	NEAR
	push	cx
	mov	cx,[wframeshift]
	mov	edx,edi
	shr	edx,cl
	and	dx,[curwndmask]
	cmp	dx,[curwnd_w]
	jne	@@chgwr0
	cmp	dx,[curwnd_r]
	jne	@@chgwr0
@@chgwr0_brk:
	and	di,[wframemask]
	pop	cx
	mov	bx,word ptr [slinebytes]
	sub	bx,8
	mov	dx,[wframemask]
	mov	ax,[wseg_w]
	mov	es,ax
	mov	ax,[wseg_r]
	push	ds
	mov	ds,ax
	
	ALIGN	4
@@lp:
	mov	eax,dword ptr [di]
	xor	eax,0f0f0f0fh
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgwr1
	cmp	di,dx
	ja	@@chgwr1
@@chgwr1_brk:
	mov	eax,dword ptr [di]
	xor	eax,0f0f0f0fh
	mov	dword ptr es:[di],eax
	add	di,4
	jc	@@chgwr2
	cmp	di,dx
	ja	@@chgwr2
@@chgwr2_brk:
	mov	eax,dword ptr [di]
	xor	eax,0f0f0f0fh
	mov	dword ptr es:[di],eax
	add	di,bx
	jc	@@chgwr3
	cmp	di,dx
	ja	@@chgwr3
@@chgwr3_brk:
	dec	cx
	jnz	@@lp
	
	pop	ds
	ret
	
	ALIGN	4
@@chgwr0:
	mov	[curwnd_w],dx
	mov	[curwnd_r],dx
	mov	cx,dx
	mov	bx,[windex_w]
	call	[wselproc]
	mov	bx,[windex_r]
	mov	dx,cx
	call	[wselproc]
	jmp	@@chgwr0_brk
	
	ALIGN	4
@@chgwr1:
	push	ofs @@chgwr1_brk
	jmp	WndIncr_xorcs
	
	ALIGN	4
@@chgwr2:
	push	ofs @@chgwr2_brk
	jmp	WndIncr_xorcs
	
	ALIGN	4
@@chgwr3:
	push	ofs @@chgwr3_brk
	jmp	WndIncr_xorcs
Xor12n		ENDP



COMMENT #
-------------------------------------------------------------------------------
 TfrLine
 
 esi ... 転送元左上オフセット
 edi ... 転送先
 cx  ... ドット単位の横幅
 dx  ... ドット単位の高さ
 
-------------------------------------------------------------------------------
#

TfrLine1w	PROC	NEAR
	pushm	<dx,bp,esi,edi>
	push	cx		; ss:[bp+4] ドット単位の横幅
	push	dx		; ss:[bp+2] ドット単位の高さ
	mov	ax,word ptr [slinebytes]
	sub	ax,cx
	push	ax		; ss:[bp] １行バイト数 - ドット単位の横幅
	mov	bp,sp
	;
	mov	cx,[wframeshift]
	mov	edx,edi
	shr	edx,cl
	and	dx,[curwndmask]
	mov	[curwnd_w],dx
	mov	cx,[wframeshift]
	mov	edx,esi
	shr	edx,cl
	and	dx,[curwndmask]
	mov	[curwnd_r],dx
	mov	bx,[windex_w]
	call	[wselproc]
	;
@@lp:
	mov	cx,word ptr ss:[bp+4]
	mov	dx,[curwnd_r]
	cmp	dx,[curwnd_w]
	jne	@@diffw
	mov	ax,si
	add	ax,cx
	jc	@@diffw
	cmp	ax,[wframemask]
	ja	@@diffw
	mov	ax,di
	add	ax,cx
	jc	@@diffw
	cmp	ax,[wframemask]
	ja	@@diffw
	mov	ax,[wseg_w]
	push	ds
	mov	ds,ax
	mov	es,ax
; DWORD
	shr	cx,2
	rep	movsd
; WORD
;	shr	cx,1
;	rep	movsw
	pop	ds
@@diffw_brk:
	add	di,word ptr ss:[bp]
	jc	@@incr_w
	cmp	di,[wframemask]
	ja	@@incr_w
@@incr_w_brk:
	add	si,word ptr ss:[bp]
	jc	@@incr_r
	cmp	si,[wframemask]
	ja	@@incr_r
@@incr_r_brk:
	dec	word ptr ss:[bp+2]
	jnz	@@lp
	
	mov	dx,[curwnd_r]
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]

	add	sp,4
	pop	cx
	popm	<edi,esi,bp,dx>
	ret
	;
	ALIGN	4
@@diffw:
	mov	ax,si
	add	ax,word ptr ss:[bp+4]
	jc	@@rd_diffw
	cmp	ax,[wframemask]
	ja	@@rd_diffw
	pushm	<di,ds>
	mov	ax,[wseg_r]
	mov	ds,ax
	mov	ax,cs
	mov	es,ax
	mov	di,ofs LineBuffer
; DWORD
	shr	cx,2
	rep	movsd
; WORD
;	shr	cx,1
;	rep	movsw
	popm	<ds,di>
@@rd_diffw_brk:
	mov	bx,[windex_w]
	mov	dx,[curwnd_w]
	call	[wselproc]
	mov	ax,di
	mov	cx,word ptr ss:[bp+4]
	add	ax,cx
	jc	@@wr_diffw
	cmp	ax,[wframemask]
	ja	@@wr_diffw
	pushm	<si>
	mov	ax,[wseg_w]
	mov	es,ax
	mov	si,ofs LineBuffer
; DWORD
	shr	cx,2
	rep	movsd
; WORD
;	shr	cx,1
;	rep	movsw
	popm	<si>
@@wr_diffw_brk:
	mov	bx,[windex_w]
	mov	dx,[curwnd_r]
	call	[wselproc]
	jmp	@@diffw_brk
	
	ALIGN	4
@@rd_diffw:
	pushm	<di>
	mov	dx,[wframemask]
	mov	ax,[wseg_r]
	mov	es,ax
	mov	di,ofs LineBuffer
@@rd_diffw_lp:
	mov	eax,dword ptr es:[si]
	mov	dword ptr [di],eax
	add	di,4
	add	si,4
	jc	@@rd_incr
	cmp	si,dx
	ja	@@rd_incr
@@rd_incr_brk:
	sub	cx,4
	ja	@@rd_diffw_lp
	popm	<di>
	jmps	@@rd_diffw_brk
	;
@@rd_incr:
	mov	dx,[curwnd_r]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	[curwnd_r],dx
	mov	bx,[windex_w]
	call	[wselproc]
	and	si,[wframemask]
	jmps	@@rd_incr_brk
	;
	
	ALIGN	4
@@wr_diffw:
	pushm	<si>
	mov	dx,[wframemask]
	mov	ax,[wseg_w]
	mov	es,ax
	mov	si,ofs LineBuffer
@@wr_diffw_lp:
	mov	eax,dword ptr [si]
	mov	dword ptr es:[di],eax
	add	si,4
	add	di,4
	jc	@@wr_incr
	cmp	di,dx
	ja	@@wr_incr
@@wr_incr_brk:
	sub	cx,4
	ja	@@wr_diffw_lp
	popm	<si>
	jmp	@@wr_diffw_brk
	;
@@wr_incr:
	mov	dx,[curwnd_w]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	and	di,[wframemask]
	jmps	@@wr_incr_brk
	;
	ALIGN	4
@@incr_w:
	mov	ax,[curwnd_w]
	add	ax,[wframedepth]
	and	ax,[curwndmask]
	mov	[curwnd_w],ax
	and	di,[wframemask]
	jmp	@@incr_w_brk
	
	ALIGN	4
@@incr_r:
	mov	dx,[curwnd_r]
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	bx,[windex_r]
	mov	[curwnd_r],dx
	call	[wselproc]
	and	si,[wframemask]
	jmp	@@incr_r_brk
	
TfrLine1w	ENDP



TfrLine		PROC	NEAR
	pushm	<dx,bp,esi,edi>
	push	cx		; ss:[bp+4] ドット単位の横幅
	push	dx		; ss:[bp+2] ドット単位の高さ
	mov	ax,word ptr [slinebytes]
	sub	ax,cx
	push	ax		; ss:[bp] １行バイト数 - ドット単位の横幅
	mov	bp,sp
	mov	cx,[wframeshift]
	mov	edx,edi
	shr	edx,cl
	and	dx,[curwndmask]
	cmp	dx,[curwnd_w]
	jne	@@chgww0
@@chgww0_brk:
	and	di,[wframemask]
	mov	edx,esi
	shr	edx,cl
	and	dx,[curwndmask]
	cmp	dx,[curwnd_r]
	jne	@@chgwr0
@@chgwr0_brk:
	push	ds
	and	si,[wframemask]
	mov	ax,[wseg_w]
	mov	es,ax
	mov	ax,[wseg_r]
	mov	dx,[wframemask]
	mov	ds,ax
	
	ALIGN	4
@@lp:
	mov	cx,word ptr ss:[bp+4]
	mov	ax,di
	add	ax,cx
	jc	@@ovl
	cmp	ax,dx
	ja	@@ovl
	mov	ax,si
	add	ax,cx
	jc	@@ovl
	cmp	ax,dx
	ja	@@ovl
; DWORD
	shr	cx,2
	rep	movsd
; WORD
;	shr	cx,1
;	rep	movsw
@@ovl_brk:
	add	di,word ptr ss:[bp]
	jc	@@incr_w
	cmp	di,dx
	ja	@@incr_w
@@incr_w_brk:
	add	si,word ptr ss:[bp]
	jc	@@incr_r
	cmp	si,dx
	ja	@@incr_r
@@incr_r_brk:
	dec	word ptr ss:[bp+2]
	jnz	@@lp
	pop	ds
	add	sp,4
	pop	cx
	popm	<edi,esi,bp,dx>
	ret

	ALIGN	4
@@ovl:
	mov	eax,dword ptr [si]
	mov	dword ptr es:[di],eax
	add	si,4
	jc	@@incr_r1
	cmp	si,dx
	ja	@@incr_r1
@@incr_r1_brk:
	add	di,4
	jc	@@incr_w1
	cmp	di,dx
	ja	@@incr_w1
@@incr_w1_brk:
	sub	cx,4
	ja	@@ovl
	jmps	@@ovl_brk

	ALIGN	4
@@chgww0:
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	jmp	@@chgww0_brk
	ALIGN	4
@@chgwr0:
	mov	[curwnd_r],dx
	mov	bx,[windex_r]
	call	[wselproc]
	jmp	@@chgwr0_brk
	
	ALIGN	4
@@incr_w:
	push	ofs @@incr_w_brk
	jmp	WndIncr_wcs
	ALIGN	4
@@incr_r:
	push	ofs @@incr_r_brk
	jmp	WndIncr_r
	
	ALIGN	4
@@incr_w1:
	push	ofs @@incr_w1_brk
	jmp	WndIncr_wcs
	ALIGN	4
@@incr_r1:
	push	ofs @@incr_r1_brk
	jmp	WndIncr_r
TfrLine		ENDP


COMMENT #
-------------------------------------------------------------------------------
 FillLine
 
 edi ... 転送左上
 cx  ... ドット単位の横幅
 dx  ... ドット単位の高さ
 al  ... 色
 
-------------------------------------------------------------------------------
#

FillLine	PROC	NEAR
	pushm	<dx,bp,edi>
	and	eax,0fh
	mov	esi,dword ptr ds:[eax * 4 + ofs Colortbl]
	mov	ax,word ptr [slinebytes]
	sub	ax,cx
	push	ax		; ss:[bp+4] ... １行のバイト数 - 横幅
	push	dx		; ss:[bp+2] ... 高さ
	push	cx		; ss:[bp]   ... 横幅
	mov	bp,sp
	mov	edx,edi
	mov	cx,[wframeshift]
	mov	ax,[wseg_w]
	mov	es,ax
	shr	edx,cl
	and	dx,[curwndmask]
	cmp	dx,[curwnd_w]
	jne	@@chgw0
@@chgw0_brk:
	and	di,[wframemask]
	
	ALIGN	4
@@lp:
	mov	cx,word ptr ss:[bp]
	mov	ax,di
	add	ax,cx
	jc	@@cmp_chg
	cmp	ax,[wframemask]
	ja	@@cmp_chg
; DWORD
	shr	cx,2
	mov	eax,esi
	rep	stosd
; WORD
;	shr	cx,1
;	mov	ax,si
;	rep	stosw
@@cmp_chg_brk:
	add	di,word ptr ss:[bp+4]
	jc	@@incr_w
	cmp	di,[wframemask]
	ja	@@incr_w
@@incr_w_brk:
	dec	word ptr ss:[bp+2]
	jnz	@@lp
	
	pop	cx
	add	sp,4
	popm	<edi,bp,dx>
	ret
	
	ALIGN	4
@@cmp_chg:
	mov	dword ptr es:[di],esi
	add	di,4
	jc	@@incr_w1
	cmp	di,[wframemask]
	ja	@@incr_w1
@@incr_w1_brk:
	sub	cx,4
	ja	@@cmp_chg
	jmps	@@cmp_chg_brk

	ALIGN	4
@@chgw0:
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	jmp	@@chgw0_brk
	
	ALIGN	4
@@incr_w:
	push	ofs @@incr_w_brk
	jmp	WndIncr_w
	
	ALIGN	4
@@incr_w1:
	push	ofs @@incr_w1_brk
	jmp	WndIncr_w
	
FillLine	ENDP


WndselByBios	PROC	FAR
	mov	ax,4f05h
	pushf
	call	cs:[Org10h]
	ret
WndselByBios	ENDP

TSR_TEXT	ENDS


;==============================================================================

_DATA		SEGMENT
VMArray		dd	?
_DATA		ENDS
_BSS		SEGMENT
Tmpbuff		db	1600 dup (?)
_BSS		ENDS


	.286

_TEXT		SEGMENT


GetOrg10h	PROC	NEAR
	pushm	<bx,es>
	mov	ax,5010h
	int	15h
	or	ah,ah
	jnz	@@err
	mov	ax,word ptr es:[bx + (tDspx.dspx_org10)]
	mov	word ptr [Org10h],ax
	mov	ax,word ptr es:[bx + (tDspx.dspx_org10 + 2)]
	mov	word ptr [Org10h+2],ax
	mov	ax,es:[bx + (tDspx.dspx_palettetbl)]
	mov	word ptr [Egapalentry],ax
	mov	word ptr [Egapalentry+2],es
	mov	ax,0
	jmps	@@exit
@@err:
	mov	ax,3510h
	int	21h
	mov	word ptr [Org10h],bx
	mov	word ptr [Org10h+2],es
	mov	ax,1
@@exit:
	popm	<es,bx>
	ret
GetOrg10h	ENDP

COMMENT #
-------------------------------------------------------------------------------
 FillVbePack
 ds:si   ptr to tVbePack
 
-------------------------------------------------------------------------------
#

_DATA		SEGMENT
Sftseltbl	dw	64, 16, 32, 15, 16, 14, 8, 13, 4, 12, 0, 0

Wndseltbl	LABEL	WORD
		; a=     none    r     w   r/w
		dw	   -1,   -1,   -1,0000h		; B=none
		dw	   -1,   -1,0100h,0000h		; B=r
		dw	   -1,0001h,   -1,0001h		; B=w
		dw	0101h,0101h,0100h,0100h		; B=r/w
_DATA		ENDS

FillVbePack	PROC	NEAR
	pushm	<bx,cx,dx,di,es>
	mov	ax,[si + (tVbepack.vbepk_vm)]
	cmp	ax,0ffffh
	je	@@creso
	les	di,[VMArray]
@@cvm_lp:
	mov	dx,word ptr es:[di]
	add	di,2
	cmp	ax,dx
	je	@@cvm_found
	cmp	dx,0ffffh
	jne	@@cvm_lp
@@notfound:
	mov	ax,VBEPK_NOTFOUND
	jmp	@@exit
@@cvm_found:
	movseg	es,cs
	mov	di,ofs Tmpbuff
	mov	es:[di + (tVesam.vesam_attr)],0
	mov	cx,ax
	mov	ax,4f01h
	_call_int10
	cmp	ax,004fh
	jne	@@notfound
	jmp	@@set

@@creso:
	mov	bx,word ptr [VMArray]
@@creso_lp:
	mov	es,word ptr [VMArray + 2]
	mov	cx,word ptr es:[bx]
	add	bx,2
	cmp	cx,0ffffh
	je	@@notfound
	movseg	es,cs
	mov	di,ofs Tmpbuff
	mov	es:[di + (tVesam.vesam_attr)],0
	mov	ax,4f01h
	_call_int10
	mov	al,byte ptr es:[di + (tVesam.vesam_attr)]
	test	al,01000000b
	jnz	@@creso_lp
	and	al,00010011b
	cmp	al,00010011b
	jne	@@creso_lp
	mov	ax,es:[di + (tVesam.vesam_columns)]
	cmp	ax,[si + (tVbepack.vbepk_scrnX)]
	jne	@@creso_lp
	mov	ax,es:[di + (tVesam.vesam_rows)]
	cmp	ax,[si + (tVbepack.vbepk_scrnY)]
	jne	@@creso_lp
	mov	al,es:[di + (tVesam.vesam_planes)]
	mov	ah,es:[di + (tVesam.vesam_bitspixel)]
	cmp	ax,0801h
	jne	@@creso_lp
	mov	al,es:[di + (tVesam.vesam_banks)]
	mov	ah,es:[di + (tVesam.vesam_mtype)]
	cmp	ax,0401h
	jne	@@creso_lp
	mov	[si + (tVbepack.vbepk_vm)],cx
@@set:
	mov	ax,es:[di + (tVesam.vesam_bytes)]
	mov	[si + (tVbepack.vbepk_bpl)],ax
	mov	ax,word ptr es:[di + (tVesam.vesam_cntl)]
	mov	dx,word ptr es:[di + (tVesam.vesam_cntl)+2]
	mov	word ptr [si + (tVbepack.vbepk_selproc)],ax
	mov	word ptr [si + (tVbepack.vbepk_selproc)+2],dx
	mov	al,es:[di + (tVesam.vesam_attrA)]
	and	al,00000111b
	shr	al,1
	sbb	ah,ah
	and	al,ah
	mov	dl,al
	mov	al,es:[di + (tVesam.vesam_attrB)]
	and	al,00000111b
	shr	al,1
	sbb	ah,ah
	and	al,ah
	shl	al,2
	or	al,dl
	xor	ah,ah
	add	ax,ax
	mov	bx,ax
	mov	ax,word ptr [bx + ofs Wndseltbl]
	cmp	ax,-1
	jne	@@set_2
	mov	ax,VBEPK_INVLD
	jmp	@@exit
@@set_2:
	mov	[si + (tVbepack.vbepk_wndW)],al
	mov	[si + (tVbepack.vbepk_wndR)],ah
	mov	dx,es:[di + (tVesam.vesam_segA)]
	cmp	al,1
	jne	@@set_3
	mov	dx,es:[di + (tVesam.vesam_segB)]
@@set_3:
	mov	[si + (tVbepack.vbepk_wsegW)],dx
	mov	dx,es:[di + (tVesam.vesam_segA)]
	cmp	ah,1
	jne	@@set_4
	mov	dx,es:[di + (tVesam.vesam_segB)]
@@set_4:
	mov	[si + (tVbepack.vbepk_wsegR)],dx
	mov	dx,es:[di + (tVesam.vesam_gra)]
	mov	bx,ofs Sftseltbl
@@gra_lp:
	mov	ax,word ptr [bx]
	cmp	ax,dx
	je	@@gra_2
	add	bx,4
	cmp	ax,0
	jne	@@gra_lp
@@gra_invld:
	mov	ax,VBEPK_INVLD
	jmp	@@exit
@@gra_2:
	mov	ax,word ptr [bx+2]
	mov	[si + (tVbepack.vbepk_wgsft)],ax
	mov	ax,es:[di + (tVesam.vesam_size)]
	cmp	ax,dx
	jb	@@gra_invld
	cmp	ax,64
	ja	@@gra_invld
	mov	cx,1024
	mul	cx
	mov	word ptr [si + (tVbepack.vbepk_wsize)],ax
	mov	word ptr [si + (tVbepack.vbepk_wsize)+2],dx
	mov	ax,es:[di + (tVesam.vesam_size)]
	xor	dx,dx
	div	es:[di + (tVesam.vesam_gra)]
	mov	[si + (tVbepack.vbepk_wgdepth)],ax
	
	mov	ax,VBEPK_NOERR
@@exit:
	popm	<es,di,dx,cx,bx>
	ret
FillVbePack	ENDP


CheckVmExist	PROC	NEAR
	pushm	<cx,dx,si>
	xor	dx,dx
	mov	si,ofs VbeModeTables
	mov	cx,VbeModeCount
@@lp:
	call	FillVbePack
	cmp	ax,VBEPK_NOERR
	je	@@cont
	mov	[si + (tVbepack.vbepk_vm)],-1
	dec	dx
@@cont:
	inc	dx
	add	si,SIZE tVbepack
	loop	short @@lp
	mov	ax,dx
	popm	<si,dx,cx>
	ret
CheckVmExist	ENDP


ChkVbe		PROC	NEAR
	pushm	<dx,di,es>
	movseg	es,cs
	mov	di,ofs Tmpbuff
	mov	word ptr es:[di],'BV'
	mov	word ptr es:[di+2],'2E'
	mov	ax,4f00h
	_call_int10
	cmp	al,4fh
	jne	@@err
	cmp	ah,ah
	jne	@@err
	mov	ax,word ptr es:[di + (tVesainf.vesai_vm)]
	mov	word ptr [VMArray],ax
	mov	ax,word ptr es:[di + (tVesainf.vesai_vm) + 2]
	mov	word ptr [VMArray + 2],ax
	mov	ax,es:[di + (tVesainf.vesai_total)]
	mov	word ptr [Vramtotal],0
	mov	word ptr [Vramtotal+2],ax
	mov	ax,es:[di + (tVesainf.vesai_ver)]
	jmps	@@exit
@@err:
	mov	ax,0
@@exit:
	popm	<es,di,dx>
	ret
ChkVbe		ENDP


_TEXT		ENDS

		END
