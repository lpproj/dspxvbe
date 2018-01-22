COMMENT #
===============================================================================
 profvbe.asm --- dspxvbe.pro
 
===============================================================================
#

		INCLUDE ..\dspx.inc
		INCLUDE profvbe.inc


_TEXT		SEGMENT BYTE PUBLIC 'CODE'
	ASSUME	cs:_TEXT, ds:_TEXT
	ORG	0

Entry		LABEL	NEAR



ENTRY_1		LABEL	NEAR
	dw	ENTRY_2 - $
	db	'VideoCardInfo   '
	db	ID_CARDINFO


ENTRY_2		LABEL	NEAR
	dw	ENTRY_3 - $
	db	'DriverFileName  '
	db	NAME_DRIVER		; �h���C�o�t�@�C���� 


ENTRY_3		LABEL	NEAR
	dw	ENTRY_4 - $
	db	'VideoModeTable  '
	db	01, 20			; �o�[�W���� 
	dw	(vms_bottom - vms_entry) /17	; �G���g���� 
vms_entry:
	db	1
	tVms <03h,00000000b, 80,25,12,30,12,24,1024, 768,12,24,00h,0>
	;db	0
	;tVms <70h,00000000b, 66,25,12,24,12,24, 800, 600,12,24,00h,0>
	db	0
	tVms <70h,00000000b,100,37, 8,16, 8,16, 800, 600, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,100,33, 8,18, 8,16, 800, 600, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,100,30, 8,20, 8,16, 800, 600, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,128,48, 8,16, 8,16,1024, 768, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,128,42, 8,18, 8,16,1024, 768, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,128,38, 8,20, 8,16,1024, 768, 8,16,00h,0>
	db	1
	tVms <70h,00000000b, 84,32,12,24,12,24,1024, 768,12,24,00h,0>
	db	0
	tVms <70h,00000000b,144,54, 8,16, 8,16,1152, 864, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,144,48, 8,18, 8,16,1152, 864, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,144,43, 8,20, 8,16,1152, 864, 8,16,00h,0>
	db	0
	tVms <70h,00000000b, 96,36,12,24,12,24,1152, 864,12,24,00h,0>
	db	0
	tVms <70h,00000000b, 96,28,12,30,12,24,1152, 864,12,24,00h,0>
	db	0
	tVms <70h,00000000b,160,64, 8,16, 8,16,1280,1024, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,160,56, 8,18, 8,16,1280,1024, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,160,51, 8,20, 8,16,1280,1024, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,106,42,12,24,12,24,1280,1024,12,24,00h,0>
	db	0
	tVms <70h,00000000b,106,34,12,30,12,24,1280,1024,12,24,00h,0>
	db	0
	tVms <70h,00000000b,200,75, 8,16, 8,16,1600,1200, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,200,66, 8,18, 8,16,1600,1200, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,200,60, 8,20, 8,16,1600,1200, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,132,50,12,24,12,24,1600,1200,12,24,00h,0>
	db	0
	tVms <70h,00000000b,132,40,12,30,12,24,1600,1200,12,24,00h,0>
vms_bottom:

ENTRY_4		LABEL	NEAR
	dw	ENTRY_5 - $
	db	'DSPXInfo        '
	dw	0000000000000000b


ENTRY_5		LABEL	NEAR
	dw	ENTRY_6 - $
	db	'DBCSVideoMode   '
	db	03h,0, 80,25


ENTRY_6		LABEL	NEAR
	dw	ENTRY_7 - $
	db	'SBCSVideoMode   '
	db	03h,0, 80,25


ENTRY_7		LABEL	NEAR
	dw	ENTRY_8 - $
	db	'OptionTable     '
	dw	2			; �I�v�V�����̐� 
	
	db	'HS=OFF/ON',0
	db	'��ʃX�N���[���̕��@���w�肵�܂�',10
	db	'  OFF : �n�[�h�E�F�A�X�N���[�����s���܂���',10
	db	'  ON  : �n�[�h�E�F�A�X�N���[�����s���܂�'
	db	'�i�^���悯��Γ��삵�܂��j',10
	db	'�I�v�V�������w�莞�� /HS=OFF �Ɠ����ɂȂ�܂��B',10
	db	0
	
	db	'SFC=OFF/HALF/ON',0
	db	'���p�t�H���g�����C���������ɓǂݍ��ނ��ǂ����w�肵�܂��B',10
	db	'  OFF : ���C����������ɔ��p�t�H���g��ǂݍ��݂܂���B',10
	db	'  HALF: �O�������P�Q�W������ǂݍ��݂܂��B',10
	db	'  ON  : ���p�t�H���g�̂��ׂĂ���������ɓǂݍ��݂܂��B',10
	db	'�I�v�V�������w�莞�� /SFC=HALF �Ɠ����ɂȂ�܂��B',10
	db	0
	
	db	0
	db	0

ENTRY_8		LABEL	NEAR
	dw	0

_TEXT		ENDS
		END	Entry

