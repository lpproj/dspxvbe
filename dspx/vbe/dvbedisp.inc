COMMENT #
-------------------------------------------------------------------------------
 dvbedisp.inc
-------------------------------------------------------------------------------
#

	IFDEF	DSPX$DVBEDISP


_DOnce_		MACRO	oval
	lea	bx,[eax * Bitssize + ofs Bitstbl]
	mov	eax,dword ptr [bx]
	mov	ebx,eax
	xor	eax,(01010101h * BITSEXP_BASE)
	and	eax,edx				; BG
	and	ebx,ecx				; FG
	or	eax,ebx				; FG + BG
	mov	dword ptr es:[di + oval],eax
ENDM

_DOnceL		MACRO	oval, ival
	movzx	eax, byte ptr [si + ival]
	shr	al,4
	_DOnce_	oval
ENDM

_DOnceR		MACRO	oval, ival
	movzx	eax, byte ptr [si + ival]
	and	al,15
	_DOnce_	oval
ENDM



		EXTRN	Bitstbl : DWORD
		EXTRN	Colortbl : DWORD
		
		EXTRN	crtcstart : DWORD, crtcmask : DWORD
		EXTRN	curwnd_w : WORD, curwnd_r : WORD
		EXTRN	windex_w : WORD
		EXTRN	wseg_w : WORD
		EXTRN	windex_r : WORD
		EXTRN	wseg_r : WORD
		
		EXTRN	slinebytes : DWORD
		EXTRN	slinebytes_s : DWORD, slinebytes_d : DWORD
		EXTRN	clinebytes : DWORD
		
		EXTRN	wselproc : DWORD
		EXTRN	wframesize : DWORD
		EXTRN	wframemask : WORD
		EXTRN	wframeshift : WORD, wframedepth : WORD
		EXTRN	curwndmask : WORD
		EXTRN	cwidth_s : BYTE, cwidth_d : BYTE, cheight : BYTE
		
		EXTRN	WndIncr_w : NEAR, WndIncr_wcs : NEAR
		EXTRN	WndIncr_r : NEAR
		
		PUBLIC	Disp8
		PUBLIC	Disp16
		PUBLIC	Disp12
		PUBLIC	Disp24
		
	ELSE
		PUBLIC	Bitstbl
		PUBLIC	Colortbl
		
		PUBLIC	crtcstart, crtcmask
		PUBLIC	curwnd_w, curwnd_r
		PUBLIC	windex_w
		PUBLIC	wseg_w
		PUBLIC	windex_r
		PUBLIC	wseg_r
	
		PUBLIC	slinebytes
		PUBLIC	slinebytes_s, slinebytes_d
		PUBLIC	clinebytes
		
		PUBLIC	wselproc
		PUBLIC	wframesize
		PUBLIC	wframemask, wframeshift, wframedepth
		PUBLIC	curwndmask
		PUBLIC	cwidth_s, cwidth_d, cheight
		
		PUBLIC	WndIncr_w, WndIncr_wcs
		PUBLIC	WndIncr_r
		
		EXTRN	Disp8 : NEAR, Disp16 : NEAR
		EXTRN	Disp12 : NEAR, Disp24 : NEAR
	ENDIF
