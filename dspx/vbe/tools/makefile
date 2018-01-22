#

AS	= tasm /ml
LD	= link /NOI


#all : hkv10.exe vmstack.sys
all : vbefix.exe

vbefix.exe : vbefix.asm
	$(AS) vbefix ;
	wlink file vbefix.obj option caseexact
	del vbefix.obj

hkv10.exe : hkv10.asm
	$(AS) hkv10 ;
	wlink file hkv10.obj option caseexact
	del hkv10.obj

vmstack.sys : vmstack.asm
	$(AS) vmstack ;
	wlink file vmstack.obj option caseexact
	copy vmstack.exe vmstack.sys
	del vmstack.obj
	del vmstack.exe
