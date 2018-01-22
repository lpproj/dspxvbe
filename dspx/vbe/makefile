#
#
#

AS	= tasm
AFLAGS	= /ml /t /i.. /dLPDRV_API
#AS	= ml
#AFLAGS	= -Cp -c -nologo -I.. -DLPDRV_API -Fo$@
#LD	= tlink
#LFLAGS	= /c /x
LD	= link
LFLAGS	= /NOI

INC	= ..\\mydef.inc ..\\dspx.inc ..\\dspxseg.inc ..\\dspxcmn.ah

.asm.obj:
#	$(AS) $(AFLAGS) -Fo$@ $< ;
	$(AS) $(AFLAGS) $<,$@ ;

all : dspxvben.exe dspxvbe.exe dspxvbe.pro

dspxvbe.exe : dspxvbe.obj dvbew64k.obj font.obj dspxcmn.obj dspxldr.obj
	ms2wlink $(LFLAGS) dspxvbe+dvbew64k+font+dspxldr+dspxcmn ; >VBE.LNK
	wlink @VBE.LNK

dspxvben.exe : dspxvben.obj dvbedisp.obj font.obj dspxcmn.obj dspxldr.obj
	ms2wlink $(LFLAGS) dspxvben+dvbedisp+font+dspxldr+dspxcmn, dspxvben ; >VBEN.LNK
	wlink @VBEN.LNK


dspxvbe.pro : profvbe.asm profvbe.inc
	tasm /ml profvbe ;
	link /TINY profvbe.obj, dspxvbe.pro ;
	del profvbe.obj
	copy dspxvbe.pro dspx.pro

dspxvbe.obj : dspxvbe.asm font.inc $(INC) profvbe.inc
	$(AS) $(AFLAGS) /dW64K dspxvbe ;

dspxvben.obj : dspxvbe.asm font.inc $(INC) profvbe.inc
	$(AS) $(AFLAGS) dspxvbe, dspxvben;

dvbedisp.obj : dvbedisp.asm dvbedisp.inc dspxvbe.inc
	$(AS) $(AFLAGS) dvbedisp.asm ;

dvbew64k.obj : dvbew64k.asm dvbedisp.inc dspxvbe.inc
	$(AS) $(AFLAGS) /dW64K dvbew64k.asm ;

dspxldr.obj : ..\\dspxldr.asm ..\\dspxldr.inc $(INC)
	$(AS) $(AFLAGS) ..\\dspxldr.asm, dspxldr ;

dspxcmn.obj : ..\\dspxcmn.obj $(INC)
	$(AS) $(AFLAGS) ..\\dspxcmn.asm, dspxcmn ;

