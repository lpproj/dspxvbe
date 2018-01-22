AS	= tasm
AFLAGS	= /ml /t /dLPDRV_API /i..
#AS	= ml
#AFLAGS	= -Cp -c -nologo -DLPDRV_API
#LD	= tlink
#LFLAGS	= /c
#LFLAGS	= /c /x
LD	= link
LFLAGS	= /NOI

INC	= mydef.inc dspx.inc dspxseg.inc

.asm.obj:
	$(AS) $(AFLAGS) $< ;

all : dspx543x.exe dspx543x.pro

dspx543x.pro : prof543x.asm prof543x.inc
	$(AS) $(AFLAGS) prof543x.asm ;
	$(LD) $(LFLAGS) prof543x ;
	etob prof543x.exe dspx543x.pro
	del prof543x.exe

dspx543x.exe : dspx543x.obj cl3xdisp.obj cl3xhw.obj dspxcmn.obj font.obj \
		fontexp.obj dspxldr.obj
	$(LD) $(LFLAGS) cl3xdisp+cl3xhw+font+fontexp+dspxldr+dspxcmn+dspx543x, dspx543x ;

dspx543x.obj : dspx543x.asm cl3xhw.inc

cl3xdisp.obj : cl3xdisp.asm cl3xdisp.inc cl3xhw.inc

fontexp.obj : fontexp.asm fontexp.inc font.inc

font.obj : font.asm font.inc

cl3xhw.obj : cl3xhw.asm cl3xhw.inc
