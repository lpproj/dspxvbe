COMMENT #
-------------------------------------------------------------------------------
 vbeaxes.inc
-------------------------------------------------------------------------------
#



tVbeinfo	STRUC
vbei_vm		dw	-1
vbei_xreso	dw	?	; 水平解像度
vbei_yreso	dw	?	; 垂直
vbei_wndW	dw	?	; Write Window の番号
vbei_wndR	dw	?	; Read Window
vbei_segW	dw	?	; Write Window の開始セグメント
vbei_segR	dw	?	; Read 
vbei_wndsize	dd	?	; Window のサイズ
vbei_func	dd	?	; Window切り替えファンクションエントリ
vbei_gra	dd	?	; 切り替え分解能（バイト単位）
vbei_wndpergra	dw	?	; wndsize / gra
vbei_pages	dw	?
tVbeinfo	ENDS

vbei_wndRW	EQU	vbei_wndW
vbei_segRW	EQU	vbei_segW


	IFDEF	$DSPX$VBEACCESS
	
	ELSE
	
	ENDIF

