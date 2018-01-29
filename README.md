DSPXVBE - Extended Video (V-Text) Driver for IBM DOS/V Extension
================================================================

## about

IBM DOS/V Extensionの仕様に準拠した、DOS/VのV-Textドライバです。
VESA VBE汎用のドライバと、Cirrus Logic CL-GD5428/5434用ドライバの
ソースが含まれています。

githubでの公開にあたり、ソースに若干の変更を加え、JWasmでアセンブル
できるようにしています。また、Cirrus Logicのドライバに関しては、
ビルドこそ可能になっているものの、動作確認を行っておりません
（ソースの一部が保存されておらず、かつて動作していた状態でのビルドが
不可能なため、「バイナリ作成はひとまず可能」という現状での提供と
なります）。

なお、リリース版のバイナリは以下から入手可能です。

  http://hp.vector.co.jp/authors/VA003720/lpproj/dspxdrv.htm
  http://www.vector.co.jp/soft/dos/hardware/se042304.html


## Prerequisites

IBMの日本語版PC DOS/V（もしくは日本語版OS/2 2.1以上）と
IBM DOS/V Extensionが必要となります。


## How to build

OpenWatcomに含まれるリンカ(wlink)とmake(wmake)、そしてアセンブル用に
JWasm（原作者のサイトがすでに消失している）が必要となります。

OpenWatcom:
  http://www.openwatcom.org/
  http://open-watcom.github.io/open-watcom/

JWasm:
  https://web.archive.org/web/20141010153046/http://www.japheth.de/JWasm.html
  https://sourceforge.net/projects/jwasm/

（各ディレクトリのMakefile.wcを手動で書き換えれば、MicrosoftのMASM 6.xでも
おそらくアセンブル可能です）

    wmake -f Makefile.wc


ソースはThe MIT Licenseにもとづき、再配布、再利用可能です。


2018-01-29
sava
