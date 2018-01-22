COMMENT #
===============================================================================
 vbeaxes.asm
===============================================================================
#

$DSPX$VBEACCESS = 0000h

		.XLIST
		INCLUDE mydef.inc
		INCLUDE dspx.inc
		INCLUDE dspxseg.inc
		
		INCLUDE vesa.inc
		INCLUDE vbeaxes.inc
		
		.LIST

G_DATA		SEGMENT

SizeofVram	dd	?

VbeInfos	LABEL	tVbeinfo
	tVbeinfo <103h, 800, 600>
	tVbeinfo <105h,1024, 768>
	tVbeinfo <107h,1280,1024>
	tVbeinfo <-1,  1152, 864>
	tVbeinfo <-1,  1600,1200>	; 120h (VBE 2.0)
cntVbeInfo 	= ( $ - VbeInfos ) / (SIZE tVbeinfo)

VbeVersion	dw	?

G_DATA		ENDS


_DATA		SEGMENT

wndseltbl	LABEL	WORD
		;Å®wndA	0(n/a)     1(r)	   2(w)	   3(r/w)	Å´wndB
		dw	-1,-1	, -1,-1	, -1,-1	,   0, 0	; 0 (n/a)
		dw	-1,-1,	, -1,-1	,  0, 1 ,   0, 0	; 1 (r)
		dw	-1,-1,	,  1, 0	, -1,-1 ,   0, 0	; 2 (w)
		dw	 1, 1	,  1, 1	,  1, 1	,   0, 0	; 3 (r/w)

_DATA		ENDS
_BSS		SEGMENT
vbevmptr	dd	?
vbeinfo		db	512 dup (?)
avail_vm	db	0
_BSS		ENDS

_TEXT		SEGMENT

CheckVbeMode	PROC	NEAR
	movseg	es,ds
	mov	di,ofs vbeinfo
	mov	word ptr [di],'BV'
	mov	word ptr [di+2],'2E'
	mov	ax,4f00h
	int	10h
	cmp	ax,004fh
	je	@@2
@@1_err:
	jmp	@@err
@@2:
	cmp	word ptr [di],'EV'
	jne	@@1_err
	cmp	word ptr [di+2],'AS'
	jne	@@1_err
	mov	[avail_vm],0
	mov	ax,[di + (tVesainf.vesai_ver)]
	mov	[VbeVersion],ax
	mov	ax,[di + (tVesainf.vesai_total)]
	mov	word ptr [SizeofVram],0
	mov	word ptr [SizeofVram+2],ax
	mov	ax,word ptr [di + (tVesainf.vesai_vm)]
	mov	word ptr [vbevmptr],ax
	mov	ax,word ptr [di + (tVesainf.vesai_vm + 2)]
	mov	word ptr [vbevmptr + 2],ax
	mov	si,ofs VbeInfos
	mov	di,ofs vbeinfo
	mov	bx,cntVbeInfo
@@lp:
	mov	cx,[si + (tVbeinfo.vbei_vm)]
	mov	ax,4f01h
	int	10h
	cmp	ax,004fh
	je	@@lp_2
@@lp_novm:
	mov	[si + (tVbeinfo.vbei_vm)],0
	jmp	@@lp_cont
@@lp_2:
	mov	ax,[di + (tVesam.vesam_attr)]
	and	ax,01010001b
	cmp	ax,00010001b
	jne	@@lp_novm
@@lp_cont:
	add	si,SIZE tVbeinfo
	dec	bx
	jnz	@@lp

@@err:
	mov	ax,1
	ret
CheckVbeMode	ENDP

SetVbeStat	PROC	NEAR
	pushm	<bx,cx>
	mov	[si + (tVbeinfo.vbei_pages)],0
	mov	ax,[di + (tVesam.vesam_gra)]
	mov	cx,1024
	mul	cx
	mov	word ptr [si + (tVbeinfo.vbei_gra)],ax
	mov	word ptr [si + (tVbeinfo.vbei_gra + 2)],dx
	mov	ax,[di + (tVesam.vesam_size)]
	mul	cx
	mov	word ptr [si + (tVbeinfo.vbei_wndsize)],ax
	mov	word ptr [si + (tVbeinfo.vbei_wndsize + 2)],dx
	mov	ax,word ptr [di + (tVesam.vesam_cntl)]
	mov	word ptr [si + (tVbeinfo.vbei_func)],ax
	mov	ax,word ptr [di + (tVesam.vesam_cntl + 2)]
	mov	word ptr [si + (tVbeinfo.vbei_func + 2)],ax
	mov	al,[di + (tVesam.vesam_attrA)]
	and	al,00000111b
	shr	al,1
	sbb	ah,ah
	and	al,ah
	xor	bx,bx
	mov	bl,al
	mov	al,[di + (tVesam.vesam_attrB)]
	and	al,00000111b
	shr	al,1
	sbb	ah,ah
	and	al,ah
	or	bl,al
	shl	bx,2
	mov	ax,word ptr [bx + ofs wndseltbl]
	mov	[si + (tVbeinfo.vbei_wndW)],ax
	mov	ax,word ptr [bx + ofs wndseltbl + 2]
	mov	[si + (tVbeinfo.vbei_wndR)],ax
	popm	<cx,bx>
	ret
SetVbeStat	ENDP


_TEXT		ENDS


	END
