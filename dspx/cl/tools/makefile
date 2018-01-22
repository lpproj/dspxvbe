#AS	= tasm
#AFLAGS	= /ml /t /dLPDRV_API
AS	= ml
AFLAGS	= -Cp -c -nologo -DLPDRV_API
#LD	= tlink
#LFLAGS	= /c /x
LD	= link
LFLAGS	= /NOI

#INC	= mydef.inc 
INC	= 

.asm.obj:
	$(AS) $(AFLAGS) $< ;

.asm.com:
	$(AS) $(AFLAGS) $< ;
	$(LD) $(LFLAGS) $*.obj ;
	etob -c $*.exe
	del $*.exe

.asm.exe:
	$(AS) $(AFLAGS) $< ;
	$(LD) $(LFLAGS) $*.obj ;

all : clid.com clidhw.com clwrap64.sys clvbefix.exe

clean : 
	delfree clid.com clid.obj

clid.com : clid.asm $(INC)

clidhw.com : clidhw.asm $(INC)

clwrap64.sys : clwrap64.asm $(INC)
	$(AS) $(AFLAGS) $*.asm ;
	$(LD) $(LFLAGS) $*.obj ;
	etob $*.exe $*.sys
	del $*.exe

clvbefix.exe : clvbefix.asm $(INC)

