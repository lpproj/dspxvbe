COMMENT #
===============================================================================
 bitblt.inc

===============================================================================
#

tBlt		STRUC
blt_src		dd	?
blt_dest	dd	?
blt_width	dw	?
blt_height	dw	?
blt_fg		db	?
blt_bg		db	?
blt_bytes	dw	?
tBlt		ENDS

tBltini		STRUC
bltini_width	dw	?
bltini_height	dw	?
bltini_pixels	dw	?
bltini_planes	dw	?
tBltini		ENDS


tCsrSize	STRUC
csiz_left	db	?	; ��ʏ�̉��̐擪�I�t�Z�b�g
csiz_width	db	?	; ��ʏ�̉����i�O�̎��͕\�����Ȃ��j
csiz_top	db	?	; ��ʏ�̏c�̐擪�I�t�Z�b�g
csiz_height	db	?	; ��ʏ�̍����i�O�̎��͕\�����Ȃ��j
tCsrSize	ENDS
