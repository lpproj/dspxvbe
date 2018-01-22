COMMENT #
==============================================================================
 dspxvbe.inc
 (c)鯖/LP-Project. 1996
==============================================================================
#

VBEPK_NOERR	EQU	0
VBEPK_NOTFOUND	EQU	1
VBEPK_INVLD	EQU	2

tVbepack	STRUC
vbepk_vm	dw	?	; video mode
vbepk_scrnX	dw	?	; screen width
vbepk_scrnY	dw	?	; screen heght
vbepk_bpl	dw	?	; bytes per line
vbepk_selproc	dd	?	; window select proc

vbepk_wsize	dd	?	; ウィンドウサイズ（バイト単位）
vbepk_wndW	db	?	; 書き込みウィンドウの番号(0...A 1...B)
vbepk_wndR	db	?	; 読みだし
vbepk_wsegW	dw	?	; 書き込みウィンドウのセグメント
vbepk_wsegR	dw	?	; 読みだし
vbepk_wgsft	dw	?	; ウィンドウ分解能のシフトカウント
vbepk_wgdepth	dw	?	; ウインドウサイズ / ウインドウ分解能

tVbepack	ENDS


tDspm		STRUC
dspm_width	db	?
dspm_height	db	?
dspm_sbcs	dw	?
dspm_dbcs	dw	?
dspm_xor	dw	?
dspm_left	dw	?
dspm_right	dw	?
tDspm		ENDS


BITSEXP_BASE	EQU	0fh
Bitssize	EQU	4


bitsexp8b	MACRO	p1, p2
$b8b$0 = (p1 AND 1) * p2
$b8b$1 = ((p1 SHR 1) AND 1) * p2
$b8b$2 = ((p1 SHR 2) AND 1) * p2
$b8b$3 = ((p1 SHR 3) AND 1) * p2
$b8b$4 = ((p1 SHR 4) AND 1) * p2
$b8b$5 = ((p1 SHR 5) AND 1) * p2
$b8b$6 = ((p1 SHR 6) AND 1) * p2
$b8b$7 = ((p1 SHR 7) AND 1) * p2
		db	$b8b$7,$b8b$6,$b8b$5,$b8b$4,$b8b$3,$b8b$2,$b8b$1,$b8b$0
ENDM

bitsexp4b	MACRO	p1, p2
$b8b$0 = (p1 AND 1) * p2
$b8b$1 = ((p1 SHR 1) AND 1) * p2
$b8b$2 = ((p1 SHR 2) AND 1) * p2
$b8b$3 = ((p1 SHR 3) AND 1) * p2
		db	$b8b$3,$b8b$2,$b8b$1,$b8b$0
ENDM


_prmentry	MACRO
	pushad
	pushf
	push	ds
	push	es
	mov	bp,sp
	mov	di,cs
	mov	ds,di
	mov	es,di
	cld
ENDM

_prmexit	MACRO
	pop	es
	pop	ds
	popf
	popad
	retf
ENDM

$pushad$base 	EQU	6

reg_es		EQU	<word ptr ss:[bp]>
reg_ds		EQU	<word ptr ss:[bp+2]>
reg_flags	EQU	<word ptr ss:[bp+4]>
reg_edi		EQU	<dword ptr ss:[bp + $pushad$base ]>
reg_di		EQU	<word ptr ss:[bp + $pushad$base ]>
reg_esi		EQU	<dword ptr ss:[bp + $pushad$base + 4]>
reg_si		EQU	<word ptr ss:[bp + $pushad$base + 4]>
reg_ebp		EQU	<dword ptr ss:[bp + $pushad$base + 8]>
reg_bp		EQU	<word ptr ss:[bp + $pushad$base + 8]>
reg_esp		EQU	<dword ptr ss:[bp + $pushad$base + 12]>
reg_ebx		EQU	<dword ptr ss:[bp + $pushad$base + 16]>
reg_bx		EQU	<word ptr ss:[bp + $pushad$base + 16]>
reg_bl		EQU	<byte ptr ss:[bp + $pushad$base + 16]>
reg_bh		EQU	<byte ptr ss:[bp + $pushad$base + 16 + 1]>
reg_edx		EQU	<dword ptr ss:[bp + $pushad$base + 20]>
reg_dx		EQU	<word ptr ss:[bp + $pushad$base + 20]>
reg_dl		EQU	<byte ptr ss:[bp + $pushad$base + 20]>
reg_dh		EQU	<byte ptr ss:[bp + $pushad$base + 20 + 1]>
reg_ecx		EQU	<dword ptr ss:[bp + $pushad$base + 24]>
reg_cx		EQU	<word ptr ss:[bp + $pushad$base + 24]>
reg_cl		EQU	<byte ptr ss:[bp + $pushad$base + 24]>
reg_ch		EQU	<byte ptr ss:[bp + $pushad$base + 24 + 1]>
reg_eax		EQU	<dword ptr ss:[bp + $pushad$base + 28]>
reg_ax		EQU	<word ptr ss:[bp + $pushad$base + 28]>
reg_al		EQU	<byte ptr ss:[bp + $pushad$base + 28]>
reg_ah		EQU	<byte ptr ss:[bp + $pushad$base + 28 + 1]>
