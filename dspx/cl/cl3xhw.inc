COMMENT #
===============================================================================
 cl3xhw.inc

 Init_acc	アクセラレータ関係初期化
 ds:di tBltini のポインタ

 Init_csr	カーソル関係初期化
 dx,ax,si は破壊される

 TfrMem2Scrn	メモリ→画面へBitBlt（モノクロをカラー拡張）
 ds:di	tBlt へのポインタ
 eax,cx,si,di,es は破壊される。

 TfrScrn2Scrn	画面→画面のBitBlt
 ds:di	tBlt へのポインタ
 es = ds に設定しておくこと。
 eax,cx,si,di は破壊される。

 TfrScrn2ScrnX	画面→画面のBitBlt（モノクロをカラー拡張）
 ds:di	tBlt へのポインタ
 es = ds に設定しておくこと。
 eax,cx,si,di は破壊される。

 BltFillRect	純色での矩形塗り潰し
 ds:di	tBlt へのポインタ
 es = ds に設定しておくこと。
 eax,cx,si,di は破壊される。

 InvertRect	矩形色反転
 ds:di	tBlt へのポインタ
 es = ds に設定しておくこと。
 eax,cx,si,di は破壊される。

 MoveToScrn	メインメモリから任意オフセットのビデオメモリに転送
 ds:si メモリのアドレス
 ebx   ビデオメモリのオフセット
 cx    転送バイト数

 MoveFromScrn	ビデオメモリからメインメモリに転送
 ebx   ビデオメモリのオフセット
 es:di メモリのアドレス
 cx    転送バイト数
 
 SetWindowOffset ウィンドウオフセットレジスタの設定
 ebx   ビデオメモリのオフセット
 [result]
  di ... 実際のメモリ上でのオフセット
  あとは S-VGA のオフセットレジスタにオフセットが書き込まれる
 （上の３つはフォントキャッシュデータ、カーソルパターン転送用）

 SetHWCsrPos	ハードウェアカーソルの位置を決める
 ax	X
 dx	Y
 ax,dx,bx は破壊される。

 SetHWCsrPtn	ハードウェアカーソルパターンを設定する
 ds:si	tCsrSize のポインタ
 csiz_width か csiz_height が０の時はカーソルは表示しないようにする。
 （透明カーソルに設定する）

 


===============================================================================
#

		IFDEF $DSPX$CL3XHW$

CLB_ROP_BLACK	EQU	00h		; BLACKNESS
CLB_ROP_SRC	EQU	0dh		; SRCCOPY
CLB_ROP_WHITE	EQU	0eh		; WHITENESS
CLB_ROP_NOT	EQU	0bh		; DSTINVERT
CLB_ROP_SRCNOT	EQU	0d0h		; NOTSRC


CLB_BLT_COPY	EQU	00000000b	; Scrn to scrn
CLB_BLT_COPYREV	EQU	00000001b	; Scrn to scrn , direction reverse
CLB_BLT_COPYEXP	EQU	10000000b	; Scrn to scrn with color expand
CLB_BLT_MEMEXP	EQU	10000100b	; Mem to scrn with color expand
CLB_BLT_PTNEXP	EQU	11000000b	; 8x8 b/w pattern expand


tClb		STRUC		; MEMORY-Mapped BitBlt registers
clb_bg		db	?
clb_bg1		db	?
clb_bg2		db	?
clb_bg3		db	?
clb_fg		db	?
clb_fg1		db	?
clb_fg2		db	?
clb_fg3		db	?
clb_width	dw	?
clb_height	dw	?
clb_destpitch	dw	?
clb_srcpitch	dw	?
clb_dest	dd	?
clb_src		dd	?	; 最上位バイトは Blt destination write mask
clb_mode	db	?
clb_offset19	db	?	; (reserved)
clb_rop		db	?
clb_extmode	db	0	; (GR33)
tClb		ENDS

clb_status	EQU	0040h

_wait_acc	MACRO
	LOCAL	p1
p1:
	sti
	mov	dx,03ceh
	mov	al,31h
	cli
	out	dx,al
	inc	dx
	in	al,dx
	test	al,00001000b
	;test	al,00000001b
	jnz	short p1
ENDM


_write_acc	MACRO
	mov	ax,0b800h
	mov	es,ax
	xor	di,di
	mov	cx,((SIZE tClb) + 3) SHR 2
	rep	movsd
ENDM


_write_acc_start	MACRO
	_write_acc
	mov	byte ptr es:[0040h],00000010b
ENDM


		
		PUBLIC	Init_acc, Init_csr
		
		PUBLIC	TfrMem2Scrn, TfrScrn2Scrn
		PUBLIC	TfrScrn2ScrnX
		PUBLIC	BltFillRect, InvertRect
		PUBLIC	BltAbort
		
		PUBLIC	SetWindowOffset, MoveToScrn
		PUBLIC	SetHWCsrPos, SetHWCsrPtn, DisplayHWCsr, EraseHWCsr
		
		PUBLIC	SetBltMode
		
;-----------------------------------------------------------------------------
		ELSE
		
		EXTRN	Init_acc:NEAR, Init_csr:NEAR
		
		EXTRN	TfrMem2Scrn:NEAR
		EXTRN	TfrScrn2Scrn:NEAR, TfrScrn2ScrnX:NEAR
		EXTRN	BltFillRect:NEAR, InvertRect:NEAR
		EXTRN	BltAbort:NEAR
		
		EXTRN	SetWindowOffset:NEAR, MoveToScrn:NEAR
		EXTRN	SetHWCsrPos:NEAR, DisplayHWCsr:NEAR, EraseHWCsr:NEAR
		EXTRN	SetHWCsrPtn:NEAR
		
		EXTRN	SetBltMode:NEAR
		
		ENDIF

