COMMENT #
-------------------------------------------------------------------------------

 dspxldr.inc	- Interface between dspxldr and dspx-driver
 (c)�I/LP-Project. 1995-96



 Drv_Opening : NEAR (��풓�j
 �I�[�v�j���O�\���i�������̏������K�v�Ȏ��͂����ōs���Ă����܂�Ȃ��B������
 Drv_Checkvideo �̎��s�͊�{�I�� Drv_Opening �ȑO�ł���B�j


 Drv_Displayhelp : NEAR�i��풓�j
 �w���v���b�Z�[�W�\���B


 Drv_Checkvideo : NEAR�i��풓�j
 �r�f�I�h���C�o�����݂̃r�f�I�`�b�v�ɑΉ����Ă��邩�ǂ������ׂ�B
 �i/CHECK �I�v�V�����w�莞�Ə풓������Ƃ��j
 al ... 0 /CHECK �I�v�V�������w�肳��Ă��Ȃ��ꍇ
 al ... 1 �w�肳��Ă���ꍇ
 [result] al ... 0 �g����
                 1 �g���Ȃ�
                 2 �킩��Ȃ�


 Drv_Checkvideoerr : NEAR�i��풓�j
 Drv_Checkvideo �� 0 �ȊO�̐���Ԃ��Ă����Ƃ��͂��ꂪ�Ăяo�����B
 
 al ... 1 �u�g���Ȃ��v�|�̃G���[��\��
 al ... 2 �u�g���Ȃ���������Ȃ��v�|�̃G���[��\��


 Drv_Getparam : NEAR�i��풓�j

 �N�����A�R�}���h���C���̃p�����[�^��͂��K�v�ȏꍇ�A���̒��œK���ɏ�������B
 ds:bx ... �p�����[�^�̐擪�A�h���X�B �k���R�[�h�ŏI���B
 [result] al bit0 ... Drv_Getparam ���ŉ��߂�����Z�b�g
                      �i�Z�b�g���Ȃ����̓f�t�H���g�̏������Ȃ����j
             bit7 ... bit0 = 1 �ŁA�p�����[�^�̗p�@���Ԉ���Ă���Ƃ��Z�b�g
          ah bit7 ... �񕜕s�\�ȃG���[�̍ۂ̓Z�b�g


 Drv_Paramerr : NEAR�i��풓�j

 Drv_Getparam �ŃG���[��Ԃ�����A��x�Ăяo�����B
 �i���x�G���[��Ԃ��Ă��ADrv_Paramerr ���Ăяo�����͍̂Ō�ɂP�񂾂��j


 Drv_Preloadjob : NEAR�i��풓�j

 �h���C�o���풓����Ƃ��ɑO�������K�v�Ȃ�A�����ŏ���������B
 Drv_Checkprof �� Drv_Checkvms �Ȃǂ̌�A�풓���̂t�l�a�]���O�ɌĂяo�����B
 ���W�X�^�͊�{�I�ɂ��ׂĕۑ����邱�ƁB

 Drv_Checkprof : NEAR�i��풓�j
 �v���t�@�C���iDSPX.PRO�j���{�h���C�o�̂��̂��ǂ������ׂ�B
 ���ʂɂ̓v���t�@�C���� VideoCardInfo �G���g���̓��e���g����
 es:di ... VideoCardInfo �G���g���̕�����擪�i�[���ŏI���Ȃ��̂Œ��Ӂj�B
 cx ... �G���g�������̃o�C�g��
 [result] al ... 0 �g����
                 1 �g���Ȃ��i�{�h���C�o�̃v���t�@�C���ł͂Ȃ��j


 Drv_Checkvms : NEAR�i��풓�j

 ds:si �Ŏ����ꂽ tVms �̃G���g�����g���邩�ǂ����`�F�b�N����B
 [result]
 ax = 0		���ׂȂ������B�ivms_info �� bit7 �����炩���߃Z�b�g�����
 		���āA�Ȃ���������ŃN���A����C���Ȃ��j
 ax = 1		�g����B vms_info �� bit7 �̓N���A����B
 ax = 80h	�g���Ȃ��B vms_info �� bit7 �͂��炩���߃N���A����Ă������A
		������ŃZ�b�g����B


 Drv_Checkvmserr : NEAR�i��풓�j

 Drv_Checkvms �Łu�g���Ȃ��v����x�ł��Ԃ����ꍇ�A�ЂƂƂ���`�F�b�N����
 ��ɂP�񂾂��Ăяo�����B
 �ӂ��͒P�Ɂu�r�f�I�J�[�h�̓s���Ŏg���Ȃ����[�h������v�Ƃ����Ƃ�
 ���b�Z�[�W��\�����邾���B


 Drv_Getbottom : NEAR�i��풓�j 

 �풓���̏I���I�t�Z�b�g��Ԃ��iPSP���͊���ɂ���Ȃ��j
 [result] bx �I���I�t�Z�b�g�i�o�C�g�P�ʁj


 Drv_Drvinfo : tDspxDrv�i�풓�j
 
 �h���C�o�� tDspxDrv �̃I�t�Z�b�g�B




[MYAPI] �i�풓�j
�@tDspxDrv �� drv_myapi �G���g���̂P���[�h�� MYAPI �ւ� FAR �G���g����
�@�I�t�Z�b�g�����ł���i�Z�O�����g���� tDspxDrv �̂���Z�O�����g�𗬗p�j
�@ah �ɃR�}���h�ԍ������� FAR CALL ����B

�@LPDRV_GETVER		�o�[�W�����擾

�@LPDRV_GETSEG		�풓���̃I�[�i�Z�O�����g�A�h���X�擾
  [result] es ... �I�[�i�Z�O�����g�A�h���X

�@LPDRV_SETSEG		�풓���̃I�[�i�Z�O�����g�A�h���X�ݒ�
  es ... �I�[�i�Z�O�����g�A�h���X


[dspxldr ���p�ӂ��Ă��郂�W���[���A�ϐ�]
 dspx_org_int10 : DWORD�i�풓�j
 
 $DISP.SYS �풓�ȑO�� int 10h �x�N�^�̃A�h���X�B



-------------------------------------------------------------------------------
#

	IFDEF	DSPX$LDR$VERSION
	
		EXTRN	Drv_Getparam:NEAR
		EXTRN	Drv_Checkvideo:NEAR
		EXTRN	Drv_Preloadjob:NEAR
		EXTRN	Drv_Checkprof:NEAR
		EXTRN	Drv_Checkvms:NEAR
		EXTRN	Drv_Opening:NEAR
		EXTRN	Drv_Displayhelp:NEAR
		EXTRN	Drv_Paramerr:NEAR
		EXTRN	Drv_Checkvideoerr:NEAR
		EXTRN	Drv_Checkvmserr:NEAR
		EXTRN	Drv_Getbottom:NEAR
		
		EXTRN	Drv_Drvinfo:tDspxDrv
		
		PUBLIC	GetDspxldrVer
		PUBLIC	dspx_org_int10
	
	
	ELSE

		PUBLIC	Drv_Getparam
		PUBLIC	Drv_Checkvideo
		PUBLIC	Drv_Preloadjob
		PUBLIC	Drv_Checkprof
		PUBLIC	Drv_Checkvms
		PUBLIC	Drv_Opening
		PUBLIC	Drv_Displayhelp
		PUBLIC	Drv_Paramerr
		PUBLIC	Drv_Checkvideoerr
		PUBLIC	Drv_Checkvmserr
		PUBLIC	Drv_Getbottom
		
		PUBLIC	Drv_Drvinfo
		
		EXTRN	GetDspxldrVer:NEAR
		EXTRN	dspx_org_int10:DWORD
	
	ENDIF