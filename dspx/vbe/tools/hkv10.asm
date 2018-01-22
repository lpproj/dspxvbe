COMMENT #
=============================================================================
hkv10.asm : hkv10.com source
version 0.02

 Int 10h ベクタを一時的にぶんどるドライバ／プログラム

=============================================================================
#

CR		EQU	13
LF		EQU	10
eos		EQU	'$'

jmps		MACRO	p1
	jmp	short p1
ENDM

pushm		MACRO	p1
	IRP	p2,<p1>
		push	p2
	ENDM
ENDM

popm		MACRO	p1
	IRP	p2,<p1>
		pop	p2
	ENDM
ENDM


APIMAJOR	EQU	0
APIMINOR	EQU	00h
APIGETVER	EQU	0
APIGETWORK	EQU	1
APIGETORGVECT	EQU	2
APISETORGVECT	EQU	3

tvect		STRUC
flag_onoff	db	?
prev_vm		db	?
prev_vect	dd	?
tvect		ENDS


_TEXT		SEGMENT BYTE PUBLIC
_TEXT		ENDS
STACK		SEGMENT PARA STACK
STACK		ENDS


_TEXT		SEGMENT	BYTE
	ASSUME	cs:_TEXT,ds:_TEXT

	ORG	0

Top:
		dd	-1
		dw	8000h
		dw	Strategy
		dw	Init_Commands
hkv_id		db	'$$HKV10$'
		db	'HKLPPROJ'
hkv_id_len	=	($ - hkv_id)
Api		dd	?
		dw	?
ApiWorkArea	db	16 dup (0)
ApiWork_len	=	($ - ApiWorkArea)

New10h		PROC	FAR
		db	0eah		; jmp xxxx:yyyy
Org10h		dd	?
New10h		ENDP

reqhdr		dd	?

Strategy	PROC	FAR
	mov	word ptr cs:[reqhdr],bx
	mov	word ptr cs:[reqhdr+2],es
	ret
Strategy	ENDP

Commands	PROC	FAR
	pushm	<bx,ds>
	lds	bx,cs:[reqhdr]
	mov	word ptr [bx+3],8103h		; なんにでもエラーを返す 
	popm	<ds,bx>
	ret
Commands	ENDP


ApiProc		PROC	FAR
	cmp	ax,APIGETVER
	je	api_getver
	cmp	ax,APIGETWORK
	je	api_getwork
	cmp	ax,APIGETORGVECT
	je	api_getvect
	cmp	ax,APISETORGVECT
	je	api_setvect
api_err:
	mov	ax,-1
	stc
	ret
api_getver:
	mov	bx,(APIMAJOR * 256) + APIMINOR
api_noerr:
	mov	ax,0
	clc
	ret
api_getwork:
	push	cs
	pop	es
	mov	bx,offset ApiWorkArea
	mov	cx,ApiWork_len
	jmps	api_noerr
api_getvect:
	les	bx,cs:[Org10h]
	jmps	api_noerr
api_setvect:
	mov	word ptr cs:[Org10h],bx
	mov	word ptr cs:[Org10h+2],es
	jmps	api_noerr
ApiProc		ENDP


Dev_Bottom	LABEL	NEAR
;---------------常駐はここまで------------------------------------------------


Pmsg		PROC	NEAR
	push	ax
	mov	ah,9
	int	21h
	pop	ax
	ret
Pmsg		ENDP


Init_Commands	PROC	FAR
	pushf
	pushm	<ax,bx,dx,ds,es>
	cld
	mov	ax,cs
	mov	ds,ax
	mov	word ptr ds:[0],-1	; デバイスチェインを自前で初期化 
	mov	word ptr ds:[2],-1
	mov	word ptr [Api],offset ApiProc
	mov	word ptr [Api+2],cs
	mov	dx,offset msgOpening
	call	Pmsg
	call	GetApi
	cmp	ax,0
	jne	init_c_already
	mov	ax,3510h
	int	21h
	mov	word ptr [Org10h],bx
	mov	word ptr [Org10h+2],es
	mov	ax,2510h
	mov	dx,offset New10h
	int	21h
	lds	bx,[reqhdr]
	mov	byte ptr [bx+13],1
	mov	word ptr [bx+14],offset Dev_Bottom
	mov	word ptr [bx+16],cs
	mov	word ptr cs:[0008h],offset Commands
	mov	word ptr [bx+3],0100h
	jmps	init_c_exit
init_c_already:
	mov	dx,offset errAlready
	call	Pmsg
	lds	bx,[reqhdr]
	mov	word ptr [bx+3],0100h
	mov	byte ptr [bx+13],0
	mov	word ptr [bx+14],0
	mov	word ptr [bx+16],cs
	mov	word ptr cs:[0004h],0	; ブロックデバイスにしとく 
					; （でないと日電DOS2.11、3.1で
					; 開放できないらしい。 ああ不便。
					; どうやら東芝DOS3.1もらしい。） 
init_c_exit:
	popm	<es,ds,dx,bx,ax>
	popf
	ret
Init_Commands	ENDP


GetApi		PROC	NEAR
	pushm	<cx,si,di>
	mov	ah,52h
	int	21h			; get SYSVARS pointer to es:bx
	add	bx,22h			; Top of Device chain (NUL) DOS3+
getapi_lp:
	test	word ptr es:[bx + 4],8000h	; Character device?
	jz	getapi_next
	mov	si,offset hkv_id
	lea	di,[bx + si]
	mov	cx,hkv_id_len
	repe	cmpsb
	jne	getapi_next
	mov	ax,1
	les	bx,dword ptr es:[bx + Api]
	jmps	getapi_exit
getapi_next:
	les	bx,dword ptr es:[bx]	; next device hdr
	cmp	bx,-1
	jne	getapi_lp		; （つまり bx=ffff なら次はないワケ）
	mov	ax,0
getapi_exit:
	popm	<di,si,cx>
	ret
GetApi		ENDP



COMMENT #
-----------------------------------------------------------------------------
 コマンドライン実行時の処理
-----------------------------------------------------------------------------
#

ApiPtr		dd	?
CallPtr		dw	?

COMMENT #
-----------------------------------------------------------------------------
 ON の時...現在の int 10h ベクタとビデオモードを作業域に保存
           内部の OrgVect を現在の int 10h ベクタにする。
           ビデオモードを３にする。

 OFFの時...int10h ベクタが変更されている場合は、変更されたベクタを
           内部の OrgVect に転送して、作業域に保存したベクタを復元。
           変更されていない場合は、単に作業域のベクタを戻す。
           ビデオモードの復元。（ただ３にしてるだけだけど）
-----------------------------------------------------------------------------
#

VectOn		PROC	NEAR
	pushm	<bx,es>
	mov	ax,APIGETWORK
	call	dword ptr [ApiPtr]
	cmp	es:[bx + (tvect.flag_onoff)],0
	jne	vecton_exit
	mov	es:[bx + (tvect.flag_onoff)],1
	pushm	<bx,es>
	mov	ax,3510h
	int	21h
	mov	ax,bx
	mov	dx,es
	popm	<es,bx>
	mov	word ptr es:[bx + (tvect.prev_vect)],ax
	mov	word ptr es:[bx + (tvect.prev_vect +2)],dx
	pushm	<bx,ds,es>
	mov	ax,APIGETORGVECT
	call	dword ptr [ApiPtr]
	push	es
	pop	ds
	mov	dx,bx
	mov	ax,2510h
	int	21h
	popm	<es,ds,bx>
	mov	ax,3
	push	bp
	int	10h
	pop	bp
vecton_exit:
	popm	<es,bx>
	ret
VectOn		ENDP

VectOff		PROC	NEAR
	pushm	<bx,ds,es>
	mov	ax,APIGETWORK
	call	dword ptr [ApiPtr]
	cmp	es:[bx + (tvect.flag_onoff)],0
	je	vectoff_exit
	mov	es:[bx + (tvect.flag_onoff)],0
	mov	dx,word ptr es:[bx + (tvect.prev_vect)]
	mov	cx,word ptr es:[bx + (tvect.prev_vect+2)]
	pushm	<bx,ds,es>
	mov	ax,3510h
	int	21h
	cmp	dx,bx
	jne	vectoff_modified
	mov	ax,es
	cmp	ax,cx
	jne	vectoff_modified
	mov	ds,cx
	mov	ax,2510h
	int	21h
	jmps	vectoff_2
vectoff_modified:
	mov	ds,cx
	mov	ax,2510h
	int	21h
	mov	ax,APISETORGVECT
	call	cs:[ApiPtr]
	popm	<es,ds,bx>
vectoff_2:
	mov	ax,3
	push	bp
	int	10h
	pop	bp
vectoff_exit:
	popm	<es,ds,bx>
	ret
VectOff		ENDP


Exe_Main	PROC	NEAR
	mov	ax,cs
	mov	ds,ax
	cld
	mov	ah,62h
	int	21h
	mov	es,bx
	mov	di,0081h
m_prm_lp:
	mov	ax,word ptr es:[di]
	inc	di
	cmp	al,' '
	je	m_prm_lp
	cmp	al,9			; HTAB
	je	m_prm_lp
	cmp	al,0
	je	m_prm_lp
	cmp	al,CR
	je	m_prm_noprm
	or	ax,2020h		; 小文字化 
	mov	dx,offset VectOn
	cmp	ax,'no'			; 'on'?
	je	m_prm_onoff
	mov	dx,offset VectOff
	cmp	ax,'fo'			; 'of'f ?
	je	m_prm_onoff
m_prm_noprm:
	mov	dx,offset msgOpening
	call	Pmsg
	mov	dx,offset msgHelp
	call	Pmsg
	mov	al,1
	jmps	m_prm_exit
m_prm_onoff:
	mov	[CallPtr],dx
	call	GetApi
	cmp	ax,0
	jne	m_prm_callapi
	mov	dx,offset errNotExist
	call	Pmsg
	mov	al,2
	jmps	m_prm_exit
	ret
m_prm_callapi:
	mov	word ptr [ApiPtr],bx
	mov	word ptr [ApiPtr+2],es
	call	[CallPtr]
	mov	al,0
m_prm_exit:
	mov	ah,4ch
	int	21h
Exe_Main	ENDP


msgOpening	db	'HKV10  (c)sava/LP-Project. 1995-96',CR,LF,eos
msgHelp		db	'[用法] HKV10 [on | off]',CR,LF
		db	'on  ... Int 10h ベクタの値を一時的に変更します',CR,LF
		db	'off ... Int 10h ベクタの値を元に戻します',CR,LF
		db	eos
errAlready	db	'ERR : HKV10 already installed.',CR,LF,eos
errNotExist	db	'ERR : HKV10 DEVICE DRIVER not exist.',CR,LF,eos
_TEXT		ENDS

STACK		SEGMENT
	dw	128 dup (?)
STACK		ENDS


	END	Exe_Main

