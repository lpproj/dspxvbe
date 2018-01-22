COMMENT #
===============================================================================
 vesa.inc
===============================================================================
#

tVesainf	STRUC
vesai_id	db	4 dup (?)	; VESA ID "VESA"
vesai_ver	dw	?	; Major , Minor (0102h as 1.2)
vesai_oemname	dd	?	; ptr to OEM name
vesai_capa	dd	?	; Capabilities
vesai_vm	dd	?	; ptr to video modes
vesai_total	dw	?	; VRAM amount (by 64k-bytes)
vesai_oemver	dw	?	; OEM version (VBE 2.0)
vesai_vendor	dd	?	; ptr to vendor name (VBE 2.0)
vesai_product	dd	?	; ptr to product name (VBE 2.0)
vesai_revision	dd	?	; ptr to revision str (VBE 2.0)

;(vesai_reserved	db	222 dup (?) )
;(vesai_oem_scratch	db	256 dup (?) )	; VBE 2.0
tVesainf	ENDS


tVesam		STRUC
vesam_attr	dw	?	; モード情報 
vesam_attrA	db	?	; ウインドウＡ属性
vesam_attrB	db	?	; ウインドウＢ属性
vesam_gra	dw	?	; ウインドウ分解能（KB単位）
vesam_size	dw	?	; ウインドウサイズ（KB単位）
vesam_segA	dw	?	; ウインドウＡセグメント
vesam_segB	dw	?	; ウインドウＢセグメント
vesam_cntl	dd	?	; ウインドウ設定関数へのポインタ
vesam_bytes	dw	?	; １行のバイト数
				; ここから先は VESA OEM Mode でのサポート 
				; 
vesam_columns	dw	?	; 横のドット（文字）数
vesam_rows	dw	?	; 縦のドット（文字）数
vesam_width	db	?	; キャラクタ１文字の幅（ドット単位）
vesam_height	db	?	; キャラクタ１文字の高さ（ドット単位）
vesam_planes	db	?	; メモリープレーンの数
vesam_bitspixel	db	?	; １ドット表現に必要なビット数（色数）
vesam_banks	db	?	; バンク数
vesam_mtype	db	?	; メモリーモデルタイプ
vesam_banksize	db	?	; バンクサイズ
vesam_pages	db	?	; イメージページ数
vesam_reserved	db	?
				; ここから先は VBE 1.2 以上
vesam_masksizeR	db	?	; マスクサイズ（赤）
vesam_fposR	db	?	; ビット位置（赤）
vesam_masksizeG	db	?	; （緑）
vesam_fposG	db	?	;
vesam_masksizeB	db	?	; （青）
vesam_fposB	db	?	;
vesam_masksize_	db	?	; （予約）
vesam_fpos_	db	?	;
vesam_dcolor	db	?	; ダイレクトカラー情報
				; ここから先は VBE 2.0 以上
vesam_padd	dd	?	; ビデオバッファの物理アドレス
vesam_startoff	dd	?	
vesam_sizeoff	dd	?
tVesam		ENDS

