COMMENT #
===============================================================================
 cl3xhw.inc

 Init_acc	�A�N�Z�����[�^�֌W������
 ds:di tBltini �̃|�C���^

 Init_csr	�J�[�\���֌W������
 dx,ax,si �͔j�󂳂��

 TfrMem2Scrn	����������ʂ�BitBlt�i���m�N�����J���[�g���j
 ds:di	tBlt �ւ̃|�C���^
 eax,cx,si,di,es �͔j�󂳂��B

 TfrScrn2Scrn	��ʁ���ʂ�BitBlt
 ds:di	tBlt �ւ̃|�C���^
 es = ds �ɐݒ肵�Ă������ƁB
 eax,cx,si,di �͔j�󂳂��B

 TfrScrn2ScrnX	��ʁ���ʂ�BitBlt�i���m�N�����J���[�g���j
 ds:di	tBlt �ւ̃|�C���^
 es = ds �ɐݒ肵�Ă������ƁB
 eax,cx,si,di �͔j�󂳂��B

 BltFillRect	���F�ł̋�`�h��ׂ�
 ds:di	tBlt �ւ̃|�C���^
 es = ds �ɐݒ肵�Ă������ƁB
 eax,cx,si,di �͔j�󂳂��B

 InvertRect	��`�F���]
 ds:di	tBlt �ւ̃|�C���^
 es = ds �ɐݒ肵�Ă������ƁB
 eax,cx,si,di �͔j�󂳂��B

 MoveToScrn	���C������������C�ӃI�t�Z�b�g�̃r�f�I�������ɓ]��
 ds:si �������̃A�h���X
 ebx   �r�f�I�������̃I�t�Z�b�g
 cx    �]���o�C�g��

 MoveFromScrn	�r�f�I���������烁�C���������ɓ]��
 ebx   �r�f�I�������̃I�t�Z�b�g
 es:di �������̃A�h���X
 cx    �]���o�C�g��
 
 SetWindowOffset �E�B���h�E�I�t�Z�b�g���W�X�^�̐ݒ�
 ebx   �r�f�I�������̃I�t�Z�b�g
 [result]
  di ... ���ۂ̃�������ł̃I�t�Z�b�g
  ���Ƃ� S-VGA �̃I�t�Z�b�g���W�X�^�ɃI�t�Z�b�g���������܂��
 �i��̂R�̓t�H���g�L���b�V���f�[�^�A�J�[�\���p�^�[���]���p�j

 SetHWCsrPos	�n�[�h�E�F�A�J�[�\���̈ʒu�����߂�
 ax	X
 dx	Y
 ax,dx,bx �͔j�󂳂��B

 SetHWCsrPtn	�n�[�h�E�F�A�J�[�\���p�^�[����ݒ肷��
 ds:si	tCsrSize �̃|�C���^
 csiz_width �� csiz_height ���O�̎��̓J�[�\���͕\�����Ȃ��悤�ɂ���B
 �i�����J�[�\���ɐݒ肷��j

 


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
clb_src		dd	?	; �ŏ�ʃo�C�g�� Blt destination write mask
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
