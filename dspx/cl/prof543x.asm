COMMENT #
===============================================================================
 prof543x.asm
 (c)�I/LP-Project. 1996
===============================================================================
#

		.XLIST
		INCLUDE dspx.inc
		INCLUDE prof543x.inc
		.LIST

_TEXT		SEGMENT
	ASSUME	cs:_TEXT, ds:_TEXT
	ORG	0

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
	dw	VMS_COUNT		; �G���g���� 

VMS_TABLES	LABEL	NEAR
	db	1
	tVms <03h,00000001b, 80,25,12,30,12,24,1024, 768,12,24,00h,0>
	db	0
	tVms <03h,00000001b, 80,32,12,24,12,24,1024, 768,12,24,00h,0>
	db	0
	tVms <70h,00000001b, 53,20,12,24,12,24, 640, 480,12,24,00h,0>
	db	0
	tVms <70h,00000001b,106,40, 6,12, 6,12, 640, 480, 6,12,00h,0>
	db	0
	tVms <70h,00000001b, 91,34, 7,14, 6,12, 640, 480, 6,12,00h,0>
	db	0
	tVms <70h,00000001b, 66,25,12,24,12,24, 800, 600,12,24,00h,0>
	db	1
	tVms <70h,00000001b,100,33, 8,18, 8,16, 800, 600, 8,16,00h,0>
	db	0
	tVms <70h,00000001b,100,37, 8,16, 8,16, 800, 600, 8,16,00h,0>
	db	0
	tVms <70h,00000001b,133,50, 6,12, 6,12, 800, 600, 6,12,00h,0>
	db	0
	tVms <70h,00000001b,114,42, 7,14, 6,12, 800, 600, 6,12,00h,0>
	db	0
	tVms <70h,00000001b, 84,32,12,24,12,24,1024, 768,12,24,00h,0>
	db	0
	tVms <70h,00000001b,128,42, 8,18, 8,16,1024, 768, 8,16,00h,0>
	db	0
	tVms <70h,00000001b,128,48, 8,16, 8,16,1024, 768, 8,16,00h,0>
	db	0
	tVms <70h,00000001b,146,54, 7,14, 6,12,1024, 768, 6,12,00h,0>
	db	0
	tVms <70h,00000001b,170,64, 6,12, 6,12,1024, 768, 6,12,00h,0>
	db	0
	tVms <70h,00000000b,106,34,12,30,12,24,1280,1024,12,24,00h,0>
	db	0
	tVms <70h,00000000b,106,42,12,24,12,24,1280,1024,12,24,00h,0>
	db	0
	tVms <70h,00000000b,160,56, 8,18, 8,16,1280,1024, 8,16,00h,0>
	db	0
	tVms <70h,00000000b,160,64, 8,16, 8,16,1280,1024, 8,16,00h,0>
VMS_COUNT = ($ - VMS_TABLES) / (1 + SIZE tVms)

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
	dw	3			; �I�v�V�����̐� 
	db	'FC=ON/OFF',0
	db	'�S�p�t�H���g�L���b�V���̗L�����w�肵�܂��B',10
	db	'  ON  : �S�p�t�H���g�̈ꕔ���r�f�I�q�`�l��ɃL���b�V��'
	db	'���܂��B',10
	db	'      �i�r�f�I�q�`�l���Q�l�o�C�g�ȏ�K�v�ł��j',10
	db	'  OFF : �S�p�t�H���g�L���b�V�����s���܂���B',10
	db	'�I�v�V�������w�莞�� /FC=OFF �Ɠ����ɂȂ�܂��B'
	db	0
	db	'SFC=ON/HALF/OFF',0
	db	'���p�t�H���g�����C���������ɓǂݍ��ނ��ǂ����w�肵�܂��B',10
	db	'  ON  : ���p�t�H���g�̂��ׂĂ���������ɓǂݍ��݂܂��B',10
	db	'  HALF: �O�������P�Q�W������ǂݍ��݂܂��B',10
	db	'  OFF : ���C����������ɔ��p�t�H���g��ǂݍ��݂܂���B',10
	db	'�I�v�V�������w�莞�� /SFC=OFF �Ɠ����ɂȂ�܂��B',10
	db	0
	db	'MMIO=ON/OFF',0
	db	'�������}�b�v�h�h�^�n���g�p���邩�ǂ����w�肵�܂��B',10
	db	'  ON  : �������}�b�v�h�h�^�n���g�p���܂��B',10
	db	'        �iOS/2 ��ł͓��삵�܂���B�w�肵�Ȃ��ł��������j',10
	db	'  OFF : �g�p���܂���B',10
	db	'�I�v�V�������w�莞�� /MMIO=ON �Ɠ����ɂȂ�܂��B',10
	db	'�iOS/2 ��ł� /MMIO=OFF �Ɠ����j',10
	db	0
	
	db	0
	db	0
	
ENTRY_8		LABEL	NEAR
	dw	0

_TEXT		ENDS
		END
