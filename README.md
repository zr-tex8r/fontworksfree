fontworksfree Package
=====================

LaTeX: Support for the free fonts provided by Fontworks

[Fontworks社のGitHubページ][fontworks-repos]においてOFL 1.1の下で
後悔されているTrueTypeフォント群を(u)pLaTeX＋dvipdfmxのワークフローで
利用するためのパッケージ。

### 前提環境

  * TeXフォーマット：LaTeX
  * LaTeXエンジン：欧文LaTeX／pLaTeX／upLaTeX
      - 欧文LaTeXでは欧文のみのサポート。
      - pdfLaTeXは不可。
  * DVIウェア：dvipdfmx
      - 20201019版以降を推奨。古い版の場合は一部の記号が出力できない・
        出力が不正になるという制限がある。

### インストール

  * 本パッケージ内のファイルを以下のように配置する。

      - `cmap/*`     → $TEXMF/fonts/cmap/fontworksfree
      - `ofm/*.ofm`  → $TEXMF/fonts/tfm/public/fontworksfree
      - `tfm/*.tfm`  → $TEXMF/fonts/ofm/public/fontworksfree
      - `vf/*.vf`    → $TEXMF/fonts/vf/public/fontworksfree
      - `tex/*.*`    → $TEXMF/tex/latex/fontworksfree
      - `*.map`      → $TEXMF/fonts/map/dvipdfmx/fontworksfree

  * [FontworksのGitHubレポジトリ][fontworks-repos]から以下のTrueType
    フォントファイルを取得する。

      - DotGothic16-Regular.ttf     （DotGothic16 内の fonts/ttf 以下）
      - KleeOne-Regular.ttf         （Klee 内の fonts/ttf 以下）
      - KleeOne-Semibold.ttf        （Klee 内の fonts/ttf 以下）
      - RampartOne-Regular.ttf      （Rampart 内の fonts/ttf 以下）
      - ReggaeOne-Regular.ttf       （Reggae 内の fonts/ttf 以下）
      - RocknRollOne-Regular.ttf    （RocknRoll 内の fonts/ttf 以下）
      - Stick-Regular.ttf           （Stick 内の fonts/ttf 以下）
      - TrainOne-Regular.ttf        （Train 内の fonts/ttf 以下）

    そして取得したファイルを以下のように配置する。

      - `*.map` → $TEXMF/fonts/truetype/fontworks/fontworksfree

※必要に応じて `mktexlsr` を実行する。

### ライセンス

MITライセンスの下で配布される。  
This package is distributed under the MIT License.


------------------------
fontworksfree パッケージ
------------------------

### 読込

オプションはない。

    \usepackage{fontworksfree}

※パッケージ読込時の`\Cjascale`の値を和文スケール値とする。`\Cjascale`
が未定義の場合の既定値は1である。

### 機能

パッケージを読み込むと以下のフォントファミリが提供される。

  * DotGothic16  → 和文 `dotgothic16`・欧文 `adotgothic16`
  * KleeOne      → 和文 `kleeone`・欧文 `akleeone`
      - SemiBoldウェイトを`b`シリーズに割り当てている。
  * RampartOne   → 和文 `rampartone`・欧文 `arampartone`
  * ReggaeOne    → 和文 `reggaeone`・欧文 `areggaeone`
  * RocknRollOne → 和文 `rocknrollone`・欧文 `arocknrollone`
  * Stick        → 和文 `stick`・欧文 `astick`
  * TrainOne     → 和文 `trainone`・欧文 `atrainone`

また、以下のファミリ切替命令が提供される。例えば、`\jkleeonefamily`は
和文のみ、`\akleeonefamily`は欧文のみ、`\kleeonefamily`は両方のファミリ
をKleeOneのものに切り替える。

  * `\dotgothicfamily`／`\jdotgothicfamily`／`\adotgothicfamily`
  * `\kleeonefamily`／`\jkleeonefamily`／`\akleeonefamily`
  * `\rampartonefamily`／`\jrampartonefamily`／`\arampartonefamily`
  * `\reggaeonefamily`／`\jreggaeonefamily`／`\areggaeonefamily`
  * `\rocknrollonefamily`／`\jrocknrollonefamily`／`\arocknrollonefamily`
  * `\stickfamily`／`\jstickfamily`／`\astickfamily`
  * `\trainonefamily`／`\jtrainonefamily`／`\atrainonefamily`


標準和文フォントとしての使用
----------------------------

fontworksfreeパッケージを利用しなくても、「和文フォントに対するdvipdfmx
のマップファイル行を設定する」作業を行えば、標準（＋japanese-otf）の
和文フォントとして対象のフォントを利用できる。このように使う場合は、
japanese-otfの機能と組み合わせる（例えば`\CID`命令で異体字や非Unicode
文字を出力する）ことも可能である。fontworksfreeパッケージを読み込んで
欧文だけそちらの機能を使うこともできる。

※この場合でも、本バンドル（特にその中のCMapファイル群）をインストール
しておくと、和文出力の機能が改善する。（例えば、KleeOneでUnicodeにない
「丸51」が出力できる。）

この「標準和文フォントとして設定する」作業は[pxchfonパッケージ]を利用
すると簡単に行える。以下にpxchfonとfontworksfreeパッケージを組み合わせて
使う例を掲載する。

    %#!uplatex
    \documentclass[uplatex,dvipdfmx,a4paper]{jsarticle}
    % ↓多ウェイトにしたいので'deluxe'を指定.
    \usepackage[deluxe]{otf}
    % ↓プリセット無しで, かつpxchfonの欧文出力は使わないので
    % 'noalphabet'を指定. 'unicode'は指定しない.
    \usepackage[noalphabet]{pxchfon}
    % ↓欧文出力の機能を使う.
    \usepackage{fontworksfree}
    % ↓和文の標準の"明朝体"にKleeOneを割り当てる.
    \setminchofont{KleeOne-Regular.ttf}% クレー One
    \setboldminchofont{KleeOne-SemiBold.ttf}% クレー One SemiBold
    % ↓欧文の標準の"セリフ体"にKleeOneを割り当てる.
    \renewcommand{\rmdefault}{akleeone}
    % ↓和文の標準の"丸ゴシック体"にRampartOneを割り当てる.
    \setmarugothicfont{RampartOne-Regular.ttf}% ランパート One
    % ↓'\Rampart'で和文欧文ともにRampartOneに切り替える.
    \newcommand*{\Rampart}{%
      %↓和文を"丸ゴシック"に変え, 欧文はfontworksfreeの命令を使う.
      \mgfamily \arampartonefamily}
    % ※"ゴシック/サンセリフ"の設定は変えていない.
    \begin{document}
    %↓和文でjapanese-otfの機能を利用できる.
    KleeOneのテスト。
    「本日は\textbf{晴天}なり\ajSnowman\ajMaru{88}」

    \Rampart RampartOneのテスト。\CID{7652}飾区！
    \end{document}


更新履歴
--------

  * Version 0.2 〈2021/02/21〉
      - 最初の公開版。


[fontworks-repos]: https://github.com/fontworks-fonts

--------------------
Takayuki YATO (aka. "ZR")  
https://github.com/zr-tex8r
