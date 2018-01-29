COMMENT #
===============================================================================
 dspxvbe.asm
 version 0.03
 (c)鯖/LP-Project. 1996-97, 2018
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
		INCLUDE dvbedisp.inc
		
		.386

DSPXVBE_MAJOR	EQU	0
DSPXVBE_MINOR	EQU	03h
;Revision	EQU	' '

_call_int10	MACRO
	pushf
	call	dword ptr [Org10h]
ENDM

_call_int10_cs	MACRO
	pushf
	call	dword ptr cs:[Org10h]
ENDM

L_DATA		SEGMENT
dspm		tDspm	<>
prev_csradd	dd	0
prev_xy		LABEL	WORD
prev_x		db	0
prev_y		db	0
csr_height	db	1,0
csr_offset	dd	0
sfc_max		db	127,0
TfrProc		dw	?
text_x		dw	?
text_y		dw	?

LineBuffer	LABEL	BYTE
DbcsBuffer	db	3 * 30 dup (?)
DbcsHBuffer	db	2 * 30 dup (?)
		db	1600 - ($ - LineBuffer) dup (?)
L_DATA		ENDS
F_DATA		SEGMENT
SbcsBuffer	LABEL	BYTE
		db	CR,LF
		db	'このへんは半角フォントバッファなわけです',CR,LF
		db	(256 * 2 * 30) - ($ - SbcsBuffer) dup (?)
SbcsBufferBottom LABEL	BYTE
;		db	2 * 30 dup (?)
;SbcsResident1	LABEL	NEAR
;		db	127 * 2 * 30 dup (?)
;SbcsResident128	LABEL	NEAR
;		db	128 * 2 * 30 dup (?)
;SbcsResident256	LABEL	NEAR
F_DATA		ENDS
G_DATA		SEGMENT
DefaultPalette	db	3 * 40h dup (0)

VbeVersion	dw	0

VbeModeTables	LABEL	tVbepack
VbeMode800	tVbepack <103h, 800, 600>
VbeMode1024	tVbepack <105h,1024, 768>
VbeMode1280	tVbepack <107h,1280,1024>
VbeMode1152	tVbepack <-1,1152, 864>
VbeMode1600	tVbepack <-1,1600,1200>
VbeModeCount = ($ - VbeModeTables) / (SIZE tVbepack)

VideoModeTables	LABEL	tVms
	tVms <03h,00000000b, 80,25,12,30,12,24,1024, 768,12,24,00h,0>
	;tVms <70h,00000000b, 66,25,12,24,12,24, 800, 600,12,24,00h,0>
	tVms <70h,00000000b,100,37, 8,16, 8,16, 800, 600, 8,16,00h,0>
	tVms <70h,00000000b,100,33, 8,18, 8,16, 800, 600, 8,16,00h,0>
	tVms <70h,00000000b,100,30, 8,20, 8,16, 800, 600, 8,16,00h,0>
	tVms <70h,00000000b,128,48, 8,16, 8,16,1024, 768, 8,16,00h,0>
	tVms <70h,00000000b,128,42, 8,18, 8,16,1024, 768, 8,16,00h,0>
	tVms <70h,00000000b,128,38, 8,20, 8,16,1024, 768, 8,16,00h,0>
	tVms <70h,00000000b, 84,32,12,24,12,24,1024, 768,12,24,00h,0>
	tVms <70h,00000000b,144,54, 8,16, 8,16,1152, 864, 8,16,00h,0>
	tVms <70h,00000000b,144,48, 8,18, 8,16,1152, 864, 8,16,00h,0>
	tVms <70h,00000000b,144,43, 8,20, 8,16,1152, 864, 8,16,00h,0>
	tVms <70h,00000000b, 96,36,12,24,12,24,1152, 864,12,24,00h,0>
	tVms <70h,00000000b, 96,28,12,30,12,24,1152, 864,12,24,00h,0>
	tVms <70h,00000000b,160,64, 8,16, 8,16,1280,1024, 8,16,00h,0>
	tVms <70h,00000000b,160,56, 8,18, 8,16,1280,1024, 8,16,00h,0>
	tVms <70h,00000000b,160,51, 8,20, 8,16,1280,1024, 8,16,00h,0>
	tVms <70h,00000000b,106,42,12,24,12,24,1280,1024,12,24,00h,0>
	tVms <70h,00000000b,106,34,12,30,12,24,1280,1024,12,24,00h,0>
	tVms <70h,00000000b,200,75, 8,16, 8,16,1600,1200, 8,16,00h,0>
	tVms <70h,00000000b,200,66, 8,18, 8,16,1600,1200, 8,16,00h,0>
	tVms <70h,00000000b,200,60, 8,20, 8,16,1600,1200, 8,16,00h,0>
	tVms <70h,00000000b,132,50,12,24,12,24,1600,1200,12,24,00h,0>
	tVms <70h,00000000b,132,40,12,30,12,24,1600,1200,12,24,00h,0>
VideoModeCount = ($ - VideoModeTables) / (SIZE tVms)

FontModeTables	LABEL	tFont
	tFont <1,VT_VM_NORMAL,12,30,12,24,12,24, ExpS1230, ExpD2430, -1>
	tFont <1,VT_VM_NORMAL,12,24,12,24,12,24, -1, -1, -1>
	tFont <1,VT_VM_NORMAL, 8,20, 8,16, 8,16, ExpS0820, ExpD1620, -1>
	tFont <1,VT_VM_NORMAL, 8,18, 8,16, 8,16, ExpS0818, ExpD1618, -1>
	tFont <1,VT_VM_NORMAL, 8,16, 8,16, 8,16, -1, -1, -1>
FontModeCount = ($ - FontModeTables) / (SIZE tFont)

DspmTables	LABEL	tDspm
	tDspm <12,24,Disp12,Disp24,Xor12n,Left24,Right24>
	tDspm < 8,16,Disp8,Disp16,Xor8n,Left16,Right16>
DspmCount = ($ - DspmTables) / (SIZE tDspm)
DspmDummy	tDspm <?,?,DummyProc,DummyProc,DummyProc,DummyProc,DummyProc>

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
Primitive_Up	dw	ofs ScrollUp
Primitive_Down	dw	ofs ScrollDown
		dw	ofs SetCursorShape
		dw	ofs PutCursor
		dw	ofs EraseCursor
		dw	ofs SetPalette
		dw	ofs ChangeFont
		dw	ofs ReturnStateSize
		dw	ofs SaveState
		dw	ofs RestoreState
		dw	ofs ChangeState
		
		
DriverName	db	'Generic VBE 256 driver '
		db	'0'+DSPXVBE_MAJOR, '.'
		db	'0'+(DSPXVBE_MINOR SHR 4),'0'+(DSPXVBE_MINOR AND 15)
		;db	'test'
		db	' (c)鯖',0

G_DATA		ENDS

TSR_TEXT	SEGMENT

GetVmsVm	PROC	NEAR
	pushm	<cx>
	mov	si,ofs VbeModeTables
	mov	cx,VbeModeCount
@@srchvm:
	mov	ax,word ptr [bx + (tVms.vms_screenx)]
	cmp	ax,word ptr [si + (tVbepack.vbepk_scrnX)]
	jne	@@cnt
	mov	ax,word ptr [bx + (tVms.vms_screeny)]
	cmp	ax,word ptr [si + (tVbepack.vbepk_scrnY)]
	je	@@getvm
@@cnt:
	add	si,SIZE tVbepack
	loop	short @@srchvm
@@getvm:
	mov	ax,[si + (tVbepack.vbepk_vm)]
	popm	<cx>
	ret
GetVmsVm	ENDP

GetSfcBytes	PROC	NEAR
	pushm	<ax,dx>
	mov	ax,word ptr [sfc_max]
	inc	ax
	mov	cx,2 * 30
	mul	cx
	mov	cx,ax
	popm	<dx,ax>
	ret
GetSfcBytes	ENDP


ExpS0818	PROC	NEAR
	add	si,1
	call	[GetSbcsT]
	sub	si,1
	cmp	al,0
	jne	@@exit
	push	ax
	xor	ax,ax
	test	bl,1
	jz	@@2
	mov	al,byte ptr es:[si + 1]
	mov	ah,byte ptr es:[si + 16]
@@2:
	mov	byte ptr es:[si],al
	mov	byte ptr es:[si+17],ah
	pop	ax
@@exit:
	ret
ExpS0818	ENDP


ExpD1618	PROC	NEAR
	pushm	<ds>
	movseg	ds,es
	add	si,2
	call	[GetDbcsT]
	sub	si,2
	pushm	<ax,dx>
	test	bl,1
	jnz	short @@exp
	xor	ax,ax
	xor	dx,dx
@@exp_exit:
	mov	word ptr es:[si],ax
	mov	word ptr es:[si + (2 * 17)],dx
	popm	<dx,ax>
@@exit:
	popm	<ds>
	ret
@@exp:
	mov	ax,word ptr es:[si + 2]
	mov	dx,word ptr es:[si + (2 * 16)]
	jmps	@@exp_exit
ExpD1618	ENDP


ExpS0820	PROC	NEAR
	add	si,2
	call	[GetSbcsT]
	sub	si,2
	cmp	al,0
	jne	@@exit
	push	ax
	xor	ax,ax
	test	bl,1
	jz	@@2
	mov	al,byte ptr es:[si + 2]
	mov	ah,byte ptr es:[si + 17]
@@2:
	mov	byte ptr es:[si],al
	mov	byte ptr es:[si + 1],al
	mov	byte ptr es:[si + 18],ah
	mov	byte ptr es:[si + 19],ah
	pop	ax
@@exit:
	ret
ExpS0820	ENDP


ExpD1620	PROC	NEAR
	pushm	<ds>
	movseg	ds,es
	add	si,2 * 2
	call	[GetDbcsT]
	sub	si,2 * 2
	pushm	<ax,dx>
	test	bl,1
	jnz	short @@exp
	xor	ax,ax
	xor	dx,dx
@@exp_exit:
	mov	word ptr es:[si],ax
	mov	word ptr es:[si + 2],ax
	mov	word ptr es:[si + (2 * 18)],dx
	mov	word ptr es:[si + (2 * 19)],dx
	popm	<dx,ax>
@@exit:
	popm	<ds>
	ret
@@exp:
	mov	ax,word ptr es:[si + (2 * 2)]
	mov	dx,word ptr es:[si + (2 * 17)]
	jmps	@@exp_exit
ExpD1620	ENDP



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


Left24		PROC	NEAR
	mov	di,ofs DbcsHBuffer
	push	di
	mov	cx,word ptr [cheight]
@@lp:
	mov	ax,word ptr [si]
	mov	word ptr [di],ax
	add	si,3
	add	di,2
	dec	cx
	jnz	@@lp
	pop	si
	ret
Left24		ENDP

Right24		PROC	NEAR
	mov	di,ofs DbcsHBuffer
	push	di
	mov	cx,word ptr [cheight]
@@lp:
	mov	ax,word ptr [si+1]
	xchg	al,ah
	shl	ax,4
	xchg	al,ah
	mov	word ptr [di],ax
	add	si,3
	add	di,2
	dec	cx
	jnz	@@lp
	pop	si
	ret
Right24		ENDP


Right16		PROC	NEAR
	inc	si
Left16		LABEL	NEAR
	mov	di,ofs DbcsHBuffer
	push	di
	mov	cx,word ptr [cheight]
@@lp:
	mov	al,byte ptr [si]
	mov	byte ptr [di],al
	add	si,2
	inc	di
	dec	cx
	jnz	@@lp
	pop	si
	ret
Right16		ENDP


DispatchDspm	PROC	NEAR
	mov	si,ofs DspmTables
	mov	cx,DspmCount
@@lp:
	mov	al,[si + (tDspm.dspm_width)]
	cmp	al,[bx + (tVms.vms_charwidth)]
	je	@@dsp
	add	si,SIZE tDspm
	loop	@@lp
	mov	si,ofs DspmDummy
@@dsp:
	mov	ax,ds
	mov	es,ax
	mov	cx,(SIZE tDspm) / 2
	mov	di,ofs dspm
	rep	movsw
	ret
DispatchDspm	ENDP

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


DummyProc	PROC	NEAR
	ret
DummyProc	ENDP

SetToExtVm	PROC	FAR
	pushf
	cld
	pushm	<ax,bx>
	pushm	<si,ds>
	mov	bx,cs
	mov	ds,bx
	and	ax,00ffh
	shl	ax,4
	add	ax,ofs VideoModeTables
	mov	bx,ax
	call	GetVmsVm
	popm	<ds,si>
	mov	bx,ax
	mov	ax,4f02h
	_call_int10_cs
	popm	<bx,ax>
	;
	pusha
	pushm	<ds,es>
	cld
	mov	si,cs
	mov	ds,si
	mov	es,si
	and	ax,00ffh
	shl	ax,4
	add	ax,ofs VideoModeTables
	mov	bx,ax
	
	mov	ax,[bx + (tVms.vms_screeny)]
	mov	[screen_y],ax
	mov	al,[bx + (tVms.vms_columns)]
	mov	byte ptr [text_x],al
	mov	al,[bx + (tVms.vms_rows)]
	mov	byte ptr [text_y],al
	mul	byte ptr [bx + (tVms.vms_charheight)]
	mov	[screen_uy],ax
	
	call	GetVmsVm
	call	InitVbeVars16
	call	DispatchDspm
	mov	si,ofs FontModeTables
	mov	cx,FontModeCount
	call	AssignFont
	mov	si,ofs SbcsBuffer
	xor	cx,cx
@@sbcs_lp:
	call	[GetSbcs]
	add	si,[SbcsCharBytes]
	inc	cx
	cmp	cx,word ptr [sfc_max]
	jbe	@@sbcs_lp
	mov	[prev_y],-1

	popm	<es,ds>
	popa
	call	LoadDefaultPalette
	popf
	ret
SetToExtVm	ENDP


LoadDefaultPalette	PROC	NEAR
	push	ax
	xor	ax,ax
@@lp0:
	call	SetVesaPal
	add	ax,0101h
	cmp	al,05h
	jbe	@@lp0
	mov	ax,1406h
	call	SetVesaPal
	mov	ax,0707h
	call	SetVesaPal
	mov	ax,3808h
@@lp1:
	call	SetVesaPal
	add	ax,0101h
	cmp	al,0fh
	jbe	@@lp1
	pop	ax
	ret
LoadDefaultPalette	ENDP


ResetToVga	PROC	FAR
	pushm	<ax>
	pushf
	mov	ax,0012h
	_call_int10_cs
@@2:
	popf
	popm	<ax>
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
	call	[dspm.dspm_sbcs]
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
	call	[dspm.dspm_dbcs]
@@hh_brk:
	_prmexit
	;
@@hh:
	push	si
	call	[dspm.dspm_left]
	mov	dx,reg_dx
	mov	al,reg_al
	call	[dspm.dspm_sbcs]
	pop	si
	call	[dspm.dspm_right]
	mov	dx,reg_dx
	mov	al,reg_bl
	inc	dl
	call	[dspm.dspm_sbcs]
	;call	Disp24HandH
	jmps	@@hh_brk
WriteDbcsChar	ENDP


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


RectRollUp	PROC	NEAR
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
	ret
RectRollUp	ENDP

RectRollUpBp	PROC	NEAR
	push	bp
	push	dx			; ss:[bp+4]
	push	cx			; ss:[bp+2]
	push	ax			; ss:[bp]
	mov	bp,sp
	call	GetDestAddr
	movzx	eax,byte ptr ss:[bp]	; reg_al
	mov	ebx,[clinebytes]
	mul	ebx
	lea	esi,[edi + eax]
	mov	al,byte ptr ss:[bp+4]	; reg_dl
	sub	al,byte ptr ss:[bp+2]	; reg_cl
	inc	al
	mov	bl,[cwidth_s]
	mul	bl
	mov	cx,ax
	mov	al,byte ptr ss:[bp+5]	; reg_dh
	sub	al,byte ptr ss:[bp+3]	; reg_ch
	sub	al,byte ptr ss:[bp]	; reg_al
	inc	al
	mov	bl,[cheight]
	mul	bl
	mov	dx,ax
	call	[TfrProc]
	pop	ax
	pop	cx
	pop	dx
	pop	bp
	ret
RectRollUpBp	ENDP

RectRollDown	PROC	NEAR
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
	ret
RectRollDown	ENDP

RectRollDownBp	PROC	NEAR
	push	bp
	push	dx		; ss:[bp+4]
	push	cx		; ss:[bp+2]
	push	ax		; ss:[bp]
	mov	bp,sp
	mov	ch,dh
	push	cx
	sub	ch,al
	call	GetDestAddr
	pop	cx
	mov	esi,edi
	call	GetDestAddr
	mov	al,byte ptr ss:[bp+4]	; reg_dl
	sub	al,byte ptr ss:[bp+2]	; reg_cl
	inc	al
	mov	bl,[cwidth_s]
	mul	bl
	mov	cx,ax
	mov	dx,word ptr [cheight]
	mov	al,byte ptr ss:[bp+5]	; reg_dh
	sub	al,byte ptr ss:[bp+3]	; reg_ch
	sub	al,byte ptr ss:[bp]	; reg_al
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
	pop	ax
	pop	cx
	pop	dx
	pop	bp
	ret
RectRollDownBp	ENDP


ScrollUp	PROC	FAR
	_prmentry
	call	RectRollUp
	mov	[prev_y],-1
	_prmexit
ScrollUp	ENDP


ScrollUp_hw	PROC	FAR
	_prmentry
	mov	ah,dl
	sub	ah,cl
	inc	ah
	cmp	ah,byte ptr [text_x]		; x1-x0 + 1 < columns
	jb	@@sw
	mov	ah,byte ptr [text_y]
	sub	ah,dh
	add	ah,ch
	cmp	ah,8
	jb	@@2
@@sw:
	call	RectRollUp
	jmp	@@exit
@@2:
	mov	ah,byte ptr [text_y]
	dec	ah				; 画面下部にスクロールしない
	sub	ah,dh				; 部分はあるか？ 
	jbe	@@r_roof
	mov	ch,dh
	inc	ch				; (x0,y1+1)-(x1,rows+al-1)
	mov	dh,byte ptr [text_y]
	add	dh,al
	dec	dh
	call	RectRollDownBp
	mov	ax,reg_ax
	mov	cx,reg_cx
	mov	dx,reg_dx
@@r_roof:
	cmp	ch,0
	je	@@crtc
	mov	dh,ch
	dec	dh				; (x0,0)-(x1,y0-1+al)
	add	dh,al
	;dec	dh
	mov	ch,0
	call	RectRollDownBp
	mov	al,reg_al
@@crtc:
	movzx	eax,al
	mov	ecx,[clinebytes]
	mul	ecx
	mov	ecx,[crtcstart]
	add	eax,ecx
	and	eax,[crtcmask]
	mov	[crtcstart],eax
	call	SetCrtc
@@exit:
	mov	[prev_y],-1
	_prmexit
ScrollUp_hw	ENDP


ScrollDown	PROC	FAR
	_prmentry
	call	RectRollDown
	mov	[prev_y],-1
	_prmexit
ScrollDown	ENDP


ScrollDown_hw	PROC	FAR
	_prmentry
	mov	ah,dl
	sub	ah,cl
	inc	ah
	cmp	ah,byte ptr [text_x]		; x1-x0 + 1 < columns
	jb	@@sw
	mov	ah,byte ptr [text_y]
	sub	ah,dh
	add	ah,ch
	cmp	ah,8
	jb	@@2
@@sw:
	call	RectRollDown
	jmp	@@exit
@@2:
	movzx	eax,al
	mov	ecx,[clinebytes]
	mul	ecx
	mov	ecx,eax
	mov	eax,[crtcstart]
	sub	eax,ecx
	and	eax,[crtcmask]
	mov	[crtcstart],eax
	mov	ax,reg_ax
	mov	cx,reg_cx
	mov	dx,reg_dx
	cmp	ch,0
	je	@@btm
	mov	dh,ch
	dec	dh				; (x0,0)-(x1,y0-1+al)
	add	dh,al
	;dec	dh
	mov	ch,0
	call	RectRollUpBp
	mov	ax,reg_ax
	mov	cx,reg_cx
	mov	dx,reg_dx
@@btm:
	mov	ah,byte ptr [text_y]
	dec	ah				; 画面下部にスクロールしない
	sub	ah,dh				; 部分はあるか？ 
	jbe	@@crtc
	mov	ch,dh
	inc	ch				; (x0,y1+1)-(x1,rows+al-1)
	mov	dh,byte ptr [text_y]
	add	dh,al
	dec	dh
	call	RectRollUpBp
	
@@crtc:
	call	SetCrtc
@@exit:
	mov	[prev_y],-1
	_prmexit
ScrollDown_hw	ENDP



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
	call	[dspm.dspm_xor]
	_prmexit
PutCursor	ENDP

EraseCursor	PROC	FAR
	_prmentry
	mov	edi,[prev_csradd]
	mov	cx,word ptr [csr_height]
	call	[dspm.dspm_xor]
	_prmexit
EraseCursor	ENDP


COMMENT #
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
#

SetPalette	PROC	FAR
	pushf
	cld
	cmp	al,15
	ja	@@exit
	call	SetVesaPal
@@exit:
	popf
	ret
SetPalette	ENDP

SetVesaPal	PROC	NEAR
	pushm	<bx,cx,dx,di,bp,ds,es>
	push	ax
	mov	bp,sp
	mov	al,ah
	xor	ah,ah
	mov	dx,cs
	mov	ds,dx
	mov	es,dx
	mov	di,ofs LineBuffer
	mov	bx,ofs DefaultPalette
	add	bx,ax
	add	bx,ax
	add	bx,ax
	mov	al,byte ptr [bx + 2]	; b
	mov	ah,byte ptr [bx + 1]	; g
	mov	word ptr [di],ax
	xor	ax,ax
	mov	al,byte ptr [bx]	;r
	mov	word ptr [di + 2],ax
	cmp	[VbeVersion],0200h
	jb	@@vga
	mov	dx,word ptr ss:[bp]
	xor	dh,dh
	mov	cx,1
	mov	ax,4f09h
	mov	bx,0
	_call_int10
	cmp	ax,004fh
	jne	@@vga
	xor	byte ptr [di],00111111b
	xor	byte ptr [di + 1],00111111b
	xor	byte ptr [di + 2],00111111b
	mov	dx,word ptr ss:[bp]
	xor	dh,dh
	not	dl
	mov	cx,1
	mov	ax,4f09h
	mov	bx,0
	_call_int10
	jmps	@@exit

@@vga:
	mov	cl,byte ptr [di]
	mov	ch,byte ptr [di + 1]
	mov	dh,byte ptr [di + 2]
	mov	bx,word ptr ss:[bp]
	xor	bh,bh
	mov	ax,1010h
	_call_int10
	mov	cl,byte ptr [di]
	mov	ch,byte ptr [di + 1]
	mov	dh,byte ptr [di + 2]
	xor	dh,00111111b
	xor	ch,00111111b
	xor	cl,00111111b
	mov	bx,word ptr ss:[bp]
	xor	bh,bh
	not	bl
	mov	ax,1010h
	_call_int10
	
@@exit:
	pop	ax
	popm	<es,ds,bp,di,dx,cx,bx>
	ret
SetVesaPal	ENDP

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
		IFDEF	Revision
		db	Revision
		ENDIF
		IFDEF	W64K
		db	' (64K-Windowed)'
		ENDIF
		db	' (c)鯖/LP-Project. 1996-1997, 2018',CR,LF,0
msgHelp		db	'VESA BIOS 汎用の IBM DOS/V Extension ビデオ拡張'
		db	'ドライバです。',CR,LF
		db	CR,LF
		db	'DSPXVBE [/HS=ON|OFF] [/SFC=ON|HALF|OFF] '
		db	'[/NOUMB] [/R]',CR,LF
		db	CR,LF
		db	'  /HS=OFF',HT,'ハードウェアスクロールを行いません'
		db	'（初期値）。',CR,LF
		db	'  /HS=ON',HT,'ハードウェアスクロールを行います'
		db	'（運がよければ動作します）。',CR,LF
		db	'  /SFC=OFF',HT,'半角フォントをメモリにキャッシュ'
		db	'しません。',CR,LF
		db	'  /SFC=HALF',HT,'半角フォントの前半１２８文字を'
		db	'キャッシュします（初期値）。',CR,LF
		db	'  /SFC=ON',HT,'半角フォントをすべてキャッシュ'
		db	'します。',CR,LF
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

sSFC		db	'SFC='
cSFC = ($ - sSFC)
sON		db	'ON',0
sOFF		db	'OFF',0
sALL		db	'ALL',0
sHALF		db	'HALF',0
sNONE		db	'NONE',0



_DATA		ENDS

_TEXT		SEGMENT


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
	mov	byte ptr [sfc_max],255
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
	mov	[sfc_max],0
	jmp	@@process
@@4_3:
	mov	si,bx
	mov	di,ofs sHALF
	call	StrCmp
	jne	@@4_4
	mov	[sfc_max],127
	jmp	@@process
@@4_4:
	mov	ax,8081h		; err and break
	jmp	@@exit
@@5:
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
	test	byte ptr [bx + (tVms.vms_info)],80h
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
	test	byte ptr [bx + (tVms.vms_info)],80h
	jnz	@@no_thru
	mov	[cvm_novm],1
	jmps	@@no_set
@@no_set:				; 使えない
	mov	ax,80h
	or	byte ptr [bx + (tVms.vms_info)],80h
	jmps	@@exit
@@no_thru:				; 使えない（もともと使えなかった）
	mov	ax,0
	jmps	@@exit
@@avail:				; 使える
	and	byte ptr [bx + (tVms.vms_info)],7fh
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
	cmp	[opt_hs_mdfy],0
	je	@@pal
	cmp	[opt_hs],2
	jb	@@pal
	mov	cs:[Primitive_Up],ofs ScrollUp_hw
	mov	cs:[Primitive_Down],ofs ScrollDown_hw
	;
@@pal:
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
COMMENT #
--------------------------------------------------
	REPT	256
		bitsexp8b $bitstbl$, BITSEXP_BASE
	$bitstbl$ = $bitstbl$ + 1
	ENDM
--------------------------------------------------
#
	.LIST
Colortbl	LABEL	DWORD
	$colortbl$ = 00000000h
	REPT	16
		dd	$colortbl$
	$colortbl$ = $colortbl$ + 01010101h
	ENDM
G_DATA		ENDS
L_DATA		SEGMENT

		ALIGN	4

crtcstart	dd	?
crtcmask	dd	0ffffffffh
curwnd_w	dw	?
curwnd_r	dw	?
windex_w	dw	?	; 書き込みウインドウ番号
wseg_w		dw	?	; 書き込みウインドウセグメント
windex_r	dw	?
wseg_r		dw	?

screen_y	dw	?	; 画面縦ドット数 
screen_uy	dw	?	; 使う縦ドット数（文字高さ * 縦文字数） 

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

InitVbeVars16	PROC	NEAR
	pushm	<ax,cx,dx>
	mov	ax,[si + (tVbepack.vbepk_bpl)]
	mov	cx,ax
	mov	word ptr [slinebytes],ax
	xor	dx,dx
	mov	word ptr [slinebytes + 2],dx
	mov	word ptr [slinebytes_s + 2],dx
	mov	word ptr [slinebytes_d + 2],dx
	mov	dl,[bx + (tVms.vms_charwidth)]
	mov	[cwidth_s],dl
	sub	cx,dx
	mov	word ptr [slinebytes_s],cx
	sub	cx,dx
	mov	word ptr [slinebytes_d],cx
	add	dl,dl
	mov	[cwidth_d],dl
	xor	cx,cx
	mov	cl,[bx + (tVms.vms_charheight)]
	mov	[cheight],cl
	mul	cx
	mov	word ptr [clinebytes],ax
	mov	word ptr [clinebytes+2],dx
	mov	ax,word ptr [si + (tVbepack.vbepk_wsize)]
	mov	dx,word ptr [si + (tVbepack.vbepk_wsize + 2)]
	mov	word ptr [wframesize],ax
	mov	word ptr [wframesize + 2],dx
	sub	ax,1
	sbb	dx,0
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

	mov	ax,word ptr [Vramtotal]
	mov	dx,word ptr [Vramtotal +2]
	sub	ax,1
	sbb	dx,0
	mov	word ptr [crtcmask],ax
	mov	word ptr [crtcmask + 2],dx
	mov	cx,[wframeshift]
@@sh_lp:
	shr	dx,1
	rcr	ax,1
	loop	@@sh_lp
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
	xor	ax,ax
	mov	word ptr [crtcstart],ax
	mov	word ptr [crtcstart+2],ax
	pop	bx
	
	popm	<dx,cx,ax>
	ret
InitVbeVars16	ENDP


SetCrtc		PROC	NEAR
	pushm	<ax,bx,cx,dx>
	mov	ax,word ptr [crtcstart]
	mov	dx,word ptr [crtcstart + 2]
	mov	cx,word ptr [slinebytes]
	div	cx
	mov	cx,dx
	mov	dx,ax
	mov	ax,4f07h
	xor	bx,bx
	_call_int10
	popm	<dx,cx,bx,ax>
	ret
SetCrtc		ENDP

;-------------------------------------
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

Xor8n		PROC	NEAR
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
	sub	bx,4
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
	add	di,bx
	jc	@@chgwr2
	cmp	di,dx
	ja	@@chgwr2
@@chgwr2_brk:
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
Xor8n		ENDP

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

COMMENT !
---------------------------------------
Vram2Vram1w	PROC	NEAR
	pushm	<esi,edi>
	push	cx
	mov	cx,[wframeshift]
	mov	ax,[curwndmask]
	mov	edx,edi
	shr	edx,cl
	and	di,[wframemask]
	and	dx,ax
	mov	bx,dx
	mov	edx,esi
	shr	edx,cl
	and	si,[wframemask]
	and	dx,ax
	pop	cx
	mov	[curwnd_r],dx
	cmp	dx,[curwnd_w]		; 前の Wnd No.と違うときは(Readに)更新 
	jne	@@sel_rd
@@sel_rd_brk:
	mov	[curwnd_w],bx
	cmp	bx,dx			; Read と Write の Window が違う？ 
	jne	@@diff
					; R/W Length が Window をはみ出すか?
	mov	dx,[wframemask]
	mov	ax,si
	add	ax,cx
	jc	@@diff
	cmp	ax,dx
	ja	@@diff
	mov	ax,di
	add	ax,cx
	jc	@@diff
	cmp	ax,dx
	ja	@@diff
					; どちらもはみ出さないようなら･･･
					; 普通に転送しておしまい 
	push	ds
	mov	ax,[wseg_w]
	mov	es,ax
	mov	ds,ax
	shr	cx,2
	rep	movsd
	pop	ds
@@exit:
	popm	<edi,esi>
	ret
@@sel_rd:
	push	bx
	mov	[curwnd_r],dx
	mov	bx,[windex_w]
	call	[wselproc]
	pop	bx
	jmps	@@sel_rd_brk
;
;
@@diff:
	mov	[curwnd_w],bx
	mov	dx,[curwnd_r]
	mov	ax,[wseg_w]
	mov	es,ax
	mov	bx,[wframemask]
	;
	; Read Wnd から LineBuffer へ
	;
	pushm	<cx,di>
	mov	di,ofs LineBuffer
@@lp_rd:
	mov	eax,dword ptr es:[si]
	mov	dword ptr [di],eax
	add	di,4
	add	si,4
	jc	@@incr_rd
	cmp	si,bx
	ja	@@incr_rd
@@incr_rd_brk:
	sub	cx,4
	jbe	@@rd_exit
	mov	eax,dword ptr es:[si]
	mov	dword ptr [di],eax
	add	di,4
	add	si,4
	jc	@@incr_rd
	cmp	si,bx
	ja	@@incr_rd
	sub	cx,4
	jbe	@@rd_exit
	jmps	@@lp_rd
@@rd_exit:
	popm	<di,cx>
	;
	; LineBuffer から Read Wnd へ 
	;
	mov	si,ofs LineBuffer
	mov	dx,[curwnd_w]
	cmp	dx,[curwnd_r]
	je	@@lp_wr_pre
	mov	bx,[windex_w]
	mov	[curwnd_r],dx
	call	[wselproc]
@@lp_wr_pre:
	mov	bx,[wframemask]
@@lp_wr:
	mov	eax,dword ptr [si]
	mov	dword ptr es:[di],eax
	add	si,4
	add	di,4
	jc	@@incr_wr
	cmp	di,bx
	ja	@@incr_wr
@@incr_wr_brk:
	sub	cx,4
	jbe	@@exit
	mov	eax,dword ptr [si]
	mov	dword ptr es:[di],eax
	add	si,4
	add	di,4
	jc	@@incr_wr
	cmp	di,bx
	ja	@@incr_wr
	sub	cx,4
	jbe	@@exit
	jmp	@@lp_wr
;
@@incr_rd:
	push	bx
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	bx,[windex_w]
	mov	[curwnd_r],dx
	call	[wselproc]
	pop	bx
	jmp	@@incr_rd_brk
;
@@incr_wr:
	push	bx
	add	dx,[wframedepth]
	and	dx,[curwndmask]
	mov	bx,[windex_w]
	mov	[curwnd_w],dx
	call	[wselproc]
	pop	bx
	jmps	@@incr_wr_brk
Vram2Vram1w	ENDP
---------------------------------------
!


	ALIGN	16

Vram2Vram1w2	PROC	NEAR
	pushm	<esi,edi>
	push	cx
	mov	ax,cx
	mov	edx,esi
	mov	cx,[wframeshift]
	shr	edx,cl
	and	dx,[curwndmask]
	and	si,[wframemask]
	mov	[curwnd_r],dx
	mov	cx,ax
	cmp	dx,[curwnd_w]
	jne	@@sel_rd
@@sel_rd_brk:
	push	cx
	push	di
	mov	di,ofs LineBuffer
	;
	; VRAM -> Buffer
	;
	mov	ax,word ptr [wframesize]
	sub	ax,si
	movseg	es,ds
	mov	ds,[wseg_w]
	je	@@rd_nochg
	cmp	ax,cx
	jae	@@rd_nochg
@@rd_chg:
	pushm	<ax,cx>
	mov	cx,ax
	shr	cx,2
	rep	movsd
	;
	; Read Window +1
	;
	mov	dx,cs:[curwnd_r]
	add	dx,cs:[wframedepth]
	and	si,cs:[wframemask]
	and	dx,cs:[curwndmask]
	mov	bx,cs:[windex_w]
	mov	cs:[curwnd_r],dx
	call	cs:[wselproc]
	popm	<cx,ax>
	sub	cx,ax
	shr	cx,2
	rep	movsd
	jmps	@@buf2vram
	
	ALIGN	16
@@rd_nochg:
	shr	cx,2
	rep	movsd
@@buf2vram:
	pop	di
	movseg	es,ds
	movseg	ds,cs
	mov	edx,edi
	mov	cx,[wframeshift]
	shr	edx,cl
	and	dx,[curwndmask]
	and	di,[wframemask]
	mov	[curwnd_w],dx
	pop	cx
	cmp	dx,[curwnd_r]
	jne	@@sel_wr
@@sel_wr_brk:
	mov	si,ofs LineBuffer
	mov	ax,word ptr [wframesize]
	sub	ax,di
	je	@@wr_nochg
	cmp	ax,cx
	jae	@@wr_nochg
	;
@@wr_chg:
	pushm	<ax,cx>
	mov	cx,ax
	shr	cx,2
	rep	movsd
	;
	; Write Window + 1
	;
	call	WndIncr_w
	popm	<cx,ax>
	sub	cx,ax
	shr	cx,2
	rep	movsd
	jmps	@@exit

	ALIGN	16
@@wr_nochg:
	shr	cx,2
	rep	movsd
@@exit:
	mov	dx,[curwnd_w]
	mov	[curwnd_r],dx
	pop	cx
	popm	<edi,esi>
	ret
	
;
	ALIGN	16
@@sel_rd:
	mov	bx,[windex_w]
	call	[wselproc]
	jmp	@@sel_rd_brk
	ALIGN	16
@@sel_wr:
	mov	bx,[windex_w]
	call	[wselproc]
	jmp	@@sel_wr_brk
Vram2Vram1w2	ENDP


TfrLine1w		PROC	NEAR
	pushm	<dx,bp,esi,edi>
	push	cx		; ss:[bp+2] ドット単位の横幅
	push	dx		; ss:[bp] ドット単位の高さ
	mov	bp,sp
@@lp:
	mov	cx,word ptr ss:[bp+2]
	call	Vram2Vram1w2
	add	esi,[slinebytes]
	add	edi,[slinebytes]
	dec	word ptr ss:[bp]
	jne	@@lp
	;
	add	sp,2
	pop	cx
	popm	<edi,esi,bp,dx>
	ret
TfrLine1w		ENDP




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
	mov	cx,ax
	movseg	es,cs
	mov	di,ofs Tmpbuff + 512
	
	mov	word ptr es:[di + (tVesam.vesam_attr)],0
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
	; VESA 1.2 で決まってるモードはチェックはしょる（高速化のため） 
	cmp	cx,0100h
	jb	@@creso_2
	cmp	cx,011bh
	ja	@@creso_2
	jmps	@@creso_lp
@@creso_2:
	movseg	es,cs
	mov	di,ofs Tmpbuff + 512
	mov	word ptr es:[di + (tVesam.vesam_attr)],0
	;
	pushm	<cx,di>
	mov	cx,256
	xor	ax,ax
	rep	stosb
	popm	<di,cx>
	;
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
	mov	dx,es:[di + (tVesam.vesam_attr)]
	and	dx,0000000001010001b
	cmp	dx,0000000000010001b
	jne	@@gra_invld
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
	mov	word ptr [si + (tVbepack.vbepk_vm)],-1
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
	;
	pushm	<cx,di>
	mov	cx,256
	xor	ax,ax
	rep	stosw
	popm	<di,cx>
	;
	mov	word ptr es:[di],'BV'
	mov	word ptr es:[di+2],'2E'
	mov	ax,4f00h
	_call_int10
	cmp	ax,004fh
	jne	@@err
	cmp	word ptr es:[di],'EV'
	jne	@@err
	cmp	word ptr es:[di+2],'AS'
	jne	@@err
	mov	ax,word ptr es:[di + (tVesainf.vesai_vm)]
	mov	word ptr [VMArray],ax
	mov	ax,word ptr es:[di + (tVesainf.vesai_vm) + 2]
	mov	word ptr [VMArray + 2],ax
	mov	ax,es:[di + (tVesainf.vesai_total)]
	mov	word ptr [Vramtotal],0
	mov	word ptr [Vramtotal+2],ax
	mov	ax,es:[di + (tVesainf.vesai_ver)]
	mov	[VbeVersion],ax
	jmps	@@exit
@@err:
	mov	ax,0
@@exit:
	popm	<es,di,dx>
	ret
ChkVbe		ENDP


_TEXT		ENDS
_DATA		SEGMENT
Buf_Entry	dw	ofs SbcsBuffer
Buf_Size	dw	SbcsBufferBottom - SbcsBuffer
_DATA		ENDS

		END
