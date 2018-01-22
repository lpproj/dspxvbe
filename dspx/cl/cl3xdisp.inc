COMMENT #
-------------------------------------------------------------------------------
 cl3xdisp.inc
 
 ScrnTfr	�P�s��]��
 cx	�\�[�X�̍��[�J�[�\���ʒu
 dx	�f�X�e�B�l�[�V�����̃J�[�\���ʒu
 bl	�]�����錅��
 cx,dx,bx �͕ۑ�����邪�Aecx,edx,ebx �̏�ʂP�U�r�b�g�ɂ��Ă͔j�󂳂��B
 
-------------------------------------------------------------------------------
#

		IFDEF $DSPX$CL3XDISP
		
		PUBLIC	Init_cl3xdisp
		PUBLIC	ChangeExtVm
		;PUBLIC	DispS, DispSmem
		;PUBLIC	DispD, DispDmem
		PUBLIC	DispSbcs, DispDbcs
		PUBLIC	FillRect
		PUBLIC	ScrnTfr
		PUBLIC	AbortBitBlt
		
		PUBLIC	SelectCsrHWSW
		PUBLIC	SetCsrPtn
		PUBLIC	DispCsr, EraseCsr
		
		PUBLIC	CacheSbcsToMem
		
		PUBLIC	CacheDbcsFonts
		PUBLIC	Init_dbcscache
		
		PUBLIC	SetFC, SetSFC, GetTsrLimit
		
		PUBLIC	SetMMIO
;------------------------------------------------------------------------------
		ELSE
		
		EXTRN	Init_cl3xdisp:NEAR
		EXTRN	ChangeExtVm:NEAR
		;EXTRN	DispS:NEAR, DispSmem:NEAR
		;EXTRN	DispD:NEAR, DispDmem:NEAR
		EXTRN	DispSbcs:NEAR, DispDbcs:NEAR
		EXTRN	FillRect:NEAR
		EXTRN	ScrnTfr:NEAR
		EXTRN	AbortBitBlt:NEAR
		
		EXTRN	SelectCsrHWSW:NEAR
		EXTRN	SetCsrPtn:WORD
		EXTRN	DispCsr:WORD, EraseCsr:WORD
		
		EXTRN	CacheSbcsToMem:NEAR
		
		EXTRN	CacheDbcsFonts:NEAR
		EXTRN	Init_dbcscache:NEAR
		
		EXTRN	SetFC:NEAR, SetSFC:NEAR
		EXTRN	GetTsrLimit:NEAR
		
		EXTRN	SetMMIO:NEAR
		
		ENDIF