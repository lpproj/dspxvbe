COMMENT #
=============================================================================
 dspxentr.inc
=============================================================================
#

		IFDEF DSPX_ENTR_32

;---------------------------------------
; 32 bit entr
;---------------------------------------

_prmentry	MACRO
	pushad
	pushfd
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
	popfd
	popad
	retf
ENDM

$pushad$base 	EQU	8

reg_es		EQU	<word ptr ss:[bp]>
reg_ds		EQU	<word ptr ss:[bp+2]>
reg_flags	EQU	<word ptr ss:[bp+4]>
reg_eflags	EQU	<dword ptr ss:[bp+4]>
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


		ELSE

;---------------------------------------
; 16 bit entr
;---------------------------------------

org_es		equ	<word ptr [bp]>
org_ds		equ	<word ptr [bp+2]>
org_di		equ	<word ptr [bp+4]>
org_si		equ	<word ptr [bp+6]>
org_bp		equ	<word ptr [bp+8]>
org_sp		equ	<word ptr [bp+10]>
org_bx		equ	<word ptr [bp+12]>
org_bl		equ	<byte ptr [bp+12]>
org_bh		equ	<byte ptr [bp+13]>
org_dx		equ	<word ptr [bp+14]>
org_dl		equ	<byte ptr [bp+14]>
org_dh		equ	<byte ptr [bp+15]>
org_cx		equ	<word ptr [bp+16]>
org_cl		equ	<byte ptr [bp+16]>
org_ch		equ	<byte ptr [bp+17]>
org_ax		equ	<word ptr [bp+18]>
org_al		equ	<byte ptr [bp+18]>
org_ah		equ	<byte ptr [bp+19]>
org_flags	equ	<word ptr [bp+20]>

_prmentry	MACRO
	pushf
	pusha
	cld
	push	ds
	push	es
	mov	si,cs
	mov	ds,si
	mov	es,si
	mov	bp,sp
ENDM


_prmexit	MACRO
	pop	es
	pop	ds
	popa
	popf
	retf
ENDM

		ENDIF

