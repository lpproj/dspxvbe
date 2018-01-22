COMMENT #
===============================================================================
 profdumy.asm --- dspxdumy.pro
 
===============================================================================
#

		INCLUDE dspx.inc
		INCLUDE profdumy.inc


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
	db	NAME_DRIVER		; ドライバファイル名 


ENTRY_3		LABEL	NEAR
	dw	ENTRY_4 - $
	db	'VideoModeTable  '
	db	01, 20			; バージョン 
	dw	1			; エントリ数 

	db	0
	tVms	<70h,00000000b,80,30,8,16,8,16,640,480,8,16,00h>


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
	dw	0			; オプションの数 
	db	0
	db	0

ENTRY_8		LABEL	NEAR
;	dw	ENTRY_9 - $
;	db	'1234567890123456'
;	db	30000 dup ('F')

ENTRY_9		LABEL	NEAR
	dw	0

_TEXT		ENDS
		END	Entry

