COMMENT #
-------------------------------------------------------------------------------
 vbeaxes.inc
-------------------------------------------------------------------------------
#



tVbeinfo	STRUC
vbei_vm		dw	-1
vbei_xreso	dw	?	; �����𑜓x
vbei_yreso	dw	?	; ����
vbei_wndW	dw	?	; Write Window �̔ԍ�
vbei_wndR	dw	?	; Read Window
vbei_segW	dw	?	; Write Window �̊J�n�Z�O�����g
vbei_segR	dw	?	; Read 
vbei_wndsize	dd	?	; Window �̃T�C�Y
vbei_func	dd	?	; Window�؂�ւ��t�@���N�V�����G���g��
vbei_gra	dd	?	; �؂�ւ�����\�i�o�C�g�P�ʁj
vbei_wndpergra	dw	?	; wndsize / gra
vbei_pages	dw	?
tVbeinfo	ENDS

vbei_wndRW	EQU	vbei_wndW
vbei_segRW	EQU	vbei_segW


	IFDEF	$DSPX$VBEACCESS
	
	ELSE
	
	ENDIF
