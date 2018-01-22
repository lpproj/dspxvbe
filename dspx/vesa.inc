COMMENT #
===============================================================================
 vesa.inc
===============================================================================
#

tVesainf	STRUC
vesai_id	db	4 dup (?)	; VESA ID "VESA"
vesai_ver	dw	?	; Major , Minor (0102h as 1.2)
vesai_oemname	dd	?	; ptr to OEM name
vesai_capa	dd	?	; Capabilities
vesai_vm	dd	?	; ptr to video modes
vesai_total	dw	?	; VRAM amount (by 64k-bytes)
vesai_oemver	dw	?	; OEM version (VBE 2.0)
vesai_vendor	dd	?	; ptr to vendor name (VBE 2.0)
vesai_product	dd	?	; ptr to product name (VBE 2.0)
vesai_revision	dd	?	; ptr to revision str (VBE 2.0)

;(vesai_reserved	db	222 dup (?) )
;(vesai_oem_scratch	db	256 dup (?) )	; VBE 2.0
tVesainf	ENDS


tVesam		STRUC
vesam_attr	dw	?	; ���[�h��� 
vesam_attrA	db	?	; �E�C���h�E�`����
vesam_attrB	db	?	; �E�C���h�E�a����
vesam_gra	dw	?	; �E�C���h�E����\�iKB�P�ʁj
vesam_size	dw	?	; �E�C���h�E�T�C�Y�iKB�P�ʁj
vesam_segA	dw	?	; �E�C���h�E�`�Z�O�����g
vesam_segB	dw	?	; �E�C���h�E�a�Z�O�����g
vesam_cntl	dd	?	; �E�C���h�E�ݒ�֐��ւ̃|�C���^
vesam_bytes	dw	?	; �P�s�̃o�C�g��
				; ���������� VESA OEM Mode �ł̃T�|�[�g 
				; 
vesam_columns	dw	?	; ���̃h�b�g�i�����j��
vesam_rows	dw	?	; �c�̃h�b�g�i�����j��
vesam_width	db	?	; �L�����N�^�P�����̕��i�h�b�g�P�ʁj
vesam_height	db	?	; �L�����N�^�P�����̍����i�h�b�g�P�ʁj
vesam_planes	db	?	; �������[�v���[���̐�
vesam_bitspixel	db	?	; �P�h�b�g�\���ɕK�v�ȃr�b�g���i�F���j
vesam_banks	db	?	; �o���N��
vesam_mtype	db	?	; �������[���f���^�C�v
vesam_banksize	db	?	; �o���N�T�C�Y
vesam_pages	db	?	; �C���[�W�y�[�W��
vesam_reserved	db	?
				; ���������� VBE 1.2 �ȏ�
vesam_masksizeR	db	?	; �}�X�N�T�C�Y�i�ԁj
vesam_fposR	db	?	; �r�b�g�ʒu�i�ԁj
vesam_masksizeG	db	?	; �i�΁j
vesam_fposG	db	?	;
vesam_masksizeB	db	?	; �i�j
vesam_fposB	db	?	;
vesam_masksize_	db	?	; �i�\��j
vesam_fpos_	db	?	;
vesam_dcolor	db	?	; �_�C���N�g�J���[���
				; ���������� VBE 2.0 �ȏ�
vesam_padd	dd	?	; �r�f�I�o�b�t�@�̕����A�h���X
vesam_startoff	dd	?	
vesam_sizeoff	dd	?
tVesam		ENDS
