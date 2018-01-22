COMMENT #
-------------------------------------------------------------------------------
 font.inc --- font.asm �̃C���^�[�t�F�[�X 


 GetSbcs : DWORD�i�풓�j
 ���p�t�H���g��ǂݍ��� FAR CALL �@�\�ւ̃|�C���^
   es:si ... �ǂݍ��ރt�H���g�̐擪�A�h���X
   cl    ... �����R�[�h
 [result] es:si ... �ǂݍ��񂾃t�H���g�̐擪�iCALL �O�Ƃł͈Ⴄ�ꍇ������j
          al    ... �s��


 GetDbcs : DWORD�i�풓�j
 �S�p�t�H���g��ǂݍ��� FAR CALL �@�\�ւ̃|�C���^
   es:si ... �ǂݍ��ރt�H���g�̐擪�A�h���X
   cx    ... �����R�[�h
 [result] es:si ... �ǂݍ��񂾃t�H���g�̐擪�iCALL �O�Ƃł͈Ⴄ�ꍇ������j
          al    ... �s��


 SbcsCharBytes : WORD�i�풓�j
 ���p�P�����̃f�[�^�̃o�C�g���B
 int((vms.charwidth+7) / 8) * vms.charheight �ŎZ�o�����ƌ�l���������B

 AssignFont : NEAR�i�풓�j
 GetSbcs, GetDbcs �Ƀt�H���g�擾�@�\�G���g�������[�h����B
   ds:bx ... tVms �G���g��
   ds:si ... tFont �z��̐擪�̃G���g��
   cx    ... tFont �z��̐��i�P�ȏ�j
   tFont �̔z��́A�P�o�C�g�� 0 �ŏI����B
   [��]	tFont <>		; tFont[0]
 	tFont <>		; tFont[1]
 	db	0		; tFont �͂ӂ���
 [result] al ... 0 ���[�h�͎��s�����itVms �̓��e�ƈ�v���� tFont ���Ȃ������j
 �� : tf_avail �G���g���� 0 �̏ꍇ�A���� tFont �G���g���̓X�L��������Ȃ��B


 IsSbcsFontT : NEAR�i�풓�j
 
 tVms �Ŏ��������p�t�H���g�����݂��邩�ǂ������ׂ�B
   ds:bx ... tVms �G���g��
 [result] al ... 0 �Ȃ�����
          al ... 1 ������
          al ... 2 �ꉞ�A�������i�w�肳�ꂽ�C���f�b�N�X�l�͂Ȃ������̂ŁA
                   �C���f�b�N�X�O�ő�p�����j
          ah �̒l�͕ۏ؂���Ȃ��B
          �������ꍇ�A�t�H���g�擾�@�\�A�h���X�� GetSbcsT �ɕۊǂ����B
          �Ȃ������ꍇ�AGetSbcsT �ɂ̓_�~�[�̃A�h���X���ۊǂ����B


 IsDbcsFontT : NEAR�i�풓�j
 
 tVms �Ŏ������S�p�t�H���g�����݂��邩�ǂ������ׂ�B
 �iGetSbcsT �Ƃقړ����Ȃ̂ŏȗ��j



-------------------------------------------------------------------------------
#

	IFDEF	$DSPX$FONT$VERSION
	
		PUBLIC	GetSbcs, GetDbcs
		PUBLIC	GetSbcsT, GetDbcsT
		PUBLIC	SbcsCharBytes
		
		PUBLIC	AssignFont
		
		PUBLIC	SbcsExpProc
	
	ELSE
	
		EXTRN	GetSbcs:DWORD, GetDbcs:DWORD
		EXTRN	GetSbcsT:DWORD, GetDbcsT:DWORD
		EXTRN	SbcsCharBytes:WORD
		
		EXTRN	AssignFont:NEAR
		
		EXTRN	SbcsExpProc:NEAR
	
	ENDIF

tFont		STRUC
tf_avail		db	0
tf_info			db	?	; ���[�h (VT_VM_? �̂��Âꂩ)
tf_charwidth		db	?	; vms_charwidth �ɓ���
tf_charheight		db	?
tf_fontwidth		db	?	; vms_fontwidth �ɓ���
tf_fontheight		db	?
tf_srcfontwidth		db	?	; vms_srcfontwidth �ɓ���
tf_srcfontheight	db	?
tf_sbcs			dw	-1	; ���p�t�H���g�̐L���^��]���[�`��
tf_dbcs			dw	-1	; �S�p
tf_chg0819		dw	-1	; ���p8x19�ޯĂ̐L���^��]���[�`��
tFont		ENDS