COMMENT #
===============================================================================
 dvbedisp.asm
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


COMMENT #
-------------------------------------------------------------------------------
 Disp8n
 dl...x  dh...y
 al...属性
 ds:si...文字ビットマップ先頭
-------------------------------------------------------------------------------
#
	ALIGN	16

Disp8Proc	PROC	NEAR
@@chgw0:
	mov	[curwnd_w],dx
	mov	bx,[windex_w]
	call	[wselproc]
	jmps	@@chgw0_brk
Disp8		LABEL	NEAR
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
	sub	ax,4
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di+4],eax
	
	add	si,1
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,word ptr ss:[bp+2]
	jc	@@chgw2
	cmp	di,[wframemask]
	ja	@@chgw2
@@chgw2_brk:
@@chgw3_brk:
	add	si,1
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

Disp8Proc	ENDP

	ALIGN	16


Disp16Proc	PROC	NEAR
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
Disp16		LABEL	NEAR
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
	sub	ax,12
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx
	and	ebx,ecx
	or	eax,ebx
	mov	dword ptr es:[di],eax
	add	di,word ptr ss:[bp+2]
	jc	@@chgw4
	cmp	di,[wframemask]
	ja	@@chgw4
@@chgw4_brk:

	add	si,2
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
	

Disp16Proc	ENDP



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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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
	lea	bx,[eax * Bitssize + ofs Bitstbl]
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



TSR_TEXT	ENDS

		END
