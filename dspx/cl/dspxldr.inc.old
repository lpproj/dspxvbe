COMMENT #
-------------------------------------------------------------------------------

 dspxldr.inc	- Interface between dspxldr and dspx-driver
 (c)鯖/LP-Project. 1995-96



 Drv_Opening : NEAR (非常駐）
 オープニング表示（初期化の処理が必要な時はここで行ってもかまわない。ただし
 Drv_Checkvideo の実行は基本的に Drv_Opening 以前である。）


 Drv_Displayhelp : NEAR（非常駐）
 ヘルプメッセージ表示。


 Drv_Checkvideo : NEAR（非常駐）
 ビデオドライバが現在のビデオチップに対応しているかどうか調べる。
 （/CHECK オプション指定時と常駐させるとき）
 al ... 0 /CHECK オプションが指定されていない場合
 al ... 1 指定されている場合
 [result] al ... 0 使える
                 1 使えない
                 2 わからない


 Drv_Checkvideoerr : NEAR（非常駐）
 Drv_Checkvideo が 0 以外の数を返してきたときはこれが呼び出される。
 
 al ... 1 「使えない」旨のエラーを表示
 al ... 2 「使えないかもしれない」旨のエラーを表示


 Drv_Getparam : NEAR（非常駐）

 起動時、コマンドラインのパラメータ解析が必要な場合、この中で適当に処理する。
 ds:bx ... パラメータの先頭アドレス。 ヌルコードで終わり。
 [result] al bit0 ... Drv_Getparam 側で解釈したらセット
                      （セットしない時はデフォルトの処理がなされる）
             bit7 ... bit0 = 1 で、パラメータの用法が間違っているときセット
          ah bit7 ... 回復不可能なエラーの際はセット


 Drv_Paramerr : NEAR（非常駐）

 Drv_Getparam でエラーを返した後、一度呼び出される。
 （何度エラーを返しても、Drv_Paramerr が呼び出されるのは最後に１回だけ）


 Drv_Preloadjob : NEAR（非常駐）

 ドライバが常駐するときに前処理が必要なら、ここで処理をする。
 Drv_Checkprof や Drv_Checkvms などの後、常駐部のＵＭＢ転送前に呼び出される。
 レジスタは基本的にすべて保存すること。

 Drv_Checkprof : NEAR（非常駐）
 プロファイル（DSPX.PRO）が本ドライバのものかどうか調べる。
 判別にはプロファイルの VideoCardInfo エントリの内容が使える
 es:di ... VideoCardInfo エントリの文字列先頭（ゼロで終わらないので注意）。
 cx ... エントリ文字のバイト数
 [result] al ... 0 使える
                 1 使えない（本ドライバのプロファイルではない）


 Drv_Checkvms : NEAR（非常駐）

 ds:si で示された tVms のエントリが使えるかどうかチェックする。
 [result]
 ax = 0		調べなかった。（vms_info の bit7 があらかじめセットされて
 		いて、なおかつこちらでクリアする気もない）
 ax = 1		使える。 vms_info の bit7 はクリアする。
 ax = 80h	使えない。 vms_info の bit7 はあらかじめクリアされていたが、
		こちらでセットする。


 Drv_Checkvmserr : NEAR（非常駐）

 Drv_Checkvms で「使えない」を一度でも返した場合、ひととおりチェックした
 後に１回だけ呼び出される。
 ふつうは単に「ビデオカードの都合で使えないモードがある」とか何とか
 メッセージを表示するだけ。


 Drv_Getbottom : NEAR（非常駐） 

 常駐部の終了オフセットを返す（PSP部は勘定にいれない）
 [result] bx 終了オフセット（バイト単位）


 Drv_Drvinfo : tDspxDrv（常駐）
 
 ドライバの tDspxDrv のオフセット。




[MYAPI] （常駐）
　tDspxDrv の drv_myapi エントリの１ワードが MYAPI への FAR エントリの
　オフセット部分である（セグメント部は tDspxDrv のあるセグメントを流用）
　ah にコマンド番号を入れて FAR CALL する。

　LPDRV_GETVER		バージョン取得

　LPDRV_GETSEG		常駐部のオーナセグメントアドレス取得
  [result] es ... オーナセグメントアドレス

　LPDRV_SETSEG		常駐部のオーナセグメントアドレス設定
  es ... オーナセグメントアドレス


[dspxldr が用意しているモジュール、変数]
 dspx_org_int10 : DWORD（常駐）
 
 $DISP.SYS 常駐以前の int 10h ベクタのアドレス。



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
