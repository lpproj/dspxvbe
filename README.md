DSPXVBE - Extended Video (V-Text) Driver for IBM DOS/V Extension
================================================================

## about

IBM DOS/V Extension�̎d�l�ɏ��������ADOS/V��V-Text�h���C�o�ł��B
VESA VBE�ėp�̃h���C�o�ƁACirrus Logic CL-GD5428/5434�p�h���C�o��
�\�[�X���܂܂�Ă��܂��B

github�ł̌��J�ɂ�����A�\�[�X�Ɏ኱�̕ύX�������AJWasm�ŃA�Z���u��
�ł���悤�ɂ��Ă��܂��B�܂��ACirrus Logic�̃h���C�o�Ɋւ��ẮA
�r���h�����\�ɂȂ��Ă�����̂́A����m�F���s���Ă���܂���
�i�\�[�X�̈ꕔ���ۑ�����Ă��炸�A���ē��삵�Ă�����Ԃł̃r���h��
�s�\�Ȃ��߁A�u�o�C�i���쐬�͂ЂƂ܂��\�v�Ƃ�������ł̒񋟂�
�Ȃ�܂��j�B

�Ȃ��A�����[�X�ł̃o�C�i���͈ȉ��������\�ł��B

  http://hp.vector.co.jp/authors/VA003720/lpproj/dspxdrv.htm
  http://www.vector.co.jp/soft/dos/hardware/se042304.html


## Prerequisites

IBM�̓��{���PC DOS/V�i�������͓��{���OS/2 2.1�ȏ�j��
IBM DOS/V Extension���K�v�ƂȂ�܂��B


## How to build

OpenWatcom�Ɋ܂܂�郊���J(wlink)��make(wmake)�A�����ăA�Z���u���p��
JWasm�i����҂̃T�C�g�����łɏ������Ă���j���K�v�ƂȂ�܂��B

OpenWatcom:
  http://www.openwatcom.org/
  http://open-watcom.github.io/open-watcom/

JWasm:
  https://web.archive.org/web/20141010153046/http://www.japheth.de/JWasm.html
  https://sourceforge.net/projects/jwasm/

�i�e�f�B���N�g����Makefile.wc���蓮�ŏ���������΁AMicrosoft��MASM 6.x�ł�
�����炭�A�Z���u���\�ł��j

    wmake -f Makefile.wc


�\�[�X��The MIT License�ɂ��ƂÂ��A�Ĕz�z�A�ė��p�\�ł��B


2018-01-29
sava
