COMMENT #
===============================================================================
 dspxcmn.asm
 
 (c)鯖/LP-Project. 1996


 ここにあるすべてのルーチンは、基本的に DF=0 であることを前提としている。
 不安な場合はあらかじめ cld を実行しておきましょう。

===============================================================================
#

		INCLUDE	mydef.inc
		INCLUDE	dspx.inc
		INCLUDE	dspxseg.inc

		.286

		PUBLIC	PutMsg, PutChar, Put_n, PutHex8, PutHex16
		;PUBLIC	Dbcs_Init
		PUBLIC	IsEnvSbcs
		PUBLIC	StrCpy, StrCat, StrUpper, StrCmp
		PUBLIC	MemCmp
		PUBLIC	GetHex
		PUBLIC	SearchPathLen
		
		;PUBLIC	Dosver_Init
		PUBLIC	Cpu_type, bCpu186, bCpu286, bCpu386, bCpu486
		PUBLIC	Dos_ver, Dosver_major, Dosver_minor
		PUBLIC	Dos_truever, Truever_major, Truever_minor
		PUBLIC	Os2mvdm_ver, Os2mvdm_major, Os2mvdm_minor
		PUBLIC	Windows_ver, Winver_major, Winver_minor, Windows_mode
		PUBLIC	bDos5, bOs2dos, bOs2v2
		
		PUBLIC	Dspxcmn_Init
		


_TEXT		SEGMENT


Dspxcmn_Init	PROC	NEAR
	call	Dosver_Init
	call	Dbcs_Init
	call	CheckCpuType
	ret
Dspxcmn_Init	ENDP

COMMENT #
-------------------------------------------------------------------------------
 表示関係 
-------------------------------------------------------------------------------
#

PutHandle	PROC	NEAR
	pushm	<ax,cx,di,es>
	mov	ax,ds
	mov	es,ax
	mov	di,dx
	mov	cx,-1
	mov	al,0
	repne	scasb
	not	cx
	dec	cx
	mov	ah,40h
	int	21h
	popm	<es,di,cx,ax>
	ret
PutHandle	ENDP


PutHandle_n	PROC	NEAR
	pushm	<ax,cx,dx,ds>
	mov	ax,ss
	mov	ds,ax
	mov	ax,(LF * 256) + CR
	push	ax
	mov	dx,sp
	mov	cx,2
	mov	ah,40h
	int	21h
	pop	ax
	popm	<ds,dx,cx,ax>
	ret
PutHandle_n	ENDP


PutMsg		PROC	NEAR
	push	bx
	mov	bx,HANDLE_STDOUT
	call	PutHandle
	pop	bx
	ret
PutMsg		ENDP

PutChar		PROC	NEAR
	pushm	<ax,dx,ds>
	mov	ah,0
	push	ax
	movseg	ds,ss
	mov	dx,sp
	call	PutMsg
	pop	ax		; スタックの内容を捨ててるだけ 
	popm	<ds,dx,ax>
	ret
PutChar		ENDP

Put_n		PROC	NEAR
	push	bx
	mov	bx,HANDLE_STDOUT
	call	PutHandle_n
	pop	bx
	ret
Put_n		ENDP


PutHex8		PROC	NEAR
	pushm	<dx,di,bp,ds,es>
	sub	sp,4
	mov	di,sp
	mov	dx,ss
	mov	ds,dx
	mov	es,dx
	mov	dx,di
	call	StrHex8
	call	PutMsg
	add	sp,4
	popm	<es,ds,bp,di,dx>
	ret
PutHex8		ENDP

PutHex16	PROC	NEAR
	pushm	<dx,di,bp,ds,es>
	sub	sp,6
	mov	di,sp
	mov	dx,ss
	mov	ds,dx
	mov	es,dx
	mov	dx,di
	call	StrHex16
	call	PutMsg
	add	sp,6
	popm	<es,ds,bp,di,dx>
	ret
PutHex16	ENDP



COMMENT #
-------------------------------------------------------------------------------
 文字（列）処理群
 必ず、あらかじめ Dbcs_Init を実行しておくこと

 ストリングのソースは基本的に ds:si で、デスティネーションは es:di 。

-------------------------------------------------------------------------------
#

_DATA		SEGMENT
		dw	6
Dbcs_Dummy	db	081h, 090h, 0e0h, 0fch
		db	0,0

bufi		db	15 dup (0)
bufi_btm	db	0
_DATA		ENDS

DbcsVect	dd	?

Dbcs_Init	PROC	NEAR
	pushm	<ax,si,ds,es>
	mov	si,ofs Dbcs_Dummy
	mov	word ptr cs:[dbcs_init_stk],sp
	mov	word ptr cs:[dbcs_init_stk+2],ss
	mov	ax,6300h
	int	21h
	mov	ss,word ptr cs:[dbcs_init_stk+2]
	mov	sp,word ptr cs:[dbcs_init_stk]
	mov	word ptr cs:[DbcsVect],si
	mov	word ptr cs:[DbcsVect+2],ds
	popm	<es,ds,si,ax>
	ret
	;
dbcs_init_stk	dd	?
Dbcs_Init	ENDP


IsEnvSbcs	PROC	NEAR
	pushm	<bx,ds>
	lds	bx,cs:[DbcsVect]
	cmp	word ptr [bx],0
	popm	<ds,bx>
	ret
IsEnvSbcs	ENDP

IsDbcsLead	PROC	NEAR
	pushm	<ax,bx,si,ds>
	lds	si,cs:[DbcsVect]
	mov	bl,al
is_dbcs_lead_lp:
	lodsw
	or	ax,ax
	jz	is_dbcs_lead_no
	cmp	bl,al
	jb	is_dbcs_lead_no
	cmp	bl,ah
	ja	is_dbcs_lead_lp
	xor	ax,ax			; if dbcs_lead , set zero flag
	jmps	is_dbcs_lead_exit
is_dbcs_lead_no:
	mov	al,1
	or	ax,ax			; if not dbcs_lead, clear zero flag
is_dbcs_lead_exit:
	popm	<ds,si,bx,ax>
	ret
IsDbcsLead	ENDP


StrUpper	PROC	NEAR
	pushm	<ax,di>
str_upr_lp:
	mov	al,byte ptr es:[di]
	cmp	al,0
	je	str_upr_exit
	cmp	al,'a'
	jb	str_upr_2
	cmp	al,'z'
	ja	str_upr_2
	sub	al,'a' - 'A'
	mov	byte ptr es:[di],al
str_upr_2:
	call	IsDbcsLead
	jne	str_upr_n
	inc	di
	cmp	byte ptr es:[di],0
	je	str_upr_exit
str_upr_n:
	inc	di
	jmps	str_upr_lp
str_upr_exit:
	popm	<di,ax>
	ret
StrUpper	ENDP


CnvtHex		PROC	NEAR
	add	al,'0'
	cmp	al,'9'
	jbe	cnvt_hex_exit
	add	al,('A' -'0' - 10)
cnvt_hex_exit:
	ret
CnvtHex		ENDP

StrHex8_n	PROC	NEAR
	push	ax
	mov	ah,al
	shr	al,1
	shr	al,1
	shr	al,1
	shr	al,1
	call	CnvtHex
	stosb
	mov	al,ah
	and	al,0fh
	call	CnvtHex
	stosb
	pop	ax
	ret
StrHex8_n	ENDP

StrHex8		PROC	NEAR
	push	di
	call	StrHex8_n
	mov	byte ptr es:[di],0
	pop	di
	ret
StrHex8		ENDP


StrHex16_n	PROC	NEAR
	xchg	al,ah
	call	StrHex8_n
	xchg	al,ah
	call	StrHex8_n
	ret
StrHex16_n	ENDP

StrHex16	PROC	NEAR
	push	di
	call	StrHex16_n
	mov	byte ptr es:[di],0
	pop	di
	ret
StrHex16	ENDP

CnvtDigit	PROC	NEAR
	sub	al,'0'
	cmp	al,10		; if al<10 then set carry, else reset.
	cmc			; toggle carry
	ret
CnvtDigit	ENDP


CnvtHexDigit	PROC	NEAR
	push	bx
	mov	bl,'0'
	cmp	al,bl
	jb	cnvt_hexd_no
	cmp	al,'9'
	jbe	cnvt_hexd_ok
	mov	bl,'A' - 10
	cmp	al,'A'
	jb	cnvt_hexd_no
	cmp	al,'F'
	jbe	cnvt_hexd_ok
	mov	bl,'a' - 10
	cmp	al,'a'
	jb	cnvt_hexd_no
	cmp	al,'f'
	jbe	cnvt_hexd_ok
cnvt_hexd_no:
	stc			; if err then set carry
	jmps	cnvt_hexd_exit
cnvt_hexd_ok:
	sub	al,bl		; (carry is always reset)
cnvt_hexd_exit:
	pop	bx
	ret
CnvtHexDigit	ENDP


StrCpy		PROC	NEAR
	pushm	<ax,si,di>
str_cpy_lp:
	lodsw
	stosb
	cmp	al,0
	je	str_cpy_exit
	mov	al,ah
	stosb
	cmp	al,0
	jne	str_cpy_lp
str_cpy_exit:
	popm	<di,si,ax>
	ret
StrCpy		ENDP


StrCat		PROC	NEAR
	pushm	<ax,cx,di>
	mov	cx,-1
	mov	al,0
	repne	scasb
	dec	di
	call	StrCpy
	popm	<di,cx,ax>
	ret
StrCat		ENDP


StrCmp		PROC	NEAR
	pushm	<ax,bx,si,di>
str_cmp_lp:
	lodsw
	mov	bx,word ptr es:[di]
	add	di,2
	sub	bl,al
	jne	str_cmp_exit
	cmp	al,0
	je	str_cmp_exit
	sub	bh,ah
	jne	str_cmp_exit
	cmp	ah,0
	jne	str_cmp_lp
str_cmp_exit:
	popm	<di,si,bx,ax>
	ret
StrCmp		ENDP


MemCmp		PROC	NEAR
	pushm	<cx,si,di>
	repe	cmpsb
	popm	<di,si,cx>
	ret
MemCmp		ENDP


GetHex		PROC	NEAR
	pushm	<bx,cx,dx>
	xor	bx,bx
	xor	cx,cx
get_hex_lp:
	mov	al,byte ptr [si]
	call	CnvtHexDigit
	jc	get_hex_brk
	mov	cl,al
	mov	ax,16
	mul	bx
	add	ax,cx
	adc	dx,0
	or	dx,dx
	jnz	get_hex_overflow
	mov	bx,ax
	inc	si
	jmps	get_hex_lp
get_hex_overflow:
	stc
	mov	bx,-1
	jmps	get_hex_exit
get_hex_brk:
	clc
get_hex_exit:
	mov	ax,bx
	popm	<dx,cx,bx>
	ret
GetHex		ENDP


SearchPathLen	PROC	NEAR
	pushm	<ax,bx,si>
	mov	ax,0
	mov	bx,ax
	mov	cx,ax
src_path_len_lp:
	lodsb
	cmp	al,0
	je	src_path_len_brk
	inc	bx
	cmp	ah,0
	jne	src_path_len_2
	cmp	al,':'
	je	src_path_len_add
	cmp	al,'\'
	jne	src_path_len_1
src_path_len_add:
	mov	cx,bx
src_path_len_1:
	call	IsDbcsLead
	jne	src_path_len_2
	mov	ah,1
	jmps	src_path_len_3
src_path_len_2:
	mov	ah,0
src_path_len_3:
	jmps	src_path_len_lp
src_path_len_brk:
	popm	<si,bx,ax>
	ret
SearchPathLen	ENDP

COMMENT #
-------------------------------------------------------------------------------
 DOS バージョン取得関係
 あらかじめ Dosver_Init でひととおり取得しておいてから適当にワークを読む 
-------------------------------------------------------------------------------
#

_BSS		SEGMENT
Dos_ver		LABEL	WORD
Dosver_minor	db	1 dup (?)
Dosver_major	db	1 dup (?)
Dos_truever	LABEL	WORD
Truever_minor	db	1 dup (?)
Truever_major	db	1 dup (?)
bDos5		db	1 dup (?)
bOs2v2		db	1 dup (?)	; OS/2 v2+ ?
bOs2dos		db	1 dup (?)	; OS/2 v2+ Dos session?
Os2mvdm_ver	LABEL	WORD
Os2mvdm_minor	db	1 dup (?)
Os2mvdm_major	db	1 dup (?)
Windows_ver	LABEL	WORD
Winver_minor	db	1 dup (?)
Winver_major	db	1 dup (?)
Windows_mode	dw	1 dup (?)
_BSS		ENDS

Dosver_Init	PROC	NEAR
	mov	ax,0
	mov	[bDos5],al
	mov	[bOs2v2],al
	mov	[bOs2dos],al
	mov	[Os2mvdm_ver],ax
	mov	[Windows_ver],ax
	mov	ax,3000h
	int	21h
	mov	[Dosver_major],al
	mov	[Dosver_minor],ah
	mov	bx,ax
	mov	ax,3306h
	int	21h
	mov	[Truever_major],bl
	mov	[Truever_minor],bh
	cmp	bl,5
	jb	dosver_init_1
	cmp	bl,10
	je	dosver_init_1
	mov	[bDos5],1
dosver_init_1:
	mov	ax,4010h
	int	2fh
	cmp	ax,0
	jne	dosver_init_2
	mov	[Os2mvdm_ver],bx
	cmp	bh,20
	jb	dosver_init_1_2
	mov	[bOs2v2],1
dosver_init_1_2:
	cmp	bx,[Dos_truever]
	jne	dosver_init_2
	mov	[bOs2dos],1
dosver_init_2:
	cmp	[Dosver_major],3
	jb	dosver_init_3
	xor	bx,bx
	xor	cx,cx
	mov	ax,160ah
	int	2fh
	cmp	ax,0
	jne	dosver_init_3
	mov	[Windows_ver],bx
	mov	[Windows_mode],cx
dosver_init_3:
	ret
Dosver_Init	ENDP


COMMENT #
-------------------------------------------------------------------------------
 CPU Check
 （１６ビットセグメント中に置くこと）
-------------------------------------------------------------------------------
#

		.386

_DATA		SEGMENT
Cpu_type	db	0
Fpu_type	db	0		; (Not available)
bCpu186		db	0
bCpu286		db	0
bCpu386		db	0
bCpu486		db	0
_DATA		ENDS

CheckCpuType	PROC	NEAR
	cli
	mov	bp,sp
	and	sp,(NOT 3)	; スタックをダブルワード単位でアライン 
	nop
	pushf
	
	;
	; 8086, 186, v30 の判別 
	;
	pushf
	pop	ax
	and	ax,00fffh	; flags の上位 4bit をクリアして
	push	ax		; もいちど flags にたたきこむ 
	popf
	pushf			; flags を取り出して...
	pop	ax
	cmp	ax,0f000h	; 上位 4bit がすべてセットされていたら 8086
	jb	short chkcputype_286
	;
	; 8086 か 80186 (including NEC V30) か？ 
	;
	mov	ax,1
	mov	cl,(32 + 1)
	shl	ax,cl
	cmp	ax,0
	je	short chkcputype_exit
	mov	[bCpu186],1
	jmps	chkcputype_exit
chkcputype_286:
	;
	; 286 か 386 以上かを判別 
	;
	mov	[bCpu286],1
	
	pushf
	pop	ax
	or	ax,0f000h	; flags の上位 4bit をセットして 
	push	ax		; もいちど flags にたたきこむ 
	popf
	pushf			; flags を取り出して...
	pop	ax
	test	ax,0f000h	; 上位 4bit がぜんぶクリアだったら 286
	je	short chkcputype_exit
chkcputype_386:
	;
	; 386 か 486 か ?
	; （eflags 中の AC フラグをいじれれば 486 であり、いじれなければ 
	; 386 とみなしてもよいらしい） 
	;
	mov	[bCpu386],1
	pushfd
	pushm	<eax, ecx>
	
	pushfd
	pop	eax
	mov	ecx,eax		; save original eflags
	xor	eax,00040000h	; ACフラグをトグルして、もいちど eflags へ 
	push	eax
	popfd
	pushfd			; eflags を取り出して...
	pop	eax
	xor	eax,ecx		; ちゃんとトグルが反映しているか確認 
	je	short chkcputype_386_exit
	mov	[bCpu486],1
chkcputype_386_exit:
	popm	<ecx,eax>
	popfd
chkcputype_exit:
	mov	al,[bCpu286]
	add	al,al
	add	al,[bCpu386]
	add	al,[bCpu486]
	add	al,[bCpu186]
	mov	[Cpu_type],al
	popf
	mov	sp,bp
	nop
	sti
	ret
CheckCpuType	ENDP

		.286

_TEXT		ENDS


COMMENT %

COMMENT #
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
#

STACK		SEGMENT
	dw	256 dup (?)
STACK		ENDS

_TEXT		SEGMENT

pmsg		PROC	NEAR
	push	ax
	mov	ah,9
	int	21h
	pop	ax
	ret
pmsg		ENDP


pchr		PROC
	pushm	<ax,dx>
	mov	dl,al
	mov	ah,2
	int	21h
	popm	<dx,ax>
	ret
pchr		ENDP


pn		PROC
	push	ax
	mov	al,CR
	call	pchr
	mov	al,LF
	call	pchr
	pop	ax
	ret
pn		ENDP

pdec1		PROC
	add	al,'0'
	cmp	al,'9'
	jbe	@@2
	add	al,'A' - '9' -1
@@2:
	call	pchr
	ret
pdec1		ENDP


phex		PROC
	push	ax
	mov	ah,al
	shr	al,4
	call	pdec1
	mov	al,ah
	and	al,15
	call	pdec1
	pop	ax
	ret
phex		ENDP


phex16		PROC	NEAR
	xchg	al,ah
	call	phex
	xchg	al,ah
	call	phex
	ret
phex16		ENDP

Entry		PROC	FAR
	mov	ax,AGROUP
	mov	ds,ax
	mov	es,ax
	call	Dbcs_Init
	call	CheckCpuType
	mov	al,[Cpu_type]
	add	al,'0'
	mov	[msg],al
	mov	dx,ofs msg
	call	pmsg
	call	Dosver_Init

	mov	dx,ofs msgdos
	call	pmsg
	mov	al,[Dosver_major]
	call	phex
	mov	al,'.'
	call	pchr
	mov	al,[Dosver_minor]
	call	phex
	call	pn

	mov	dx,ofs msgtrue
	call	pmsg
	mov	al,[Truever_major]
	call	phex
	mov	al,'.'
	call	pchr
	mov	al,[Truever_minor]
	call	phex
	call	pn
	
	mov	dx,ofs msgwin
	call	pmsg
	mov	al,[Winver_major]
	call	phex
	mov	al,'.'
	call	pchr
	mov	al,[Winver_minor]
	call	phex
	call	pn
	
	mov	dx,ofs msgmvdm
	call	pmsg
	mov	al,[Os2mvdm_major]
	call	phex
	mov	al,'.'
	call	pchr
	mov	al,[Os2mvdm_minor]
	call	phex
	call	pn
	
	mov	dx,ofs msgdos5
	call	pmsg
	mov	al,[bDos5]
	call	pdec1
	call	pn
	
	mov	dx,ofs msgos2
	call	pmsg
	mov	al,[bOs2v2]
	call	pdec1
	call	pn
	
	mov	dx,ofs msgos2dos
	call	pmsg
	mov	al,[bOs2dos]
	call	pdec1
	call	pn
	
	mov	dx,ofs msgt
	call	PutMsg
	call	Put_n
	
	mov	dx,ofs msgpath
	call	PutMsg
	call	Put_n
	mov	si,dx
	call	SearchPathLen
	add	si,cx
	mov	byte ptr [si],'!'
	mov	byte ptr [si+1],0
	call	PutMsg
	call	Put_n
	
	mov	si,ofs sx_1
	call	GetHex
	call	phex16
	call	Put_n
	
	mov	ax,4c00h
	int	21h
Entry		ENDP

msg		db	'?86',13,10,'$'
msgwin		db	'Win  $'
msgdos		db	'DOS  $'
msgtrue		db	'TRUE $'
msgmvdm		db	'MVDM $'

msgdos5		db	'DOS5+   $'
msgos2		db	'OS/2 v2 $'
msgos2dos	db	'OS/2 DOS Session $'

msgt		db	'1234567890',0

msgpath		db	'C:\まぐろ\うがしゅー\dspxうがしゅー.exe',0

sx_1		db	'124?',0


_TEXT		ENDS

		END	Entry
%

		END
