COMMENT #
===============================================================================
 dspxdumy.asm
 
 (c)鯖/LP-Project. 1995-96
===============================================================================
#

		INCLUDE mydef.inc
		INCLUDE dspx.inc
		INCLUDE dspxseg.inc
		
		INCLUDE dspxcmn.ah
		INCLUDE dspxldr.inc
		
		INCLUDE profdumy.inc


L_DATA		SEGMENT
DrvExttable	LABEL	tVms
		tVms <70h,00000000b, 80,30, 8,16, 8,16, 640, 480, 8,16,00h,0>
L_DATA		ENDS
G_DATA		SEGMENT

mypspseg	dw	?

Drv_Drvinfo	LABEL	tDspxDrv
		db	1,0
		dw	ofs DrvPrimitive
		dw	ofs DrvExttable
		dw	1
		dw	ofs DrvName
		dw	ofs DrvMyapi

DrvPrimitive	LABEL	WORD
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob
		dw	NullJob

DrvName		db	'Dummy Driver (c)鯖',0

	ALIGN	4

VectTbls	LABEL	tLPVect
Vect_10		tLPVect <10h, 1, ofs New10, ?>
VectCnt = ($ - VectTbls) / (SIZE tLPVect)

G_DATA		ENDS

TSR_TEXT	SEGMENT

New10		PROC	FAR
	jmp	cs:[Vect_10.lpvect_old]
New10		ENDP


NullJob		PROC	FAR
	ret
NullJob		ENDP

DrvMyapi	PROC	FAR
	cmp	ah,LPDRV_GETVER
	jne	@@2
	mov	bx,0100h
	jmps	@@noerr
@@2:
	cmp	ah,LPDRV_SETSEG
	jne	@@3
	mov	cs:[mypspseg],es
	jmps	@@noerr
@@3:
	cmp	ah,LPDRV_GETSEG
	jne	@@4
	mov	es,cs:[mypspseg]
	jmps	@@noerr
@@4:
	cmp	ah,LPDRV_GETVECTINFO
	jne	@@5
	movseg	es,cs
	mov	di,ofs VectTbls
	mov	cx,VectCnt
	jmps	@@noerr
@@5:
@@err:
	mov	ah,-1
	stc
	ret
@@noerr:
	xor	ah,ah
	clc
	ret
DrvMyapi	ENDP

TSR_TEXT	ENDS


_DATA		SEGMENT
sCardID		db	ID_CARDINFO
msgOpening	db	'DSPXDUMY version 0.00 (c)鯖/LP-Project. 1996, 2018',CR,LF,0
msgHelp		db	'IBM DOS/V Extension 用のダミー V-Text ドライバです。'
		db	CR,LF,CR,LF
		db	'DSPXDUMY [/NOUMB] [/R]',CR,LF
		db	CR,LF
		db	'  /NOUMB',HT,'UMB への自動ロードを禁止します',CR,LF
		db	'  /R',HT,HT,'DSPXDUMY をメモリから削除します',CR,LF
		db	0
_DATA		ENDS
_TEXT		SEGMENT

Drv_Getparam	PROC	NEAR
	mov	al,0
	mov	ah,0
	ret
Drv_Getparam	ENDP


Drv_Checkvideo	PROC	NEAR
	mov	al,0
	ret
Drv_Checkvideo	ENDP

Drv_Checkvideoerr	PROC	NEAR
	ret
Drv_Checkvideoerr	ENDP

Drv_Checkprof	PROC	NEAR
	pushm	<si>
	mov	si,ofs sCardID
	call	MemCmp
	je	@@noerr
@@err:
	mov	ax,1
	jmps	@@exit
@@noerr:
	mov	ax,0
@@exit:
	popm	<si>
	ret
Drv_Checkprof	ENDP

Drv_Checkvms	PROC	NEAR
	mov	ax,1
	test	byte ptr [si + (tVms.vms_info)],80h
	je	@@exit
	mov	al,0
@@exit:
	ret
Drv_Checkvms	ENDP

Drv_Preloadjob	PROC	NEAR
	ret
Drv_Preloadjob	ENDP

Drv_Opening	PROC	NEAR
	mov	dx,ofs msgOpening
	call	PutMsg
	ret
Drv_Opening	ENDP

Drv_Displayhelp	PROC	NEAR
	mov	dx,ofs msgHelp
	call	PutMsg
	ret
Drv_Displayhelp	ENDP

Drv_Paramerr	PROC	NEAR
	ret
Drv_Paramerr	ENDP

Drv_Checkvmserr	PROC	NEAR
	ret
Drv_Checkvmserr	ENDP

Drv_Getbottom	PROC	NEAR
	mov	bx,ofs BottomOfTsr
	ret
Drv_Getbottom	ENDP

_TEXT		ENDS


_DATA		SEGMENT
Buf_Entry	dw	0
Buf_Size	dw	0
_DATA		ENDS

		END
