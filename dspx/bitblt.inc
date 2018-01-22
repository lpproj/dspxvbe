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
csiz_left	db	?	; 画面上の横の先頭オフセット
csiz_width	db	?	; 画面上の横幅（０の時は表示しない）
csiz_top	db	?	; 画面上の縦の先頭オフセット
csiz_height	db	?	; 画面上の高さ（０の時は表示しない）
tCsrSize	ENDS

