# mikanos-build

このリポジトリは uchan が開発している教育用 OS [MikanOS](https://github.com/uchan-nos/mikanos) をビルドする手順およびツールを収録しています。
Ubuntu 18.04 で動作を確認しています。

ここで紹介する手順は Linux のコマンド操作にある程度慣れていることを前提に書かれています。
Linux のコマンドに不慣れな方は、まず [これだけは知っておきたい Linux コマンド](https://github.com/uchan-nos/os-from-zero/wiki/Basic-Linux-Commands) を読むことをお勧めします。

MikanOS のビルド手順は大きく次の 4 段階です。

1. ビルド環境の構築
2. MikanOS のソースコードの入手
3. ブートローダーのビルド
4. MikanOS のビルド

## ビルド環境の構築

ブートローダーおよび MikanOS 本体のビルドに必要なツールやファイルを揃えます。

### リポジトリのダウンロード

まずは Git をインストールして，mikanos-build リポジトリをダウンロードします。

    $ sudo apt update
    $ sudo apt install git
    $ cd $HOME
    $ git clone https://github.com/uchan-nos/mikanos-build.git osbook

mikanos-build 最新版は Ubuntu 22.04 をサポートしています。ただし、導入される lld-14 を使うとリンクアドレスがズレることにより OS やアプリが誤動作することが分かっています。
- [day03a以降、カーネルの起動まで進まない · Issue #134](https://github.com/uchan-nos/os-from-zero/issues/134)
- [tviewをLLVM 10でビルドするとページフォルトが発生する · Issue #4](https://github.com/uchan-nos/mikanos/issues/4)

lld-7 を使いたい場合は Ubuntu 18.04 か 20.04 をお使いください。Ubuntu 18.04 や 20.04 向けには次のコマンドを実行して古い mikanos-build を利用してください。

    $ cd osbook
    $ git checkout 8d4882122ec548ef680b6b5a2ae841a0fd4d07a1

### 開発ツールの導入

次に Clang，Nasm といった開発ツールや，EDK IIのセットアップを行います。
`ansible_provision.yml` に必要なツールが記載されています。
Ansible を使ってセットアップを行うと楽です。

注意）ansible_provision.yml は LLVM7 をデフォルトに設定します。これは Ubuntu の alternatives という仕組みを使い、/usr/bin 以下にリンクを張ることで実現しています。

    $ sudo apt install ansible
    $ cd $HOME/osbook/devenv
    $ ansible-playbook -K -i ansible_inventory ansible_provision.yml

セットアップが上手くいけば `iasl` というコマンドがインストールされ，`$HOME/edk2` というディレクトリが生成されているはずです。
これらがなければセットアップが失敗しています。

    $ iasl -v
    $ ls $HOME/edk2

WSL 上の Ubuntu で上記のコマンドを実行すると，`$HOME/.profile` に `DISPLAY` 環境変数の設定が追加されることがあります。
この設定を有効にするにはターミナルを再起動するか，次のコマンドを実行する必要があります。

    $ source $HOME/.profile

### 標準ライブラリのライセンスについて

加えて，上記の `ansible-playbook` コマンドはビルド済みの標準ライブラリを `$HOME/osbook/devenv/x86_64-elf` にダウンロードします。

このディレクトリに含まれるファイルは [Newlib](https://sourceware.org/newlib/)，[libc++](https://libcxx.llvm.org/)，[FreeType](https://www.freetype.org/) をビルドしたものです。
それらのライセンスはそれぞれのライブラリ固有のライセンスに従います。
MikanOS や mikanos-build リポジトリ全体のライセンスとは異なりますので注意してください。

次のファイル群は Newlib 由来です。ライセンスは `x86_64-elf/LICENSE.newlib` を参照してください。

    x86_64-elf/lib/
        libc.a
        libg.a
        libm.a
    x86_64-elf/include/
        c++/ を除くすべて

次のファイル群は libc++ 由来です。ライセンスは `x86_64-elf/LICENSE.libcxx` を参照してください。

    x86_64-elf/lib/
        libc++.a
        libc++abi.a
        libc++experimental.a
    x86_64-elf/include/c++/v1/
        すべて

次のファイル群は FreeType 由来です。ライセンスは `x86_64-elf/LICENSE.freetype` を参照してください。

    x86_64-elf/lib/
        libfreetype.a
    x86_64-elf/include/freetype2/
        すべて

## MikanOS のソースコードの入手

Git で入手できます。

    $ git clone https://github.com/uchan-nos/mikanos.git

最後の `git clone` によって、カレントディレクトリに mikanos ディレクトリが生成され、そこに MikanOS のソースコードがダウンロードされます。

## ブートローダーのビルド

EDK II のディレクトリに MikanOS ブートローダーのディレクトリをリンクします。

| :warning: 以下の `/path/to/mikanos` はご自身の環境に適した文字列に置き換えてください。 |
|:----|
| 『ゼロからのOS自作入門』にしたがって実験している場合は `ln -s $HOME/workspace/mikanos/MikanLoaderPkg ./` となるはずです。 |

    $ cd $HOME/edk2
    $ ln -s /path/to/mikanos/MikanLoaderPkg ./

`/path/to/mikanos` は先ほど `git clone` でダウンロードした mikanos ディレクトリへのパスを指定します。
ブートローダーのソースコードが正しく見えればリンク成功です。

    $ ls MikanLoaderPkg/Main.c

次に，`edksetup.sh` を読み込むことで EDK II のビルドに必要な環境変数を設定します。

    $ source edksetup.sh

`edksetup.sh` ファイルを読み込むと，環境変数が設定される他に `Conf/target.txt` が自動的に生成されます。
このファイルをエディタで開き，次の項目を修正します。

| 設定項目        | 設定値                            |
|-----------------|-----------------------------------|
| ACTIVE_PLATFORM | MikanLoaderPkg/MikanLoaderPkg.dsc |
| TARGET          | DEBUG                             |
| TARGET_ARCH     | X64                               |
| TOOL_CHAIN_TAG  | CLANG38                           |

設定が終わったらブートローダーをビルドします。

    $ build

- 「ModuleNotFoundError: No module named 'distutils.util'」というエラーが出る場合は、`sudo apt install python3-distutils` を実行してから再度 `build` を実行すると上手くいく可能性があります。試してみてください。
- 「Instance of library class [RegisterFilterLib] is not found」というエラーが出てビルドが失敗する場合は [RegisterFilterLib 関係のエラーで MikanLoaderPkg がビルドできません](https://github.com/uchan-nos/os-from-zero/blob/main/faq.md#registerfilterlib-%E9%96%A2%E4%BF%82%E3%81%AE%E3%82%A8%E3%83%A9%E3%83%BC%E3%81%A7-mikanloaderpkg-%E3%81%8C%E3%83%93%E3%83%AB%E3%83%89%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%9B%E3%82%93) を参照してください。

Loader.efi ファイルが出力されていればビルド成功です。

    $ ls Build/MikanLoaderX64/DEBUG_CLANG38/X64/Loader.efi

## MikanOS のビルド

ビルドに必要な環境変数を読み込みます。

    $ source $HOME/osbook/devenv/buildenv.sh

ビルドします。

    $ cd /path/to/mikanos
    $ ./build.sh

QEMU で起動するには `./build.sh` に `run` オプションを指定します。

    $ ./build.sh run

apps ディレクトリにアプリ群を入れ、フォントなどのリソースをも含めたディスクイメージを作るには APPS_DIR と RESOURCE_DIR 変数を指定します。

    $ APPS_DIR=apps RESOURCE_DIR=resource ./build.sh run
