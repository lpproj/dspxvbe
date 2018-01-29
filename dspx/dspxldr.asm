COMMENT #
===============================================================================
 dspxldr.asm
 version 2.20
 
 (c)鯖/LP-Project. 1995-96
===============================================================================
#

DSPXLDR_MAJOR	EQU	02h
DSPXLDR_MINOR	EQU	22h

_DBGP		MACRO	p1
	pushm	<ax,dx>
	mov	dl,p1
	mov	ah,2
	int	21h
	mov	ah,08h
	int	21h
	popm	<dx,ax>
ENDM

DSPX$LDR$VERSION = DSPXLDR_MAJOR * 256 + DSPXLDR_MINOR

		INCLUDE	mydef.inc
		INCLUDE	dspx.inc
		INCLUDE	dspxseg.inc
		
		INCLUDE	dspxcmn.ah
		
		INCLUDE dspxldr.inc
		
		IFDEF	??version
		LOCALS
		ENDIF

ARGV_LIMIT	EQU	10


STACK		SEGMENT
		dw	512 dup (?)
STACK		ENDS

_DATA		SEGMENT
errNeedDos3	db	'ERROR : DspxLdr does not work'
		db	' under DOS 2.x.',CR,LF,'$'
_DATA		ENDS

_BSS		SEGMENT
Pspseg		dw	1 dup (?)
Envseg		dw	1 dup (?)
Argc		dw	1 dup (?)
Argv		dw	1 dup (?)
Argv1		dw	(ARGV_LIMIT) dup (?)


arg_myname	db	270 dup (?)
arg_params	db	256 dup (?)
_BSS		ENDS

_TEXT		SEGMENT

		db	CR,LF
		db	'DSPX Loader ver '
		db	'0'+ DSPXLDR_MAJOR, '.'
		db	'0'+(DSPXLDR_MINOR SHR 4), '0'+(DSPXLDR_MINOR AND 15)
		db	' (c)鯖. 1995-97'
		db	CR,LF,0


Entry		PROC	FAR
	cld
	mov	ax,cs
	mov	ds,ax
	mov	[Pspseg],es
	mov	ax,word ptr es:[002ch]
	mov	[Envseg],ax
	mov	ah,30h
	int	21h
	cmp	al,2
	ja	@@2
	mov	dx,ofs errNeedDos3
	mov	ah,9
	int	21h
	mov	ax,4cffh
	int	21h
@@2:
	mov	ax,ss
	mov	bx,ds
	sub	ax,bx
	mov	cl,4
	shl	ax,cl
	cli
	mov	ss,bx
	add	sp,ax
	sti
	
	mov	bx,ss
	sub	bx,[Pspseg]
	mov	ax,sp
	add	ax,15
	mov	cl,4
	shr	ax,cl
	add	bx,ax
	mov	es,[Pspseg]
	mov	ah,4ah
	int	21h
	
	call	Dspxcmn_Init
	
	mov	si,ofs arg_myname
	mov	[Argv],si
	mov	es,[Envseg]
	call	GetMyName
	
	mov	cx,1
	mov	bx,ofs Argv + 2
	mov	es,[Pspseg]
	mov	di,0081h
	mov	si,ofs arg_params
	call	GetArgv
	inc	cx
	mov	[Argc],cx
	mov	bx,ofs [Argv]
	movseg	es,ds
@@lpcap:
	mov	di,word ptr [bx]
	call	StrUpper
	add	bx,2
	loop	@@lpcap
	
	call	DspxLdr_main
	
	mov	ah,4ch
	int	21h
Entry		ENDP


CheckSpcCr	PROC
	cmp	al,' '
	je	chk_spc_cr_exit
	cmp	al,HT
	je	chk_spc_cr_exit
	cmp	al,CR
	je	chk_spc_cr_exit
	cmp	al,LF
	je	chk_spc_cr_exit
	cmp	al,0
chk_spc_cr_exit:
	ret
CheckSpcCr	ENDP

CheckCr		PROC
	cmp	al,CR
	je	chk_cr_exit
	cmp	al,LF
chk_cr_exit:
	ret
CheckCr		ENDP

SkipSpc		PROC
skip_spc_lp:
	mov	al,byte ptr es:[di]
	inc	di
	cmp	al,0
	je	skip_spc_lp
	cmp	al,' '
	je	skip_spc_lp
	cmp	al,HT
	je	skip_spc_lp
	dec	di
	ret
SkipSpc		ENDP

GetArgv		PROC	NEAR
	pushm	<ax,bx,si,di>
get_argv_lp:
	call	SkipSpc
	call	CheckCr
	je	get_argv_exit
	cmp	cx,ARGV_LIMIT
	jae	get_argv_exit
	inc	cx
	mov	word ptr [bx],si
	add	bx,2
get_argv_cp:
	mov	al,byte ptr es:[di]
	call	CheckSpcCr
	jne	get_argv_cp_2
	mov	byte ptr [si],0
	inc	si
	jmps	get_argv_lp
get_argv_cp_2:
	mov	byte ptr [si],al
	inc	si
	inc	di
	jmps	get_argv_cp
get_argv_exit:
	dec	cx
	popm	<di,si,bx,ax>
	ret
GetArgv		ENDP

GetMyName	PROC	NEAR
	pushm	<ax,cx,si,di>
	xor	di,di
	mov	al,0
	mov	cx,32767
get_my_name_lp:
	repne	scasb
	jcxz	get_my_name_brk
	cmp	al,byte ptr es:[di]
	jne	get_my_name_lp
	cmp	word ptr es:[di+1],1
	jne	get_my_name_brk
	add	di,3
get_my_name_cp:
	mov	al,byte ptr es:[di]
	cmp	al,0
	je	get_my_name_brk
	mov	byte ptr [si],al
	inc	si
	inc	di
	jmps	get_my_name_cp
get_my_name_brk:
	mov	byte ptr [si],0
	popm	<di,si,cx,ax>
	ret
GetMyName	ENDP



COMMENT #
-------------------------------------------------------------------------------
 UMB 上に所定のバイト数確保する。 
 最初、アロケーションストラテジを 41h（UMB のみ、Best fit）にしていたら
 どうも OS/2 MVDM ではうまくいかないので 81h（UMB -> conv、Best fit）に
 してみた。（B000h より前に確保されちゃった場合は「UMB上の確保失敗」と
 みなす）
-------------------------------------------------------------------------------
#

AllocUmb	PROC	NEAR
	push	bx
	mov	ax,5800h
	int	21h
	mov	si,ax		; si = prev alloc strategy
	mov	ax,5802h
	int	21h
	xor	ah,ah
	mov	di,ax		; di = prev UMB link state
	mov	ax,5803h
	mov	bx,1
	int	21h		; UMB をつなぐ 
	mov	ax,5801h
	mov	bx,81h
	int	21h		; Allocate UMB best -> conv
	pop	bx
	push	bx
	add	bx,15
	shr	bx,4
	mov	ah,48h
	int	21h		; Alloc memory
	pushf			; UMB とストラテジを元に戻す 
	push	ax
	mov	ax,5803h
	mov	bx,di
	int	21h
	mov	ax,5801h
	mov	bx,si
	int	21h
	pop	ax
	popf
	jc	@@err
	cmp	ax,0b000h
	jae	@@2
	mov	es,ax
	mov	ah,49h
	int	21h
	mov	ax,1
	jmps	@@err
@@2:
	dec	ax
	mov	es,ax		; MCB segment
	inc	ax
	mov	word ptr es:[1],ax	; オーナを自分自身にする。 
	pushm	<cx,si,di,ds>		; 名前は現在のものを流用 
	mov	di,8
	mov	si,di
	mov	cx,4
	mov	ax,[Pspseg]
	dec	ax
	mov	ds,ax
	rep	movsw
	popm	<ds,di,si,cx>
	mov	ax,es
	inc	ax
	mov	es,ax
	mov	ax,0
	jmps	@@exit
@@err:
@@exit:
	pop	bx
	ret
AllocUmb	ENDP


LOADPROF_MEMERR	EQU	1
LOADPROF_FAILOPEN	EQU	2
LOADPROF_FAILREAD	EQU	3
LOADPROF_ILLEGAL	EQU	4

_DATA		SEGMENT
DSPX_PRO	db	'DSPX.PRO',0
errProfMem	db	'ERROR : 作業用メモリの確保に失敗しました。',CR,LF,0
errFailOpen	db	'ERROR : プロファイル（DSPX.PRO）が読み込めません。'
		db	CR,LF,0
errFailRead	db	'ERROR : プロファイル（DSPX.PRO）の読み込みエラー。'
		db	CR,LF,0
errIllegal	db	'ERROR : プロファイル（DSPX.PRO）が本ドライバのもので'
		db	'ないか、異常です。',CR,LF,0
_DATA		ENDS
_DATA		SEGMENT
ldp_ptr		dd	?
		dd	?
ldp_size	dw	32768
ldp_bottom	dw	?
_DATA		ENDS

AllocProfBuffer	PROC	NEAR
	mov	ax,[Buf_Size]
	or	ax,ax
	jz	@@2
	mov	[ldp_size],ax
	mov	ax,[Buf_Entry]
	mov	word ptr [ldp_ptr],ax
	mov	word ptr [ldp_ptr + 2],ds
	mov	ax,0
	clc
	jmp	@@exit
@@2:
	cmp	[bDos5],0
	je	@@alc_2
	mov	ax,5802h
	int	21h
	xor	ah,ah
	mov	di,ax
	mov	ax,5803h
	xor	bx,bx
	int	21h
@@alc_2:
	mov	ax,5800h
	int	21h
	xor	ah,ah
	mov	si,ax
	mov	ax,5801h
	mov	bx,1
	int	21h
	mov	ah,48h
	mov	bx,[ldp_size]
	shr	bx,4
	stc
	int	21h
	mov	word ptr [ldp_ptr],0
	mov	word ptr [ldp_ptr + 2],ax
	
	pushf
	cmp	[bDos5],0
	je	@@alc_3
	mov	ax,5803h
	mov	bx,di
	int	21h
@@alc_3:
	mov	ax,5801h
	mov	bx,si
	int	21h
	popf
@@exit:
	jc	@@exit_2
	pushm	<cx,di,es>
	les	di,[ldp_ptr]
	mov	cx,[ldp_size]
	mov	al,00h
	rep	stosb
	popm	<es,di,cx>
	pushf
	mov	ax,[ldp_size]
	add	ax,word ptr [ldp_ptr]
	mov	[ldp_bottom],ax
	popf
@@exit_2:
	ret
AllocProfBuffer	ENDP

FreeProfBuffer	PROC	NEAR
	pushm	<ax,es>
	cmp	[Buf_Size],0
	jnz	@@exit
	mov	es,word ptr [ldp_ptr + 2]
	mov	ah,49h
	int	21h
@@exit:
	popm	<es,ax>
	ret
FreeProfBuffer	ENDP


LoadProfile	PROC	NEAR
	pushm	<bx,cx,si,di,es>
	cld
	movseg	es,ds
	mov	si,ofs arg_myname
	call	SearchPathLen
	mov	di,si
	add	di,cx
	mov	si,ofs DSPX_PRO
	call	StrCpy
	call	AllocProfBuffer
	jnc	@@2
	mov	ax,LOADPROF_MEMERR
	mov	dx,ofs errProfMem
	jmp	@@exit
@@2:
	
	mov	dx,ofs arg_myname
	mov	ax,3d00h
	int	21h
	mov	bx,ax
	jnc	@@3
	mov	ax,LOADPROF_FAILOPEN
	mov	dx,ofs errFailOpen
	jmp	@@errf
@@3:
	
	push	ds
	mov	cx,[ldp_size]
	sub	cx,2
	lds	dx,[ldp_ptr]
	mov	ah,3fh
	int	21h
	pop	ds
	pushf
	push	ax
	mov	ah,3eh
	int	21h
	pop	ax
	popf
	jnc	@@4
	mov	ax,LOADPROF_FAILREAD
	mov	dx,ofs errFailRead
	jmp	@@errf
@@4:
	cmp	ax,18
	ja	@@5
	mov	ax,LOADPROF_ILLEGAL
	mov	dx,ofs errIllegal
	jmp	@@errf
@@5:
	les	bx,[ldp_ptr]
	call	GetProfileInfo
	call	FreeProfBuffer
	cmp	ax,0
	je	@@errf
	mov	dx,ofs errIllegal
@@errf:
	;push	ax
	;mov	ah,49h
	;int	21h
	;pop	ax
@@errexit:
@@exit:
	popm	<es,di,si,cx,bx>
	ret
LoadProfile	ENDP


_DATA		SEGMENT
prec		db	0
sVideoCardInfo	db	PRO_VIDEOCARD
sModeTable	db	PRO_MODETABLE
_DATA		ENDS

P_VC		EQU	00000001b
P_MT		EQU	00000010b

GetProfileInfo	PROC	NEAR
	mov	[prec],0
@@lp:
	mov	ax,word ptr es:[bx]
	or	ax,ax
	jz	@@brk
	cmp	ax,18
	jbe	@@err
	lea	di,[bx + 2]
	mov	si,ofs sVideoCardInfo
	mov	cx,16
	call	MemCmp
	jne	@@2
	;
	; VideoCardInfo ...
	;
	lea	di,[bx + 18]
	mov	cx,word ptr es:[bx]
	sub	cx,18
	call	Drv_Checkprof
	cmp	al,0
	je	@@1
	jmp	@@err
@@1:
	or	[prec],P_VC
	jmps	@@next
@@2:
	mov	si,ofs sModeTable
	mov	cx,16
	call	MemCmp
	jne	@@3
	;
	; VideoModeTable ...
	;
	mov	cx,word ptr es:[bx + 18 + 2]
	cmp	cx,[Drv_Drvinfo.drv_countoftbls]
	jne	@@err
	lea	di,[bx + 18 + 2 + 2]
	mov	si,[Drv_Drvinfo.drv_vms]
	call	TfrVmt
@@3:
@@next:
	add	bx,word ptr es:[bx]
	jc	@@err
	cmp	bx,[ldp_bottom]
	jb	@@lp
@@err:
	mov	ax,1
	jmps	@@exit
@@brk:
	mov	ax,0
@@exit:
	ret
GetProfileInfo	ENDP


_DATA		SEGMENT
index_03	db	-1
index_73	db	-1
index_70	db	-1
index_71	db	-1
index_03_n	db	-1
index_73_n	db	-1
_DATA		ENDS

TfrVmt		PROC	NEAR
	pushm	<bx>
	xor	dx,dx
@@lp:
	mov	al,byte ptr es:[di]
	inc	di
	cmp	al,1
	jne	@@2
	test	byte ptr es:[di + (tVms.vms_info)],80h
	jnz	@@2
	mov	al,es:[di + (tVms.vms_vm)]
	cmp	al,70h
	jne	@@i_2
	mov	[index_70],dl
@@i_2:
	cmp	al,71h
	jne	@@i_3
	mov	[index_71],dl
@@i_3:
	cmp	al,03h
	jne	@@i_4
	cmp	word ptr es:[di + (tVms.vms_columns)],(25 * 256) + 80
	je	@@i_3_2
	mov	[index_03],dl
	jmps	@@2
@@i_3_2:
	mov	[index_03_n],dl
@@i_4:
	cmp	al,73h
	jne	@@2
	cmp	word ptr es:[di + (tVms.vms_columns)],(25 * 256) + 80
	je	@@i_4_2
	mov	[index_73],dl
	jmps	@@2
@@i_4_2:
	mov	[index_73_n],dl
@@2:
	push	cx
	xchgseg	ds,es
	xchg	si,di
	mov	cx,16
	rep	movsb
	xchg	si,di
	xchgseg	ds,es
	pop	cx
	inc	dx
	cmp	dx,cx
	jb	@@lp
@@exit:
	popm	<bx>
	ret
TfrVmt		ENDP


SetVMIndex	PROC	NEAR
	mov	ah,12h
	mov	al,[index_70]
	mov	bx,7039h
	int	10h
	mov	ah,12h
	mov	al,[index_71]
	mov	bx,7139h
	int	10h
	mov	ah,12h
	mov	al,[index_03]
	mov	bx,0339h
	int	10h
	mov	ah,12h
	mov	al,[index_73]
	mov	bx,7339h
	int	10h
	mov	ah,12h
	mov	al,[index_03_n]
	mov	bx,0338h
	int	10h
	mov	ah,12h
	mov	al,[index_73_n]
	mov	bx,7338h
	int	10h
	ret
SetVMIndex	ENDP


_DATA		SEGMENT
param_argc	dw	1
param_err	db	0
param_err_drv	db	0
param_fatal	db	0
;
opt_check	db	0
opt_help	db	0
opt_r		db	0
opt_noprof	db	0
opt_noumb	db	0
opt_hs		db	0
opt_hs_mdfy	db	0
;
opt_vm1_mdfy	db	0
opt_vm2_mdfy	db	0
opt_vm3_mdfy	db	0
opt_vm4_mdfy	db	0
opt_vm1		dw	6ah
opt_vm2		dw	6ah
opt_vm3		dw	6ah
opt_vm4		dw	6ah

sCheck		db	'/CHECK',0
sNoumb		db	'NOUMB',0
sNoprof		db	'NOPROF',0
sNp		db	'NP',0
sVmeq		db	'VM='
sVm1eq		db	'VM1='
sVm2eq		db	'VM2='
sVm3eq		db	'VM3='
sVm4eq		db	'VM4='
sModeeq		db	'MODE='
sMode1eq	db	'MODE1='
sMode2eq	db	'MODE2='
sMode3eq	db	'MODE3='
sMode4eq	db	'MODE4='


_DATA		ENDS

GetHex_c	PROC	NEAR
	call	GetHex
	jc	get_hex_c_exit
	cmp	byte ptr [si],0
	je	get_hex_c_exit
	stc
get_hex_c_exit:
	ret
GetHex_c	ENDP

DspxLdr_prm	PROC	NEAR
	pushm	<bx,cx,si,di,es>
	mov	ax,[Argc]
	mov	[param_argc],ax
	mov	bx,ofs Argv
	movseg	es,ds
@@lp0:
	add	bx,2
	dec	[param_argc]
	jne	@@1
	jmp	@@exit
@@1:
	mov	si,word ptr [bx]
	mov	di,ofs sCheck
	call	StrCmp
	jne	@@1_2
	mov	[opt_check],1
	jmp	@@exit
@@1_2:
	pushm	<bx,cx>
	call	Drv_Getparam		; call driver
	popm	<cx,bx>
	test	al,1			; recognized by driver?
	jz	@@2
@@prm_err:
	test	al,80h			; error?
	jz	@@1_3
	mov	[param_err_drv],1
	test	ah,80h
	jz	@@1_3
	mov	[param_fatal],1
	jmp	@@exit
@@1_3:
	jmps	@@lp0
	
	;
	; default の解析 
	;
@@2:
	lodsb
	cmp	al,'/'
	je	@@opt
	cmp	al,'-'
	je	@@opt
	mov	[param_err],1
	jmps	@@lp0
@@opt:
	;
	; /? or /H
	;
	mov	ax,word ptr [si]
	cmp	al,'?'
	jne	@@opt_2
@@opt_h:
	mov	[opt_help],1
	jmp	@@opt_next
@@opt_2:
	cmp	ax,'H'
	je	@@opt_h
	;
	; /R
	;
	cmp	ax,'R'
	jne	@@opt_3
	mov	[opt_r],1
	jmp	@@opt_next
@@opt_3:
	;
	; /HS=...
	;
	cmp	ax,'SH'
	jne	@@opt_4
	cmp	byte ptr [si+2],'='
	jne	@@opt_4
	mov	ax,word ptr [si+3]
	mov	cl,0
	cmp	ax,'FO'			; /HS=OF(F)
	je	@@hs
	mov	cl,1
	cmp	ax,'CL'			; /HS=LC
	je	@@hs
	mov	cl,2
	cmp	ax,'NO'			; /HS=ON
	je	@@hs
	mov	cl,10h
	cmp	ax,'AW'			; /HS=WA
	;jne	@@opt_5
	jne	@@opt_hs_prmerr
@@hs:
	mov	[opt_hs],cl
	mov	[opt_hs_mdfy],1
	jmp	@@opt_next
@@opt_hs_prmerr:
	mov	ax,0081h
	jmp	@@prm_err
@@opt_4:
@@opt_5:
	;
	; /NOUMB
	;
	mov	di,ofs sNoumb
	call	StrCmp
	jne	@@opt_6
	mov	[opt_noumb],1
	jmp	@@opt_next
@@opt_6:
	mov	di,ofs sNp
	call	StrCmp
	je	@@opt_np
	mov	di,ofs sNoprof
	call	StrCmp
	jne	@@opt_7
@@opt_np:
	mov	[opt_noprof],1
	jmp	@@opt_next
@@opt_7:
	;
	; /VM=... or /MODE=...
	;
	mov	di,ofs sVmeq
	mov	cx,3
	call	MemCmp
	je	@@opt_vm
	mov	di,ofs sVm1eq
	mov	cx,4
	call	MemCmp
	je	@@opt_vm
	mov	di,ofs sModeeq
	mov	cx,5
	call	MemCmp
	je	@@opt_vm
	mov	di,ofs sMode1eq
	mov	cx,6
	call	MemCmp
	jne	@@opt_8
@@opt_vm:
	add	si,cx
	call	GetHex_c
	jnc	@@opt_7_2
	mov	al,1
	mov	[param_err],al
	mov	[param_fatal],al
	jmp	@@exit
@@opt_7_2:
	mov	[opt_vm1_mdfy],1
	mov	[opt_vm1],ax
	jmp	@@opt_next
@@opt_8:
	;
	; /VM2=... or /MODE2=...
	;
	mov	cx,4
	mov	di,ofs sVm2eq
	call	MemCmp
	je	@@opt_vm2
	mov	cx,6
	mov	di,ofs sMode2eq
	call	MemCmp
	jne	@@opt_9
@@opt_vm2:
	add	si,cx
	call	GetHex_c
	jnc	@@opt_8_2
	mov	al,1
	mov	[param_err],al
	mov	[param_fatal],al
	jmp	@@exit
@@opt_8_2:
	mov	[opt_vm2_mdfy],1
	mov	[opt_vm2],ax
	jmp	@@opt_next
@@opt_9:
	;
	; /VM3=... or /MODE3=...
	;
	mov	cx,4
	mov	di,ofs sVm3eq
	call	MemCmp
	je	@@opt_vm3
	mov	cx,6
	mov	di,ofs sMode3eq
	call	MemCmp
	jne	@@opt_10
@@opt_vm3:
	add	si,cx
	call	GetHex_c
	jnc	@@opt_9_2
	mov	al,1
	mov	[param_err],al
	mov	[param_fatal],al
	jmp	@@exit
@@opt_9_2:
	mov	[opt_vm3_mdfy],1
	mov	[opt_vm3],ax
	jmp	@@opt_next
@@opt_10:
	;
	; /VM4=... or /MODE4=...
	;
	mov	cx,4
	mov	di,ofs sVm4eq
	call	MemCmp
	je	@@opt_vm4
	mov	cx,6
	mov	di,ofs sMode4eq
	call	MemCmp
	jne	@@opt_11
@@opt_vm4:
	add	si,cx
	call	GetHex_c
	jnc	@@opt_10_2
	mov	al,1
	mov	[param_err],al
	mov	[param_fatal],al
	jmp	@@exit
@@opt_10_2:
	mov	[opt_vm4_mdfy],1
	mov	[opt_vm4],ax
	jmp	@@opt_next
@@opt_11:
@@opt_next:
	jmp	@@lp0
@@exit:
	popm	<es,di,si,cx,bx>
	ret
DspxLdr_prm	ENDP

G_DATA		SEGMENT
dspx_org_int10	dd	?
G_DATA		ENDS
_DATA		SEGMENT
dspx_drv_param	dd	?
dspx_mode_info	dw	0
dspx_tb_size	dw	13056
dspx_drv_name	dd	?
dspx_my_api	dd	?
dspx_ismydriver	db	0
_DATA		ENDS


GetVextinfo	PROC	NEAR
	pushm	<bx,es>
	mov	ax,5010h
	int	15h
	push	ax
	or	ah,ah
	jnz	@@exit
	mov	ax,es:[bx + (tDspx.dspx_info)]
	mov	[dspx_mode_info],ax
	mov	ax,es:[bx + (tDspx.dspx_tbsize)]
	mov	[dspx_tb_size],ax
	mov	ax,word ptr es:[bx + (tDspx.dspx_org10)]
	mov	word ptr [dspx_org_int10],ax
	mov	ax,word ptr es:[bx + (tDspx.dspx_org10) + 2]
	mov	word ptr [dspx_org_int10 + 2],ax
	les	bx,es:[bx + (tDspx.dspx_drv)]
	mov	word ptr [dspx_drv_param],bx
	mov	word ptr [dspx_drv_param + 2],es
	mov	word ptr [dspx_drv_name + 2],es
	mov	word ptr [dspx_my_api + 2],es
	mov	ax,es:[bx + (tDspxDrv.drv_name)]
	mov	word ptr [dspx_drv_name],ax
	mov	ax,es:[bx + (tDspxDrv.drv_myapi)]
	mov	word ptr [dspx_my_api],ax
	test	[dspx_mode_info],1
	jz	@@exit
	mov	si,[Drv_Drvinfo.drv_name]
	les	di,[dspx_drv_name]
	call	StrCmp
	jne	@@exit
	mov	[dspx_ismydriver],1
@@exit:
	pop	ax
	popm	<es,bx>
	ret
GetVextinfo	ENDP


RegisterDrv	PROC	NEAR
	mov	ax,5011h
	int	15h
	or	ah,ah
	jz	@@noerr
	mov	dx,ofs errAlreadyDrv
	cmp	ah,1
	je	@@err
	mov	dx,ofs errFailRegister
	cmp	ah,3
	je	@@err
	mov	dx,ofs errMisc
@@err:
	mov	ax,1
	ret
@@noerr:
	mov	ax,0
	ret
RegisterDrv	ENDP


_DATA		SEGMENT
errNotJp	db	'ERROR : For Japanese mode only.',CR,LF,0
errNoDispsys	db	'ERROR : Not found $DISP.SYS.',CR,LF,0
errMisc		db	'ERROR : なにやらエラーがでてしまいました。',CR,LF,0
errNotVext	db	'ERROR : ディスプレイドライバは IBM DOS/V Extension に'
		db	'対応していません。',CR,LF,0
errDefParamErr	db	'ERROR : パラメータに誤りがあります。',CR,LF,0
errUse186	db	'ERROR : 80186以降の CPU が必要です。',CR,LF,0
errAlreadyDrv	db	'ERROR : すでにビデオ拡張ドライバが導入されています。'
		db	CR,LF,0
errNoDrv	db	'ERROR : ビデオ拡張ドライバは導入されていない'
		db	'もようです。',CR,LF,0
errFailRegister	db	'ERROR : ビデオ拡張ドライバの登録が拒否されました。'
		db	CR,LF,0
errNotMyself	db	'ERROR : 本ドライバ以外のビデオ拡張ドライバが導入'
		db	'されています。',CR,LF,0
errDrvLocked	db	'ERROR : ビデオ拡張ドライバがロックされています。'
		db	CR,LF,0
errVectHooked	db	'ERROR : 元に戻せない割り込みベクタがあります。'
		db	CR,LF,0
wrnNotEnuffTB	db	'警告  : テキストバッファ不足のため、使えない'
		db	'ビデオモードがあります。',CR,LF,0
wrnNoUMB	db	'警告  : UMB に導入できませんので、基本メモリ上に'
		db	'導入します。',CR,LF,0
msgTsr		db	CR,LF,'ドライバが導入されました。',CR,LF,0
msgRelease	db	CR,LF,'ドライバが導入解除されました。',CR,LF,0
_DATA		ENDS
_BSS		SEGMENT
cvms_errdrv	db	1 dup (?)
cvms_tbover	db	1 dup (?)
_BSS		ENDS

_DATA		SEGMENT
iswrnNotEnuffTB	db	0
iswrnNoUMB	db	0
iserrCheckvideo	db	0
iserrCheckvms	db	0
_DATA		ENDS

PutLdrErr	PROC	NEAR
	push	ax
	mov	al,[iserrCheckvideo]
	cmp	al,0
	je	@@1
	call	Drv_Checkvideoerr
@@1:
	cmp	[iserrCheckvms],0
	je	@@2
	call	Drv_Checkvmserr
@@2:
	cmp	[iswrnNotEnuffTB],0
	je	@@3
	mov	dx,ofs wrnNotEnuffTB
	call	PutMsg
@@3:
	cmp	[iswrnNoUMB],0
	je	@@4
	mov	dx,ofs wrnNoUMB
	call	PutMsg
@@4:
	pop	ax
	ret
PutLdrErr	ENDP

DspxLdr_Chkvm	PROC	NEAR
	pushm	<cx,si>
	mov	[cvms_errdrv],0
	mov	[cvms_tbover],0
	mov	si,[Drv_Drvinfo.drv_vms]
	mov	cx,[Drv_Drvinfo.drv_countoftbls]
@@lp:
	call	Drv_Checkvms
	cmp	al,80h
	jb	@@2
	mov	[cvms_errdrv],1
	jmps	@@cnt
@@2:
	test	byte ptr [si + (tVms.vms_info)],80h
	jnz	@@cnt
	mov	al,[si + (tVms.vms_columns)]
	mul	byte ptr [si + (tVms.vms_rows)]
	add	ax,ax
	jc	@@tbovr
	cmp	byte ptr [si + (tVms.vms_vm)],70h
	je	@@4
	cmp	byte ptr [si + (tVms.vms_vm)],73h
	je	@@4
	add	ax,ax
	jc	@@tbovr
@@4:
	cmp	ax,[dspx_tb_size]
	jb	@@cnt
@@tbovr:
	or	byte ptr [si + (tVms.vms_info)],80h
	mov	[cvms_tbover],1
@@cnt:
	add	si,16
	loop	@@lp
	popm	<si,cx>
	cmp	[cvms_tbover],0
	je	@@exit_p_2
	mov	[iswrnNotEnuffTB],1
	;mov	dx,ofs wrnNotEnuffTB
	;call	PutMsg
@@exit_p_2:
	cmp	[cvms_errdrv],0
	je	@@exit_p_3
	mov	[iserrCheckvms],1
	;call	Drv_Checkvmserr
@@exit_p_3:
	ret
DspxLdr_Chkvm	ENDP


DspxLdr_main	PROC	NEAR
	call	DspxLdr_prm
	mov	al,[opt_check]
	cmp	al,0
	je	@@2
	call	Drv_Checkvideo
	jmp	@@exit
@@2:
	call	Drv_Opening
	cmp	[opt_help],0
	je	@@chkdispsys
	call	Drv_Displayhelp
	mov	al,0
	jmp	@@exit
@@chkdispsys:
	call	IsEnvSbcs
	jne	@@chkdispsys_2
	mov	dx,ofs errNotJp
	jmp	@@errexit
@@chkdispsys_2:
	mov	ax,4900h
	int	15h
	or	ah,ah
	jnz	@@chkdispsys_nodisp
	or	bl,bl
	jz	@@chkdispsys_3
@@chkdispsys_nodisp:
	mov	dx,ofs errNoDispsys
	jmp	@@errexit
@@chkdispsys_3:
	call	GetVextinfo
	or	ah,ah
	jz	@@3
	mov	dx,ofs errNotVext
	jmp	@@errexit
@@3:
	cmp	[param_err],0
	je	@@4
	mov	dx,ofs errDefParamErr
	call	PutMsg
@@4:
	cmp	[param_err_drv],0
	je	@@5
	call	Drv_Paramerr
@@5:
	cmp	[param_fatal],0
	je	@@6
	mov	al,1
	jmp	@@exit
@@6:
	cmp	[opt_r],0
	je	@@7
@@r:
	call	DspxLdr_rel
	cmp	al,0
	jne	@@errexit
	jmps	@@exit
	
@@7:
	call	DspxLdr_tsr
	;cmp	al,0
	;jne	@@errexit
@@exit:
	ret
@@errexit:
	call	PutMsg
	mov	al,1
	ret
DspxLdr_main	ENDP


DspxLdr_tsr	PROC	NEAR
	cmp	[Cpu_type],1
	jae	@@1
	mov	dx,ofs errUse186
	jmp	@@errexitp
@@1:
	mov	al,[opt_check]
	call	Drv_Checkvideo
	cmp	al,0
	je	@@2
	mov	[iserrCheckvideo],al
	cmp	al,2
	je	@@2
	push	ax
	call	Drv_Checkvideoerr
	pop	ax
	jmp	@@errexit
@@2:
	cmp	[opt_noprof],0
	jne	@@3
	call	LoadProfile
	cmp	ax,0
	je	@@3
	jmp	@@errexitp
@@3:
	call	DspxLdr_Chkvm
	call	Drv_Preloadjob
	call	Drv_Getbottom
	cmp	[opt_noumb],0
	jne	@@tsrconv
	cmp	[Pspseg],0b000h
	jae	@@tsrconv
	call	AllocUmb
	cmp	ax,0
	je	@@tsrumb
	mov	[iswrnNoUMB],1
	;mov	dx,ofs wrnNoUMB
	;call	PutMsg
@@tsrconv:
	push	bx
	mov	es,[Pspseg]
	push	bp
	push	cs
	push	[Drv_Drvinfo.drv_myapi]
	mov	bp,sp
	mov	ah,LPDRV_SETSEG
	call	dword ptr ss:[bp]
	add	sp,4
	pop	bp
	mov	word ptr es:[002ch],0000h	; 環境をクリア
	mov	es,[Envseg]
	mov	ah,49h
	int	21h
	movseg	es,cs
	mov	bx,ofs Drv_Drvinfo
	call	RegisterDrv
	pop	bx
	or	ax,ax
	je	@@tsr_2
	jmp	@@errexitp
@@tsr_2:
	call	GetVectTable
	call	SetNewVect
	call	SetDspxN
	
	call	PutLdrErr
	
	mov	dx,ofs msgTsr
	call	PutMsg
	add	bx,010fh
	shr	bx,4
	mov	dx,bx
	mov	ax,3100h
	int	21h
	
@@tsrumb:
	mov	cx,bx
	xor	si,si
	mov	di,si
	rep	movsb
	push	bp
	push	es
	push	[Drv_Drvinfo.drv_myapi]
	mov	bp,sp
	mov	ah,LPDRV_SETSEG
	call	dword ptr ss:[bp]
	add	sp,4
	pop	bp
	mov	bx,ofs Drv_Drvinfo
	call	RegisterDrv
	or	ax,ax
	je	@@umb_2
	mov	ah,49h
	int	21h
	jmp	@@errexitp
@@umb_2:
	call	GetVectTable
	call	SetNewVect
	call	SetDspxN
	
	call	PutLdrErr
	
	mov	dx,ofs msgTsr
	call	PutMsg

@@exit:
	mov	ax,0
	ret
@@errexitp:
	call	PutMsg
@@errexit:
	mov	ax,1
	ret
DspxLdr_tsr	ENDP

SetDspxN	PROC	NEAR
	pushm	<ax,bx,cx>
	call	SetVMIndex
	mov	cx,-1
	mov	ax,1203h
	mov	bl,3ah
	int	10h
	cmp	al,12h
	jne	@@exit
	cmp	ch,-1
	je	@@exit
	mov	ax,3
	int	10h
	call	Put_n
@@exit:
	popm	<cx,bx,ax>
	ret
SetDspxN	ENDP


DspxLdr_rel	PROC	NEAR
	test	[dspx_mode_info],1
	jnz	@@2
	mov	dx,ofs errNoDrv
	jmp	@@err
@@2:
	les	di,[dspx_drv_name]
	mov	si,[Drv_Drvinfo.drv_name]
	call	StrCmp
	je	@@3
	mov	dx,ofs errNotMyself
	jmp	@@err
@@3:
	call	GetVectTable
	call	QueryVectRmv
	jnc	@@3_1
	mov	dx,ofs errVectHooked
	jmps	@@err
@@3_1:
	call	SetVMIndex
	mov	ax,0012h
	int	10h
	mov	ax,5012h
	int	15h
	push	ax
	mov	ax,0003h
	int	10h
	pop	ax
	or	ah,ah
	jz	@@4
	mov	dx,ofs errDrvLocked
	cmp	ah,1
	je	@@err
	mov	dx,ofs errMisc
	jmps	@@err
@@4:
	call	RemoveVect
	mov	ah,LPDRV_GETSEG
	call	[dspx_my_api]
	mov	ah,49h
	int	21h
	mov	dx,ofs msgRelease
	call	PutMsg
	
@@exit:
	mov	ax,0
	ret
@@err:
	mov	ax,1
	ret
DspxLdr_rel	ENDP

GetDspxldrVer	PROC	NEAR
	mov	al,DSPXLDR_MAJOR
	mov	ah,DSPXLDR_MINOR
	ret
GetDspxldrVer	ENDP



_BSS		SEGMENT
myapi_entry	dd	1 dup (?)
vecttable	dd	1 dup (?)
vectcount	dw	1 dup (?)
_BSS		ENDS

GetVectTable	PROC	NEAR
	pushm	<ax,bx,cx,di,es>
	mov	[vectcount],0
	mov	ax,5010h
	int	15h
	or	ah,ah
	jnz	@@exit
	les	bx,es:[bx + (tDspx.dspx_drv)]
	mov	bx,es:[bx + (tDspxDrv.drv_myapi)]
	mov	word ptr [myapi_entry],bx
	mov	word ptr [myapi_entry + 2],es
	mov	ah,LPDRV_GETVECTINFO
	call	[myapi_entry]
	jc	@@exit
	mov	[vectcount],cx
	mov	word ptr [vecttable],di
	mov	word ptr [vecttable+2],es
@@exit:
	popm	<es,di,cx,bx,ax>
	ret
GetVectTable	ENDP


SetNewVect	PROC	NEAR
	pushm	<bx,cx,dx,di,es>
	mov	cx,[vectcount]
	jcxz	@@ok
	les	di,[vecttable]
@@lp:
	test	byte ptr es:[di + (tLPVect.lpvect_flag)],LPDRV_USEVECT
	jz	@@cnt
	mov	al,es:[di + (tLPVect.lpvect_no)]
	mov	ah,35h
	push	es
	int	21h
	mov	dx,es
	pop	es
	jc	@@err
	mov	word ptr es:[di + (tLPVect.lpvect_old)],bx
	mov	word ptr es:[di + (tLPVect.lpvect_old) + 2],dx
	push	ds
	mov	ah,25h
	mov	dx,es:[di + (tLPVect.lpvect_new)]
	movseg	ds,es
	int	21h
	pop	ds
@@cnt:
	add	di,SIZE tLPVect
	loop	@@lp
@@ok:
	mov	ax,0
	clc
	jmps	@@exit
@@err:
	mov	ah,-1
	stc
@@exit:
	popm	<es,di,dx,cx,bx>
	ret
SetNewVect	ENDP


QueryVectRmv	PROC	NEAR
	pushm	<bx,cx,dx,di,es>
	mov	cx,[vectcount]
	jcxz	@@ok
	les	di,[vecttable]
@@lp:
	test	byte ptr es:[di + (tLPVect.lpvect_flag)],LPDRV_USEVECT
	jz	@@cnt
	mov	al,es:[di + (tLPVect.lpvect_no)]
	mov	ah,35h
	push	es
	int	21h
	mov	dx,es
	pop	es
	cmp	bx,es:[di + (tLPVect.lpvect_new)]
	jne	@@no
	cmp	dx,word ptr [vecttable + 2]
	jne	@@no
@@cnt:
	add	di,SIZE tLPVect
	loop	@@lp
@@ok:
	mov	ax,0
	clc
	jmps	@@exit
@@no:
	mov	ah,-1
	stc
@@exit:
	popm	<es,di,dx,cx,bx>
	ret
QueryVectRmv	ENDP


RemoveVect	PROC	NEAR
	pushm	<bx,cx,dx,di,es>
	mov	cx,[vectcount]
	jcxz	@@ok
	les	di,[vecttable]
@@lp:
	test	byte ptr es:[di + (tLPVect.lpvect_flag)],LPDRV_USEVECT
	jz	@@cnt
	mov	al,es:[di + (tLPVect.lpvect_no)]
	mov	ah,25h
	push	ds
	lds	dx,es:[di + (tLPVect.lpvect_old)]
	int	21h
	pop	ds
@@cnt:
	add	di,SIZE tLPVect
	loop	@@lp
@@ok:
	mov	ax,0
	clc
@@exit:
	popm	<es,di,dx,cx,bx>
	ret
RemoveVect	ENDP


_TEXT		ENDS

		END	Entry
