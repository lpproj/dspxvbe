#AS	= tasm
#AFLAGS	= /ml /t /dLPDRV_API
AS	= ml
AFLAGS	= -Cp -c -nologo -DLPDRV_API
#LD	= tlink
#LFLAGS	= /c /x
LD	= link
LFLAGS	= /NOI

INC	= mydef.inc dspx.inc dspxseg.inc

.asm.obj:
	$(AS) $(AFLAGS) $< ;

all : dspxdumy.exe dspxdumy.pro

clean : 
	delfree dspx*.obj dspxdumy.exe profdumy.obj dspxdumy.pro dspx.pro

dspxdumy.exe : dspxdumy.obj dspxldr.obj dspxcmn.obj
	$(LD) $(LFLAGS) dspxdumy+dspxldr+dspxcmn;

dspxdumy.pro : profdumy.obj
	$(LD) $(LFLAGS) profdumy;
	etob profdumy.exe dspxdumy.pro
	del profdumy.exe
	copy dspxdumy.pro dspx.pro

profdumy.obj : profdumy.asm profdumy.inc dspx.inc

dspxdumy.obj : dspxdumy.asm $(INC) dspxldr.inc

dspxcmn.obj : dspxcmn.asm $(INC)

dspxldr.obj : dspxldr.asm $(INC) dspxldr.inc

