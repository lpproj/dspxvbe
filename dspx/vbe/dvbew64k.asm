COMMENT #
===============================================================================
 dvbew64k.asm
===============================================================================
#

DSPX$DVBEDISP = 0001h

		INCLUDE mydef.inc
		INCLUDE dspx.inc
		INCLUDE dspxseg.inc
		INCLUDE dspxvbe.inc
		INCLUDE dvbedisp.inc
		
		IFDEF	??version
		LOCALS
		ENDIF

		.386

TSR_TEXT	SEGMENT


_DispD		MACRO	proc_nc, proc_1l
	pushm	<bp>
	call	PrepareDisp
	mov	ax,di
	add	ax,word ptr [clinebytes]
	jc	@@cw
	mov	bp,word ptr [cheight]
	call	proc_nc
	popm	<bp>
	ret
@@cw:
	push	dx
	xor	ax,ax
	mov	dx,1
	sub	ax,di
	sbb	dx,0
	div	word ptr [slinebytes]
	pop	dx
	push	ax
	cmp	ax,0
	je	@@cw_chg
	mov	bp,ax
	call	proc_nc
	mov	ax,word ptr [slinebytes]
	sub	di,ax
	add	di,ax
	jc	@@chgwnd
@@cw_chg:
	call	proc_1l
	pop	ax
	add	ax,1
	mov	bp,word ptr [cheight]
	sub	bp,ax
	jbe	@@cw_exit
	call	proc_nc
@@cw_exit:
	popm	<bp>
	ret
	
	ALIGN	4
@@chgwnd:
	push	ofs @@cw_chg
	jmp	WndIncr_w
ENDM



COMMENT #
-------------------------------------------------------------------------------
 PrepareDisp
 dl...x, dh...y
 al...attr
 
 [result]
 ecx ... FG MASK
 edx ... BG MASK
 vesa window select (dx)
 es:di ... destination addr
 
-------------------------------------------------------------------------------
#

	ALIGN	16

PrepareDisp	PROC	NEAR
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
	xor	eax,eax
	mov	al,ch
	shr	al,4
	mov	edx,dword ptr [eax * 4 + ofs Colortbl]	; BG mask
	mov	al,ch
	and	al,0fh
	mov	ecx,dword ptr [eax * 4 + ofs Colortbl]	; FG mask
	mov	es,[wseg_w]
	ret

@@chgw0:
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	jmps	@@chgw0_brk
PrepareDisp	ENDP



COMMENT #
-------------------------------------------------------------------------------
 Disp12
 dl...x  dh...y
 al...属性
 ds:si...文字ビットマップ先頭
-------------------------------------------------------------------------------
#

	ALIGN	16

Disp8		PROC	NEAR
	_DispD	D08nc, D08c_1l
Disp8		ENDP

	ALIGN	16

Disp12		PROC	NEAR
	_DispD	D12nc, D12c_1l
Disp12		ENDP

	ALIGN	16

Disp16		PROC	NEAR
	_DispD	D16nc, D16c_1l
Disp16		ENDP

	ALIGN	16

Disp24		PROC	NEAR
	_DispD	D24nc, D24c_1l
Disp24		ENDP


COMMENT #
-------------------------------------------------------------------------------
 D12nc
 
 es:di  ... destination
 ds:si  ... source
 bp     ... 高さ
 
 ecx    ... FG のマスク値
 edx    ... BG のマスク値
 
 di, si は更新される
 cx は破壊される（というより、正常終了するとゼロになる)
 
-------------------------------------------------------------------------------
#
	ALIGN	16

D08nc		PROC	NEAR
@@lp:
	_DOnceL	0,0
	_DOnceR	4,0
	inc	si
	add	di,word ptr [slinebytes]
	dec	bp
	jne	@@lp
	ret
	
D08nc		ENDP

	ALIGN	16

D08c_1l		PROC	NEAR
	_DOnceL	0,0
	_DOnceR	4,0
	inc	si
	add	di,word ptr [slinebytes]
	jc	short @@incw_1
	ret
@@incw_1:
	jmp	WndIncr_w
D08c_1l		ENDP


	ALIGN	16

D12nc		PROC	NEAR
@@lp:
	_DOnceL	0,0
	_DOnceR	4,0
	_DOnceL	8,1
	add	si,2
	add	di,word ptr [slinebytes]
	dec	bp
	jne	@@lp
	ret
D12nc		ENDP


D12c_1l		PROC	NEAR
	_DOnceL	0,0
	add	di,4
	jc	@@incw_1
@@incb_1:
	_DOnceR	0,0
	add	di,4
	jc	@@incw_2
@@incb_2:
	_DOnceL	0,1
	add	si,2
	mov	ax,word ptr [slinebytes]
	sub	ax,8
	add	di,ax
	jc	@@incw_3
@@incb_3:
	ret
@@incw_1:
	push	ofs @@incb_1
	jmp	WndIncr_w
@@incw_2:
	push	ofs @@incb_2
	jmp	WndIncr_w
@@incw_3:
	push	ofs @@incb_3
	jmp	WndIncr_w
	
D12c_1l		ENDP

	ALIGN	16

D16nc		PROC	NEAR
@@lp:
	_DOnceL	0,0
	_DOnceR	4,0
	_DOnceL	8,1
	_DOnceR	12,1
	add	si,2
	add	di,word ptr [slinebytes]
	dec	bp
	jne	@@lp
	ret
D16nc		ENDP

	ALIGN	16

D16c_1l		PROC	NEAR
	_DOnceL	0,0
	_DOnceR	4,0
	add	di,8
	jc	@@incw_1
@@incb_1:
	_DOnceL	0,1
	_DOnceR	4,1
	add	si,2
	mov	ax,word ptr [slinebytes]
	sub	ax,8
	add	di,ax
	jc	@@incw_2
	ret
@@incw_1:
	push	ofs @@incb_1
@@incw_2:
	jmp	WndIncr_w
D16c_1l		ENDP

	ALIGN	16

D24nc		PROC	NEAR
@@lp:
	_DOnceL	0,0
	_DOnceR	4,0
	_DOnceL	8,1
	_DOnceR	12,1
	_DOnceL	16,2
	_DOnceR	20,2
	add	si,3
	add	di,word ptr [slinebytes]
	dec	bp
	jne	@@lp
	ret
D24nc		ENDP


D24c_1l		PROC	NEAR
	_DOnceL	0,0
	add	di,4
	jc	@@incw_1
@@incb_1:
	_DOnceR	0,0
	add	di,4
	jc	@@incw_2
@@incb_2:
	_DOnceL	0,1
	add	di,4
	jc	@@incw_3
@@incb_3:
	_DOnceR	0,1
	add	di,4
	jc	@@incw_4
@@incb_4:
	_DOnceL	0,2
	add	di,4
	jc	@@incw_5
@@incb_5:
	_DOnceR	0,2
	add	si,3
	mov	ax,word ptr [slinebytes]
	sub	ax,20
	add	di,ax
	jc	@@incw_6
@@incb_6:
	ret
	;
@@incw_1:
	push	ofs @@incb_1
	jmp	WndIncr_w
@@incw_2:
	push	ofs @@incb_2
	jmp	WndIncr_w
@@incw_3:
	push	ofs @@incb_3
	jmp	WndIncr_w
@@incw_4:
	push	ofs @@incb_4
	jmp	WndIncr_w
@@incw_5:
	push	ofs @@incb_5
	jmp	WndIncr_w
@@incw_6:
	push	ofs @@incb_6
	jmp	WndIncr_w
D24c_1l		ENDP

TSR_TEXT	ENDS

		END
