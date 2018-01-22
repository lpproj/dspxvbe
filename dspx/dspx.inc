COMMENT #
===============================================================================
 dspx.inc
 ver 1.00
 (c)ŽI/LP-Project. 1994-96
===============================================================================
#

		IFDEF	??version	; (if TASM...)
		NOWARN	PDC
		ENDIF

VEXT_VERSION_1	EQU	0100h
VEXT_VERSION_2	EQU	0200h

		IFNDEF	VEXT_VERSION
VEXT_VERSION	EQU	0200h
		ENDIF

		IF (VEXT_VERSION EQ 0200h)	; DOS/V Extension 2.0
VEXT_MAJOR	EQU	1
VEXT_MINOR	EQU	20
		ELSE				; DOS/V Extension 1.0
VEXT_MAJOR	EQU	1
VEXT_MINOR	EQU	0
		ENDIF

VT_HWCURSOR	EQU	00000001b
VT_SCRLWITHFILL	EQU	00000010b
VT_INVALIDMODE	EQU	10000000b

		IF (VEXT_VERSION GE VEXT_VERSION_2)	; DOS/V Extension 2.0
VT_VM_NORMAL	EQU	00000000b
VT_VM_TATE	EQU	00000100b
VT_VM_YOKO	EQU	00001000b
VT_VM_MASK	EQU	00001100b
		ENDIF

PRO_VIDEOCARD	EQU	'VideoCardInfo   '
PRO_FILENAME	EQU	'DriverFileName  '
PRO_MODETABLE	EQU	'VideoModeTable  '
PRO_DBCSMODE	EQU	'DBCSVideoMode   '
PRO_SBCSMODE	EQU	'SBCSVideoMode   '
PRO_OPTION	EQU	'OptionTable     '


		IF (VEXT_VERSION GE VEXT_VERSION_2)	; DOS/V Extension 2.0

tVms		STRUC
vms_vm			db	?
vms_info		db	?
vms_columns		db	?
vms_rows		db	?
vms_charwidth		db	?
vms_charheight		db	?
vms_fontwidth		db	?
vms_fontheight		db	?
vms_screenx		dw	?
vms_screeny		dw	?
vms_srcfontwidth	db	?
vms_srcfontheight	db	?
vms_fontindex		db	?
vms_reserved		db	?
tVms		ENDS

		ELSE					; DOS/V Extension 1.0

tVms		STRUC
vms_vm			db	?
vms_info		db	?
vms_columns		db	?
vms_rows		db	?
vms_charwidth		db	?
vms_charheight		db	?
vms_fontwidth		db	?
vms_fontheight		db	?
vms_screenx		dw	?
vms_screeny		dw	?
vms_reserved_1		dw	?
vms_reserved_2		dw	?
tVms		ENDS

	ENDIF

tDspx		STRUC
dspx_major		db	?
dspx_minor		db	?
dspx_info		dw	?
dspx_tbseg		dw	?
dspx_tbsize		dw	?
dspx_drv		dd	?
dspx_lock		dw	?
dspx_org10		dd	?
dspx_fonttbl		dw	?
dspx_texttbl		dw	?
dspx_palettetbl		dw	?
dspx_mode		dw	?
tDspx		ENDS


		IFDEF	LPDRV_API
		
;------------------------------------------------------------------------------
		
tDspxDrv	STRUC
drv_major		db	?
drv_minor		db	?
drv_primitive		dw	?
drv_vms			dw	?
drv_countoftbls		dw	?
drv_name		dw	?
drv_myapi		dw	?
tDspxDrv	ENDS

LPDRV_GETVER	EQU	0
LPDRV_GETSEG	EQU	1
LPDRV_SETSEG	EQU	2
LPDRV_QUERYMODIFYOPT	EQU	10h
LPDRV_MODIFYOPT		EQU	11h
LPDRV_GETVECTINFO	EQU	20h

LPDRV_USEVECT		EQU	1

tLPVect		STRUC
lpvect_no	db	?
lpvect_flag	db	00000000b
lpvect_new	dw	-1
lpvect_old	dd	?
tLPVect		ENDS


		ELSE

tDspxDrv	STRUC
drv_major		db	?
drv_minor		db	?
drv_primitive		dw	?
drv_vms			dw	?
drv_countoftbls		dw	?
drv_name		dw	?
tDspxDrv	ENDS

		ENDIF

		IFDEF	??version	; (if TASM ...)
		WARN	PDC
		ENDIF

