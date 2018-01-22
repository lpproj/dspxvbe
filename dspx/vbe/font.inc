COMMENT #
-------------------------------------------------------------------------------
 font.inc --- font.asm のインターフェース 


 GetSbcs : DWORD（常駐）
 半角フォントを読み込む FAR CALL 機能へのポインタ
   es:si ... 読み込むフォントの先頭アドレス
   cl    ... 文字コード
 [result] es:si ... 読み込んだフォントの先頭（CALL 前とでは違う場合がある）
          al    ... 不定


 GetDbcs : DWORD（常駐）
 全角フォントを読み込む FAR CALL 機能へのポインタ
   es:si ... 読み込むフォントの先頭アドレス
   cx    ... 文字コード
 [result] es:si ... 読み込んだフォントの先頭（CALL 前とでは違う場合がある）
          al    ... 不定


 SbcsCharBytes : WORD（常駐）
 半角１文字のデータのバイト数。
 int((vms.charwidth+7) / 8) * vms.charheight で算出されると御考え下さい。

 AssignFont : NEAR（常駐）
 GetSbcs, GetDbcs にフォント取得機能エントリをロードする。
   ds:bx ... tVms エントリ
   ds:si ... tFont 配列の先頭のエントリ
   cx    ... tFont 配列の数（１以上）
   tFont の配列は、１バイトの 0 で終える。
   [例]	tFont <>		; tFont[0]
 	tFont <>		; tFont[1]
 	db	0		; tFont はふたつ
 [result] al ... 0 ロードは失敗した（tVms の内容と一致する tFont がなかった）
 注 : tf_avail エントリが 0 の場合、その tFont エントリはスキャンされない。


 IsSbcsFontT : NEAR（常駐）
 
 tVms で示した半角フォントが存在するかどうか調べる。
   ds:bx ... tVms エントリ
 [result] al ... 0 なかった
          al ... 1 あった
          al ... 2 一応、あった（指定されたインデックス値はなかったので、
                   インデックス０で代用した）
          ah の値は保証されない。
          あった場合、フォント取得機能アドレスが GetSbcsT に保管される。
          なかった場合、GetSbcsT にはダミーのアドレスが保管される。


 IsDbcsFontT : NEAR（常駐）
 
 tVms で示した全角フォントが存在するかどうか調べる。
 （GetSbcsT とほぼ同じなので省略）



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
tf_info			db	?	; モード (VT_VM_? のいづれか)
tf_charwidth		db	?	; vms_charwidth に同じ
tf_charheight		db	?
tf_fontwidth		db	?	; vms_fontwidth に同じ
tf_fontheight		db	?
tf_srcfontwidth		db	?	; vms_srcfontwidth に同じ
tf_srcfontheight	db	?
tf_sbcs			dw	-1	; 半角フォントの伸長／回転ルーチン
tf_dbcs			dw	-1	; 全角
tf_chg0819		dw	-1	; 半角8x19ﾄﾞｯﾄの伸長／回転ルーチン
tFont		ENDS
