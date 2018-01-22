COMMENT #
===============================================================================
 mydef.inc
 version 1.10

 (c)鯖/LP-Project. 1994-96
===============================================================================
#

$SAVA$INC$MYDEF = (0100h + 10)		; 上位 8bit = major,下位 = minor (10進)

CR		EQU	13
LF		EQU	10
HT		EQU	9
cEOF		EQU	1ah
cESC		EQU	1bh

AUTHOR		EQU	'鯖/LP-Project'
;COPYRIGHT	EQU	'(c) 鯖/LP-Project,1995.'

HANDLE_STDIN	EQU	0
HANDLE_STDOUT	EQU	1
HANDLE_STDERR	EQU	2
HANDLE_STDAUX	EQU	3
HANDLE_STDPRN	EQU	4


movseg		MACRO	p1,p2
	push	p2
	pop	p1
ENDM

xchgseg		MACRO	p1,p2
	push	p1
	push	p2
	pop	p1
	pop	p2
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

jmps		MACRO	p1
	jmp	short p1
ENDM

_retf		MACRO
		db	0cbh
ENDM

;_retf_		MACRO	p1
;		db	0cah		; retf and stack add
;		dw	p1
;ENDM

jmp_f		MACRO	ps, po
		db	0eah		; JMP FAR ssss:oooo
		dw	po, ps		; offset and segment
ENDM

call_f		MACRO	ps, po
		db	09ah		; CALL FAR ssss:oooo
		dw	po, ps		; offset and segment
ENDM

_cpuid		MACRO
	db	0fh,0a2h		; CPUID (partically 486 and p5+)
ENDM

_opsize		MACRO
	db	66h		; データ（オペランド）サイズ 16/32bits トグル 
ENDM

_adsize		MACRO
	db	67h		; アドレスサイズ 16/32bits トグル 
ENDM

jmp_s		MACRO	p1
	jmp	short p1
ENDM

ja_s		MACRO	p1
	ja	short p1
ENDM

jae_s		MACRO	p1
	jae	short p1
ENDM

jb_s		MACRO	p1
	jb	short p1
ENDM

jbe_s		MACRO	p1
	jbe	short p1
ENDM

jc_s		MACRO	p1
	jc	short p1
ENDM

jcxz_s		MACRO	p1
	jcxz	short p1
ENDM

jecxz_s		MACRO	p1
	jecxz	short p1
ENDM

je_s		MACRO	p1
	je	short p1
ENDM

jg_s		MACRO	p1
	jg	short p1
ENDM

jge_s		MACRO	p1
	jge	short p1
ENDM

jl_s		MACRO	p1
	jl	short p1
ENDM

jle_s		MACRO	p1
	jle	short p1
ENDM

jna_s		MACRO	p1
	jna	short p1
ENDM

jnae_s		MACRO	p1
	jnae	short p1
ENDM

jnb_s		MACRO	p1
	jnb	short p1
ENDM

jnbe_s		MACRO	p1
	jnbe	short p1
ENDM

jnc_s		MACRO	p1
	jnc	short p1
ENDM

jne_s		MACRO	p1
	jne	short p1
ENDM

jng_s		MACRO	p1
	jng	short p1
ENDM

jnge_s		MACRO	p1
	jnge	short p1
ENDM

jnl_s		MACRO	p1
	jnl	short p1
ENDM

jnle_s		MACRO	p1
	jnle	short p1
ENDM

jno_s		MACRO	p1
	jno	short p1
ENDM

jnp_s		MACRO	p1
	jnp	short p1
ENDM

jns_s		MACRO	p1
	jns	short p1
ENDM

jnz_s		MACRO	p1
	jnz	short p1
ENDM

jo_s		MACRO	p1
	jo	short p1
ENDM	

jp_s		MACRO	p1
	jp	short p1
ENDM	

jpe_s		MACRO	p1
	jpe	short p1
ENDM	

jpo_s		MACRO	p1
	jpo	short p1
ENDM	

js_s		MACRO	p1
	js	short p1
ENDM

jz_s		MACRO	p1
	jz	short p1
ENDM

